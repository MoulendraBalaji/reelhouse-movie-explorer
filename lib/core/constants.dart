/// Application-wide constants for REELHOUSE Cinema.
class CinemaConstants {
  CinemaConstants._();

  static const String appName = 'REELHOUSE';
  static const String appTagline = 'Every film, one reel at a time';
  static const String appVersion = '1.0.0';

  // TMDB API Configuration
  // Passed via --dart-define=TMDB_KEY="..." or defaults to empty string (triggering offline fallback)
  static const String tmdbApiKey = String.fromEnvironment('TMDB_KEY', defaultValue: '');
  static const String tmdbBaseUrl = 'https://api.themoviedb.org/3';
  static const String tmdbImageBaseUrl = 'https://image.tmdb.org/t/p';

  // Fallback Data Path
  static const String fallbackMoviesJson = 'assets/data/movies.json';

  // Storage Keys
  static const String keyWatchlist = 'reelhouse_watchlist';
  static const String keyWatched = 'reelhouse_watched';
  static const String keyThemeMode = 'reelhouse_theme_mode';
  static const String keyReduceMotion = 'reelhouse_reduce_motion';
  static const String keyUserAuth = 'reelhouse_user_auth';
  static const String keyUserReviews = 'reelhouse_reviews';
  static const String keyRecentSearches = 'reelhouse_recent_searches';

  // Genres list for filters
  static const List<String> genres = [
    'ALL',
    'Action',
    'Adventure',
    'Animation',
    'Crime',
    'Drama',
    'Horror',
    'Mystery',
    'Romance',
    'Science Fiction',
    'Thriller',
  ];
}
