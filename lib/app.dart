// CONCEPT: State Management with MultiProvider at root, Theme switching, and MotionScope
// MaterialApp with named routing, dark "Midnight" & light "Matinee" themes.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/router.dart';
import 'core/constants.dart';
import 'theme/app_theme.dart';
import 'theme/motion.dart';
import 'data/local_storage_service.dart';
import 'data/movie_repository.dart';
import 'providers/movie_provider.dart';
import 'providers/watchlist_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/search_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/reviews_provider.dart';
import 'providers/settings_provider.dart';

class ReelhouseApp extends StatelessWidget {
  final LocalStorageService storage;
  final MovieRepository repository;

  const ReelhouseApp({
    super.key,
    required this.storage,
    required this.repository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider(storage)),
        ChangeNotifierProvider(create: (_) => SettingsProvider(storage)),
        ChangeNotifierProvider(create: (_) => AuthProvider(storage)),
        ChangeNotifierProvider(create: (_) => WatchlistProvider(storage)),
        ChangeNotifierProvider(create: (_) => ReviewsProvider(storage)),
        ChangeNotifierProvider(create: (_) => MovieProvider(repository)..loadCatalog()),
        ChangeNotifierProvider(create: (_) => SearchProvider(repository, storage)),
      ],
      child: Consumer2<ThemeProvider, SettingsProvider>(
        builder: (context, themeProvider, settingsProvider, _) {
          return MotionScope(
            reduceMotion: settingsProvider.reduceMotion,
            child: MaterialApp(
              title: CinemaConstants.appName,
              debugShowCheckedModeBanner: false,
              theme: CinemaTheme.matineeTheme,
              darkTheme: CinemaTheme.midnightTheme,
              themeMode: themeProvider.themeMode,
              onGenerateRoute: AppRouter.onGenerateRoute,
              initialRoute: '/home',
            ),
          );
        },
      ),
    );
  }
}
