import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:reelhouse/data/local_storage_service.dart';
import 'package:reelhouse/providers/watchlist_provider.dart';
import 'package:reelhouse/providers/theme_provider.dart';
import 'package:reelhouse/providers/settings_provider.dart';

void main() {
  group('Providers Business Logic Tests', () {
    late LocalStorageService storage;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      storage = await LocalStorageService.init();
    });

    test('WatchlistProvider adds, removes and supports undo', () async {
      final provider = WatchlistProvider(storage);
      expect(provider.watchlist, isEmpty);

      // Add movie
      await provider.addToWatchlist(42);
      expect(provider.isWatchlisted(42), isTrue);
      expect(provider.watchlist, contains(42));

      // Remove movie
      await provider.removeFromWatchlist(42);
      expect(provider.isWatchlisted(42), isFalse);

      // Undo removal
      final restored = await provider.undoRemove();
      expect(restored, isTrue);
      expect(provider.isWatchlisted(42), isTrue);
    });

    test('WatchlistProvider toggles watched status', () async {
      final provider = WatchlistProvider(storage);
      expect(provider.isWatched(10), isFalse);

      await provider.toggleWatched(10);
      expect(provider.isWatched(10), isTrue);

      await provider.toggleWatched(10);
      expect(provider.isWatched(10), isFalse);
    });

    test('ThemeProvider toggles dark and light mode', () async {
      final provider = ThemeProvider(storage);
      expect(provider.isDarkMode, isTrue);

      await provider.toggleTheme();
      expect(provider.isDarkMode, isFalse);

      await provider.setDarkMode(true);
      expect(provider.isDarkMode, isTrue);
    });

    test('SettingsProvider toggles reduce motion preference', () async {
      final provider = SettingsProvider(storage);
      expect(provider.reduceMotion, isFalse);

      await provider.setReduceMotion(true);
      expect(provider.reduceMotion, isTrue);

      await provider.toggleReduceMotion();
      expect(provider.reduceMotion, isFalse);
    });
  });
}
