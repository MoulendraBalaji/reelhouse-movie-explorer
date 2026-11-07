// CONCEPT: State Management with Provider & ChangeNotifier
// Manages persisted Watchlist and Watched films with undo capability.

import 'package:flutter/foundation.dart';
import '../data/local_storage_service.dart';

class WatchlistProvider extends ChangeNotifier {
  final LocalStorageService _storage;
  List<int> _watchlist = [];
  List<int> _watched = [];

  // For undo support
  int? _lastRemovedId;
  int? _lastRemovedIndex;

  WatchlistProvider(this._storage) {
    _loadFromStorage();
  }

  void _loadFromStorage() {
    _watchlist = _storage.getWatchlist();
    _watched = _storage.getWatchedMovies();
    notifyListeners();
  }

  List<int> get watchlist => List.unmodifiable(_watchlist);
  List<int> get watched => List.unmodifiable(_watched);

  bool isWatchlisted(int movieId) => _watchlist.contains(movieId);
  bool isWatched(int movieId) => _watched.contains(movieId);

  Future<void> toggleWatchlist(int movieId) async {
    if (_watchlist.contains(movieId)) {
      await removeFromWatchlist(movieId);
    } else {
      await addToWatchlist(movieId);
    }
  }

  Future<void> addToWatchlist(int movieId) async {
    if (!_watchlist.contains(movieId)) {
      _watchlist.insert(0, movieId);
      await _storage.saveWatchlist(_watchlist);
      notifyListeners();
    }
  }

  Future<void> removeFromWatchlist(int movieId) async {
    final index = _watchlist.indexOf(movieId);
    if (index != -1) {
      _lastRemovedId = movieId;
      _lastRemovedIndex = index;
      _watchlist.removeAt(index);
      await _storage.saveWatchlist(_watchlist);
      notifyListeners();
    }
  }

  Future<bool> undoRemove() async {
    if (_lastRemovedId != null) {
      final id = _lastRemovedId!;
      final index = _lastRemovedIndex ?? 0;
      if (index >= 0 && index <= _watchlist.length) {
        _watchlist.insert(index, id);
      } else {
        _watchlist.add(id);
      }
      _lastRemovedId = null;
      _lastRemovedIndex = null;
      await _storage.saveWatchlist(_watchlist);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> toggleWatched(int movieId) async {
    if (_watched.contains(movieId)) {
      _watched.remove(movieId);
    } else {
      _watched.add(movieId);
      // If watched, remove from un-watched watchlist if preferred
    }
    await _storage.saveWatchedMovies(_watched);
    notifyListeners();
  }
}
