// CONCEPT: State Management with Provider
// Mock authentication with persistent user profile in LocalStorage.

import 'package:flutter/foundation.dart';
import '../data/local_storage_service.dart';
import '../models/user_profile.dart';

class AuthProvider extends ChangeNotifier {
  final LocalStorageService _storage;
  bool _isLoggedIn = false;
  UserProfile _user = const UserProfile(
    name: 'Arthur Pendelton',
    email: 'archivist@reelhouse.cinema',
    bio: 'Cinema projectionist & avid film 35mm archivist.',
    memberSince: '1974',
    favoriteGenre: 'Science Fiction',
    watchedCount: 38,
    totalHours: 94.5,
  );

  AuthProvider(this._storage) {
    _isLoggedIn = _storage.getIsLoggedIn();
    final saved = _storage.getUserProfile();
    if (saved != null) {
      _user = saved;
    }
  }

  bool get isLoggedIn => _isLoggedIn;
  UserProfile get user => _user;

  Future<bool> login(String email, String password) async {
    // Simulated auth delay
    await Future.delayed(const Duration(milliseconds: 300));
    _isLoggedIn = true;
    await _storage.setLoggedIn(true);
    _user = _user.copyWith(email: email);
    await _storage.saveUserProfile(_user);
    notifyListeners();
    return true;
  }

  Future<bool> signup(String name, String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _isLoggedIn = true;
    await _storage.setLoggedIn(true);
    _user = UserProfile(
      name: name,
      email: email,
      memberSince: '2024',
      bio: 'New Reelhouse cinema member.',
      favoriteGenre: 'Drama',
      watchedCount: 0,
      totalHours: 0.0,
    );
    await _storage.saveUserProfile(_user);
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    await _storage.setLoggedIn(false);
    notifyListeners();
  }

  Future<void> updateProfile({
    required String name,
    required String email,
    required String bio,
    required String favoriteGenre,
  }) async {
    _user = _user.copyWith(
      name: name,
      email: email,
      bio: bio,
      favoriteGenre: favoriteGenre,
    );
    await _storage.saveUserProfile(_user);
    notifyListeners();
  }
}
