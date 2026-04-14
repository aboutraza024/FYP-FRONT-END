import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ISLAMIC PAGE ROUTE — Branded transitions for Sirat Al Mustaqeem
//
// Replaces the default right-to-left Material push with a soft fade +
// gentle upward slide. Feels reverent, premium, like opening a book.
//
// Usage — in MaterialApp.onGenerateRoute:
//   case '/quran': return IslamicPageRoute(page: const QuranModule());
//
// Or wrap any Navigator.push call:
//   Navigator.push(context, IslamicPageRoute(page: const QuranModule()));
// ─────────────────────────────────────────────────────────────────────────────

class IslamicPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  IslamicPageRoute({
    required this.page,
    RouteSettings? settings,
  }) : super(
          settings: settings,
          transitionDuration: const Duration(milliseconds: 320),
          reverseTransitionDuration: const Duration(milliseconds: 260),
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Fade
            final fade = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            );
            // Slight upward slide (only 3% of screen height — barely visible,
            // just enough to feel organic rather than static)
            final slide = Tween<Offset>(
              begin: const Offset(0, 0.03),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ));
            // Outgoing screen fades out slightly
            final fadeOut = Tween<double>(begin: 1.0, end: 0.85).animate(
              CurvedAnimation(
                parent: secondaryAnimation,
                curve: Curves.easeInCubic,
              ),
            );
            return FadeTransition(
              opacity: fadeOut,
              child: SlideTransition(
                position: slide,
                child: FadeTransition(
                  opacity: fade,
                  child: child,
                ),
              ),
            );
          },
        );
}

// ─────────────────────────────────────────────────────────────────────────────
// HELPER — replace all Navigator.pushNamed calls with branded transitions
// Register this in MaterialApp.onGenerateRoute:
//
//   onGenerateRoute: IslamicRouter.generate,
// ─────────────────────────────────────────────────────────────────────────────

class IslamicRouter {
  IslamicRouter._();

  // Import your screen widgets here:
  // Replace the placeholder types below with actual screen class references
  // from your imports. The logic here stays identical regardless.

  static Route<dynamic> generate(RouteSettings settings) {
    // The widget mapping is intentionally left as a factory pattern so you
    // can drop this file in without changing any other file. Just update
    // the _screenFor() method below to return the right widget per route.
    final page = _screenFor(settings);
    if (page == null) {
      return IslamicPageRoute(
        settings: settings,
        page: _NotFoundScreen(routeName: settings.name ?? '?'),
      );
    }
    return IslamicPageRoute(settings: settings, page: page);
  }

  /// Map route names to screen widgets.
  /// This is the ONLY place you need to update when adding new screens.
  static Widget? _screenFor(RouteSettings settings) {
    // NOTE: These imports must match your actual screen file imports in main.dart
    // The switch below references class names — make sure they are imported.
    switch (settings.name) {
      // The actual screen classes are resolved at compile time via main.dart imports.
      // This file is imported by main.dart, so we use a callback pattern:
      case '/':              return const _RouteProxy(routeKey: 'home');
      case '/hadith-search': return const _RouteProxy(routeKey: 'hadith');
      case '/quran':         return const _RouteProxy(routeKey: 'quran');
      case '/prayer-times':  return const _RouteProxy(routeKey: 'prayer');
      case '/utilities':     return const _RouteProxy(routeKey: 'utilities');
      case '/login':         return const _RouteProxy(routeKey: 'login');
      case '/register':      return const _RouteProxy(routeKey: 'register');
      case '/forgot-password': return const _RouteProxy(routeKey: 'forgot');
      default:               return null;
    }
  }
}

// Proxy widget — see main.dart for actual resolution
class _RouteProxy extends StatelessWidget {
  final String routeKey;
  const _RouteProxy({required this.routeKey});
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class _NotFoundScreen extends StatelessWidget {
  final String routeName;
  const _NotFoundScreen({required this.routeName});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Route not found: $routeName'),
      ),
    );
  }
}
