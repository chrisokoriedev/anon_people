import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import '../domain/post.dart';

class PostsPageResult {
  PostsPageResult({required this.items, required this.nextStartAfter});
  final List<Post> items;
  final DocumentSnapshot? nextStartAfter;
}

class PostsRepository {
  PostsRepository(this._firestore);
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _postsCol =>
      _firestore.collection('posts');

  Future<PostsPageResult> fetchPostsPage({
    required int limit,
    DocumentSnapshot? startAfter,
  }) async {
    Query<Map<String, dynamic>> q = _postsCol
        .orderBy('createdAt', descending: true)
        .limit(limit);
    if (startAfter != null) {
      q = (q).startAfterDocument(startAfter);
    }
    final snap = await q.get();
    final docs = snap.docs;
    final items = docs.map((d) => Post.fromDoc(d)).toList(growable: false);
    final nextKey = docs.isNotEmpty ? docs.last : null;
    return PostsPageResult(items: items, nextStartAfter: nextKey);
  }
}

final postsRepositoryProvider = Provider<PostsRepository>((ref) {
  final db = ref.watch(firestoreProvider);
  return PostsRepository(db);
});
