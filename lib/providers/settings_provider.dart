// CONCEPT: State Management with Provider
// Manages user accessibility settings including Reduce Motion toggle with persistence.

import 'package:flutter/foundation.dart';
import '../data/local_storage_service.dart';

class SettingsProvider extends ChangeNotifier {
  final LocalStorageService _storage;
  bool _reduceMotion = false;

  SettingsProvider(this._storage) {
    _reduceMotion = _storage.getReduceMotion();
  }

  bool get reduceMotion => _reduceMotion;

  Future<void> setReduceMotion(bool value) async {
    if (_reduceMotion != value) {
      _reduceMotion = value;
      await _storage.setReduceMotion(value);
      notifyListeners();
    }
  }

  Future<void> toggleReduceMotion() async {
    await setReduceMotion(!_reduceMotion);
  }
}
