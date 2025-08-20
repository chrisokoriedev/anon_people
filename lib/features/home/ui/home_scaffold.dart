import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';

class HomeScaffold extends StatefulWidget {
  const HomeScaffold({super.key, required this.child});
  final Widget child;

  @override
  State<HomeScaffold> createState() => _HomeScaffoldState();
}

class _HomeScaffoldState extends State<HomeScaffold> {
  int _indexFromLocation(String location) {
    if (location.startsWith('/chat')) return 1;
    if (location.startsWith('/settings')) return 2;
    return 0; // posts default
  }

  String _locationFromIndex(int index) {
    switch (index) {
      case 1:
        return '/chat';
      case 2:
        return '/settings';
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
      bottomNavigationBar: AnimatedBottomNavigationBar(
        icons: const [
          Icons.article_outlined,
          Icons.chat_bubble_outline,
          Icons.settings_outlined,
        ],
        activeIcons: const [
          Icons.article,
          Icons.chat_bubble,
          Icons.settings,
        ],
        activeIndex: index,
        gapLocation: GapLocation.none,
        notchSmoothness: NotchSmoothness.softEdge,
        leftCornerRadius: 0,
        rightCornerRadius: 0,
        onTap: (value) {
          final target = _locationFromIndex(value);
          if (target != location) context.go(target);
        },
        backgroundColor: Theme.of(context).colorScheme.surface,
        activeColor: Theme.of(context).colorScheme.primary,
        inactiveColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
        splashColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        splashSpeedInMilliseconds: 300,
        notchAndCornersAnimation: animation,
        switchAnimation: switchAnimation,
        colorChangeAnimation: colorChangeAnimation,
      ),
    );
  }

  final animation = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );

  final switchAnimation = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );

  final colorChangeAnimation = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );
}


