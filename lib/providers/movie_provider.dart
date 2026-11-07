// CONCEPT: State Management with Provider & ChangeNotifier
// Manages movie catalog data, offline fallback detection, and error/retry states.

import 'package:flutter/foundation.dart';
import '../models/movie.dart';
import '../data/movie_repository.dart';

enum MovieLoadingState { initial, loading, loaded, error }

class MovieProvider extends ChangeNotifier {
  final MovieRepository _repository;

  MovieLoadingState _state = MovieLoadingState.initial;
  String? _errorMessage;
  bool _isOffline = true;

  List<Movie> _nowShowing = [];
  List<Movie> _trending = [];
  List<Movie> _topRated = [];
  List<Movie> _comingSoon = [];
  List<Movie> _allMovies = [];

  MovieProvider(this._repository);

  MovieLoadingState get state => _state;
  bool get isLoading => _state == MovieLoadingState.loading;
  bool get isLoaded => _state == MovieLoadingState.loaded;
  bool get hasError => _state == MovieLoadingState.error;
  String? get errorMessage => _errorMessage;
  bool get isOffline => _isOffline;

  List<Movie> get nowShowing => _nowShowing;
  List<Movie> get trending => _trending;
  List<Movie> get topRated => _topRated;
  List<Movie> get comingSoon => _comingSoon;
  List<Movie> get allMovies => _allMovies;

  Future<void> loadCatalog() async {
    _state = MovieLoadingState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final nowShowingFuture = _repository.getNowShowing();
      final trendingFuture = _repository.getTrending();
      final topRatedFuture = _repository.getTopRated();
      final comingSoonFuture = _repository.getComingSoon();
      final allFuture = _repository.getAllMovies();

      final results = await Future.wait([
        nowShowingFuture,
        trendingFuture,
        topRatedFuture,
        comingSoonFuture,
        allFuture,
      ]);

      _nowShowing = results[0];
      _trending = results[1];
      _topRated = results[2];
      _comingSoon = results[3];
      _allMovies = results[4];
      _isOffline = _repository.isOfflineSource;

      _state = MovieLoadingState.loaded;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'The projector spool jammed while loading film reels.';
      _state = MovieLoadingState.error;
      notifyListeners();
    }
  }

  Future<Movie?> getMovieById(int id) async {
    // Check local memory cache first
    for (final m in _allMovies) {
      if (m.id == id) return m;
    }
    return _repository.getMovieById(id);
  }

  void retry() {
    loadCatalog();
  }
}
