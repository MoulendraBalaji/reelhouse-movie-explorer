// CONCEPT: Navigation & Routing
// Named routes with onGenerateRoute, argument passing (movieId), route guards,
// custom PageRouteBuilder transitions (Iris, Fade-Through-Black "cut", Horizontal "wipe").

import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../theme/motion.dart';
import '../screens/splash_screen.dart';
import '../screens/home_screen.dart';
import '../screens/explore_screen.dart';
import '../screens/search_screen.dart';
import '../screens/detail_screen.dart';
import '../screens/watchlist_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/login_signup_screen.dart';
import '../screens/about_screen.dart';
import '../screens/not_found_screen.dart';

class AppRouter {
  AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    // Parse route name
    final uri = Uri.parse(settings.name ?? '/');
    var path = uri.path;

    // Normalize base-href for GitHub Pages: strip /reelhouse-movie-explorer prefix
    if (path.startsWith('/reelhouse-movie-explorer')) {
      path = path.substring('/reelhouse-movie-explorer'.length);
    }
    if (path.isEmpty) path = '/';
    if (path.length > 1 && path.endsWith('/')) {
      path = path.substring(0, path.length - 1);
    }

    switch (path) {
      case '/':
      case '/home':
        return fadeThroughBlackRoute(const HomeScreen(), settings);

      case '/splash':
        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) => const SplashScreen(),
          transitionDuration: Duration.zero,
        );

      case '/explore':
        return horizontalWipeRoute(const ExploreScreen(), settings);

      case '/search':
        return fadeThroughBlackRoute(const SearchScreen(), settings);

      case '/detail':
        final movieId = settings.arguments is int
            ? settings.arguments as int
            : int.tryParse(uri.queryParameters['id'] ?? '1') ?? 1;
        return fadeThroughBlackRoute(DetailScreen(movieId: movieId), settings);

      case '/watchlist':
        return horizontalWipeRoute(const WatchlistScreen(), settings);

      case '/profile':
        return horizontalWipeRoute(const ProfileScreen(), settings);

      case '/login':
        return fadeThroughBlackRoute(const LoginSignupScreen(), settings);

      case '/about':
        return horizontalWipeRoute(const AboutScreen(), settings);

      default:
        return fadeThroughBlackRoute(const NotFoundScreen(), settings);
    }
  }

  /// Fade-Through-Black "Cinema Cut" PageRouteBuilder
  static PageRouteBuilder<T> fadeThroughBlackRoute<T>(Widget page, RouteSettings settings) {
    return PageRouteBuilder<T>(
      settings: settings,
      transitionDuration: CinemaMotion.base,
      reverseTransitionDuration: CinemaMotion.quick,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        if (CinemaMotion.isReducedMotion(context)) {
          return child;
        }

        // Outgoing screen fades out to celluloid black in first half (0.0 - 0.5)
        // Incoming screen fades up from black in second half (0.5 - 1.0)
        final fadeIn = CurvedAnimation(
          parent: animation,
          curve: const Interval(0.45, 1.0, curve: Curves.easeIn),
        );

        return Stack(
          children: [
            Container(color: CinemaTokens.celluloidBlack),
            FadeTransition(
              opacity: fadeIn,
              child: child,
            ),
          ],
        );
      },
    );
  }

  /// Horizontal "Cinema Wipe" PageRouteBuilder
  static PageRouteBuilder<T> horizontalWipeRoute<T>(Widget page, RouteSettings settings) {
    return PageRouteBuilder<T>(
      settings: settings,
      transitionDuration: CinemaMotion.base,
      reverseTransitionDuration: CinemaMotion.quick,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        if (CinemaMotion.isReducedMotion(context)) {
          return child;
        }

        final slideIn = Tween<Offset>(
          begin: const Offset(0.08, 0.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: CinemaMotion.projectorCurve));

        final fadeIn = CurvedAnimation(
          parent: animation,
          curve: const Interval(0.2, 1.0, curve: Curves.easeIn),
        );

        return SlideTransition(
          position: slideIn,
          child: FadeTransition(
            opacity: fadeIn,
            child: child,
          ),
        );
      },
    );
  }
}
