import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/providers.dart';
import '../features/auth/ui/login_page.dart';
import '../features/posts/ui/posts_page.dart';
import '../features/chat/ui/chat_page.dart';
import '../features/settings/ui/settings_page.dart';
import '../features/home/ui/home_scaffold.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authAsync = ref.watch(authStateChangesProvider);
  final authStream = ref.read(firebaseAuthProvider).authStateChanges();

  return GoRouter(
    debugLogDiagnostics: false,
    initialLocation: '/posts',
    refreshListenable: GoRouterRefreshStream(authStream),
    redirect: (context, state) {
      final isLoggingIn = state.matchedLocation == '/login';
      final user = authAsync.asData?.value;
      if (user == null) {
        return isLoggingIn ? null : '/login';
      }
      if (isLoggingIn) return '/posts';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      ShellRoute(
        builder: (context, state, child) => HomeScaffold(child: child),
        routes: [
          GoRoute(
            path: '/posts',
            builder: (context, state) => const PostsPage(),
          ),
          GoRoute(
            path: '/chat',
            builder: (context, state) => const ChatPage(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsPage(),
          ),
        ],
      ),
    ],
  );
});

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListener = () => notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }
  late final VoidCallback notifyListener;
  late final StreamSubscription<dynamic> _subscription;
  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}


