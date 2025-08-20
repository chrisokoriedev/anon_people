import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';

class HomeScaffold extends StatefulWidget {
  const HomeScaffold({super.key, required this.child});
  final Widget child;

  @override
  State<HomeScaffold> createState() => _HomeScaffoldState();
}

class _HomeScaffoldState extends State<HomeScaffold>
    with TickerProviderStateMixin {
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
        inactiveColor: Theme.of(
          context,
        ).colorScheme.onSurface.withValues(alpha: 0.5),
        splashColor:
            Theme.of(context).colorScheme.primary..withValues(alpha: 0.1),
        splashSpeedInMilliseconds: 300,
        notchAndCornersAnimation: animation,
      ),
    );
  }

  late final AnimationController animation = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );

  @override
  void dispose() {
    animation.dispose();
    super.dispose();
  }
}
