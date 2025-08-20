import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScaffold extends StatefulWidget {
  const HomeScaffold({super.key, required this.child});
  final Widget child;

  @override
  State<HomeScaffold> createState() => _HomeScaffoldState();
}

class _HomeScaffoldState extends State<HomeScaffold> {
  int _indexFromLocation(String location) {
    if (location.startsWith('/chat')) return 1;
    return 0; // posts default
  }

  String _locationFromIndex(int index) {
    switch (index) {
      case 1:
        return '/chat';
      case 0:
      default:
        return '/posts';
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final index = _indexFromLocation(location);
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.article_outlined),
              selectedIcon: Icon(Icons.article),
              label: 'Posts'),
          NavigationDestination(
              icon: Icon(Icons.chat_bubble_outline),
              selectedIcon: Icon(Icons.chat_bubble),
              label: 'Chat'),
        ],
        onDestinationSelected: (value) {
          final target = _locationFromIndex(value);
          if (target != location) context.go(target);
        },
      ),
    );
  }
}


