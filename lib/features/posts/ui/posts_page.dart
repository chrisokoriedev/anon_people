import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../../posts/data/posts_repository.dart';
import '../domain/post.dart';
import '../../auth/data/auth_repository.dart';

class PostsPage extends HookConsumerWidget {
  const PostsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pagingController = useMemoized(
      () => PagingController<DocumentSnapshot?, Post>(firstPageKey: null),
    );

    useEffect(() {
      void listener(DocumentSnapshot? pageKey) async {
        try {
          final repo = ref.read(postsRepositoryProvider);
          const limit = 20;
          final result = await repo.fetchPostsPage(
            limit: limit,
            startAfter: pageKey,
          );
          final items = result.items;
          final nextKey = result.nextStartAfter;
          final isLastPage = items.length < limit || nextKey == null;
          if (isLastPage) {
            pagingController.appendLastPage(items);
          } else {
            pagingController.appendPage(items, nextKey);
          }
        } catch (e) {
          pagingController.error = e;
        }
      }

      pagingController.addPageRequestListener(listener);
      return () {
        pagingController.removePageRequestListener(listener);
        pagingController.dispose();
      };
    }, const []);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts'),
        actions: const [_SignOutButton()],
      ),
      body: RefreshIndicator(
        onRefresh: () async => pagingController.refresh(),
        child: PagedListView<DocumentSnapshot?, Post>.separated(
          shrinkWrap: true,
          pagingController: pagingController,
          separatorBuilder: (_, __) => const Divider(height: 0),
          builderDelegate: PagedChildBuilderDelegate<Post>(
            itemBuilder: (context, item, index) => _PostTile(post: item),
            firstPageProgressIndicatorBuilder: (_) => const _ShimmerList(),
            newPageProgressIndicatorBuilder:
                (_) => const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                ),
            noItemsFoundIndicatorBuilder:
                (_) => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('No posts yet'),
                  ),
                ),
            firstPageErrorIndicatorBuilder:
                (_) => _ErrorRetry(onRetry: pagingController.refresh),
            newPageErrorIndicatorBuilder:
                (_) => _ErrorRetry(
                  onRetry: pagingController.retryLastFailedRequest,
                ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // TODO: Create post flow
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Create post not implemented')),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Post'),
      ),
    );
  }
}

class _PostTile extends StatelessWidget {
  const _PostTile({required this.post});
  final Post post;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(post.content),
      subtitle: Text(post.authorTag ?? 'Anonymous'),
      trailing: Text(post.createdAtLabel),
    );
  }
}

class _ShimmerList extends StatelessWidget {
  const _ShimmerList();
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemBuilder: (_, __) => const _ShimmerTile(),
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemCount: 6,
    );
  }
}

class _ShimmerTile extends StatelessWidget {
  const _ShimmerTile();
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

class _ErrorRetry extends StatelessWidget {
  const _ErrorRetry({required this.onRetry});
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Something went wrong'),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

class _SignOutButton extends ConsumerWidget {
  const _SignOutButton();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      tooltip: 'Sign out',
      onPressed: () async {
        await ref.read(authRepositoryProvider).signOut();
      },
      icon: const Icon(Icons.logout),
    );
  }
}
