import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';
import '../models/review.dart';
import '../models/user_profile.dart';

class LocalStorageService {
  final SharedPreferences _prefs;

  LocalStorageService(this._prefs);

  static Future<LocalStorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalStorageService(prefs);
  }

  // Watchlist (Saved Movie IDs)
  List<int> getWatchlist() {
    final list = _prefs.getStringList(CinemaConstants.keyWatchlist) ?? [];
    return list.map((e) => int.tryParse(e) ?? 0).where((id) => id > 0).toList();
  }

  Future<bool> saveWatchlist(List<int> movieIds) {
    return _prefs.setStringList(
      CinemaConstants.keyWatchlist,
      movieIds.map((e) => e.toString()).toList(),
    );
  }

  // Watched Movie IDs
  List<int> getWatchedMovies() {
    final list = _prefs.getStringList(CinemaConstants.keyWatched) ?? [];
    return list.map((e) => int.tryParse(e) ?? 0).where((id) => id > 0).toList();
  }

  Future<bool> saveWatchedMovies(List<int> movieIds) {
    return _prefs.setStringList(
      CinemaConstants.keyWatched,
      movieIds.map((e) => e.toString()).toList(),
    );
  }

  // Theme Mode (dark: true, light: false)
  bool getIsDarkMode() {
    return _prefs.getBool(CinemaConstants.keyThemeMode) ?? true;
  }

  Future<bool> setDarkMode(bool isDark) {
    return _prefs.setBool(CinemaConstants.keyThemeMode, isDark);
  }

  // Reduce Motion Setting
  bool getReduceMotion() {
    return _prefs.getBool(CinemaConstants.keyReduceMotion) ?? false;
  }

  Future<bool> setReduceMotion(bool reduce) {
    return _prefs.setBool(CinemaConstants.keyReduceMotion, reduce);
  }

  // Authentication State
  bool getIsLoggedIn() {
    return _prefs.getBool(CinemaConstants.keyUserAuth) ?? false;
  }

  Future<bool> setLoggedIn(bool loggedIn) {
    return _prefs.setBool(CinemaConstants.keyUserAuth, loggedIn);
  }

  UserProfile? getUserProfile() {
    final jsonStr = _prefs.getString('reelhouse_user_data');
    if (jsonStr == null || jsonStr.isEmpty) return null;
    try {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return UserProfile.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  Future<bool> saveUserProfile(UserProfile profile) {
    return _prefs.setString('reelhouse_user_data', jsonEncode(profile.toJson()));
  }

  // User Reviews
  List<Review> getReviews() {
    final list = _prefs.getStringList(CinemaConstants.keyUserReviews) ?? [];
    return list.map((str) {
      try {
        return Review.fromJson(jsonDecode(str) as Map<String, dynamic>);
      } catch (_) {
        return null;
      }
    }).whereType<Review>().toList();
  }

  Future<bool> saveReviews(List<Review> reviews) {
    final encoded = reviews.map((r) => jsonEncode(r.toJson())).toList();
    return _prefs.setStringList(CinemaConstants.keyUserReviews, encoded);
  }

  // Recent Searches
  List<String> getRecentSearches() {
    return _prefs.getStringList(CinemaConstants.keyRecentSearches) ?? [];
  }

  Future<bool> saveRecentSearches(List<String> searches) {
    return _prefs.setStringList(CinemaConstants.keyRecentSearches, searches);
  }
}
