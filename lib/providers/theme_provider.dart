// CONCEPT: State Management with Provider
// Manages Cinema theme modes (Midnight Screening dark vs Matinee light) with persistence.

import 'package:flutter/material.dart';
import '../data/local_storage_service.dart';

class ThemeProvider extends ChangeNotifier {
  final LocalStorageService _storage;
  bool _isDarkMode = true;

  ThemeProvider(this._storage) {
    _isDarkMode = _storage.getIsDarkMode();
  }

  bool get isDarkMode => _isDarkMode;
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await _storage.setDarkMode(_isDarkMode);
    notifyListeners();
  }

  Future<void> setDarkMode(bool isDark) async {
    if (_isDarkMode != isDark) {
      _isDarkMode = isDark;
      await _storage.setDarkMode(_isDarkMode);
      notifyListeners();
    }
  }
}
