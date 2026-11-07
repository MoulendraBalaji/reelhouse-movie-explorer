import 'dart:convert';
import 'package:flutter/services.dart';
import '../core/constants.dart';
import '../models/movie.dart';
import 'movie_repository.dart';

class LocalMovieRepository implements MovieRepository {
  List<Movie>? _cachedMovies;

  @override
  bool get isOfflineSource => true;

  Future<List<Movie>> _loadAll() async {
    if (_cachedMovies != null && _cachedMovies!.isNotEmpty) {
      return _cachedMovies!;
    }
    try {
      final jsonStr = await rootBundle.loadString(CinemaConstants.fallbackMoviesJson);
      final List<dynamic> list = jsonDecode(jsonStr) as List<dynamic>;
      _cachedMovies = list.map((item) => Movie.fromJson(item as Map<String, dynamic>)).toList();
      return _cachedMovies!;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<Movie>> getAllMovies() async {
    return _loadAll();
  }

  @override
  Future<List<Movie>> getNowShowing() async {
    final all = await _loadAll();
    return all.where((m) => m.category == 'now_showing').toList();
  }

  @override
  Future<List<Movie>> getTrending() async {
    final all = await _loadAll();
    return all.where((m) => m.category == 'trending' || m.category == 'now_showing').toList();
  }

  @override
  Future<List<Movie>> getTopRated() async {
    final all = await _loadAll();
    return all.where((m) => m.category == 'top_rated' || m.rating >= 8.3).toList();
  }

  @override
  Future<List<Movie>> getComingSoon() async {
    final all = await _loadAll();
    return all.where((m) => m.category == 'coming_soon').toList();
  }

  @override
  Future<Movie?> getMovieById(int id) async {
    final all = await _loadAll();
    try {
      return all.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Movie>> searchMovies(String query) async {
    final all = await _loadAll();
    if (query.trim().isEmpty) return all;
    final q = query.toLowerCase().trim();
    return all.where((m) {
      final matchTitle = m.title.toLowerCase().contains(q);
      final matchDirector = m.director.toLowerCase().contains(q);
      final matchGenre = m.genres.any((g) => g.toLowerCase().contains(q));
      final matchCast = m.cast.any((c) => c.name.toLowerCase().contains(q));
      return matchTitle || matchDirector || matchGenre || matchCast;
    }).toList();
  }
}
