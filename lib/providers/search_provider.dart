// CONCEPT: State Management with Provider
// Live debounced search (400ms) with local history caching.

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../data/local_storage_service.dart';
import '../data/movie_repository.dart';
import '../models/movie.dart';

class SearchProvider extends ChangeNotifier {
  final MovieRepository _repository;
  final LocalStorageService _storage;

  String _query = '';
  List<Movie> _results = [];
  bool _isLoading = false;
  List<String> _recentSearches = [];
  Timer? _debounceTimer;

  SearchProvider(this._repository, this._storage) {
    _recentSearches = _storage.getRecentSearches();
  }

  String get query => _query;
  List<Movie> get results => _results;
  bool get isLoading => _isLoading;
  List<String> get recentSearches => _recentSearches;

  void onQueryChanged(String newQuery) {
    _query = newQuery;
    _debounceTimer?.cancel();

    if (newQuery.trim().isEmpty) {
      _results = [];
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      _executeSearch(newQuery);
    });
  }

  Future<void> _executeSearch(String query) async {
    try {
      final res = await _repository.searchMovies(query);
      _results = res;
      _isLoading = false;
      _addRecent(query);
      notifyListeners();
    } catch (_) {
      _results = [];
      _isLoading = false;
      notifyListeners();
    }
  }

  void _addRecent(String query) {
    final clean = query.trim();
    if (clean.isEmpty) return;
    _recentSearches.remove(clean);
    _recentSearches.insert(0, clean);
    if (_recentSearches.length > 8) {
      _recentSearches = _recentSearches.sublist(0, 8);
    }
    _storage.saveRecentSearches(_recentSearches);
  }

  void removeRecent(String item) {
    _recentSearches.remove(item);
    _storage.saveRecentSearches(_recentSearches);
    notifyListeners();
  }

  void clearRecent() {
    _recentSearches.clear();
    _storage.saveRecentSearches(_recentSearches);
    notifyListeners();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
