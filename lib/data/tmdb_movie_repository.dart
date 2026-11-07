import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants.dart';
import '../models/movie.dart';
import 'movie_repository.dart';
import 'local_movie_repository.dart';

class TmdbMovieRepository implements MovieRepository {
  final LocalMovieRepository _fallbackRepo = LocalMovieRepository();
  bool _fallbackActive = false;

  @override
  bool get isOfflineSource => _fallbackActive || CinemaConstants.tmdbApiKey.isEmpty;

  Future<http.Response?> _get(String endpoint, [Map<String, String>? params]) async {
    if (CinemaConstants.tmdbApiKey.isEmpty) {
      _fallbackActive = true;
      return null;
    }
    final uri = Uri.parse('${CinemaConstants.tmdbBaseUrl}$endpoint').replace(
      queryParameters: {
        'api_key': CinemaConstants.tmdbApiKey,
        'language': 'en-US',
        ...?params,
      },
    );
    try {
      final res = await http.get(uri).timeout(const Duration(seconds: 6));
      if (res.statusCode == 200) {
        return res;
      } else {
        _fallbackActive = true;
        return null;
      }
    } catch (_) {
      _fallbackActive = true;
      return null;
    }
  }

  @override
  Future<List<Movie>> getNowShowing() async {
    final res = await _get('/movie/now_playing');
    if (res != null) {
      try {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final results = data['results'] as List<dynamic>? ?? [];
        return results.map((e) => Movie.fromJson(e as Map<String, dynamic>)).toList();
      } catch (_) {
        _fallbackActive = true;
      }
    }
    return _fallbackRepo.getNowShowing();
  }

  @override
  Future<List<Movie>> getTrending() async {
    final res = await _get('/trending/movie/day');
    if (res != null) {
      try {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final results = data['results'] as List<dynamic>? ?? [];
        return results.map((e) => Movie.fromJson(e as Map<String, dynamic>)).toList();
      } catch (_) {
        _fallbackActive = true;
      }
    }
    return _fallbackRepo.getTrending();
  }

  @override
  Future<List<Movie>> getTopRated() async {
    final res = await _get('/movie/top_rated');
    if (res != null) {
      try {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final results = data['results'] as List<dynamic>? ?? [];
        return results.map((e) => Movie.fromJson(e as Map<String, dynamic>)).toList();
      } catch (_) {
        _fallbackActive = true;
      }
    }
    return _fallbackRepo.getTopRated();
  }

  @override
  Future<List<Movie>> getComingSoon() async {
    final res = await _get('/movie/upcoming');
    if (res != null) {
      try {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final results = data['results'] as List<dynamic>? ?? [];
        return results.map((e) => Movie.fromJson(e as Map<String, dynamic>)).toList();
      } catch (_) {
        _fallbackActive = true;
      }
    }
    return _fallbackRepo.getComingSoon();
  }

  @override
  Future<List<Movie>> getAllMovies() async {
    // Aggregates trending and top rated or falls back
    final list = await getTrending();
    if (list.isNotEmpty && !_fallbackActive) {
      final top = await getTopRated();
      final map = {for (var m in list) m.id: m};
      for (var t in top) {
        map[t.id] = t;
      }
      return map.values.toList();
    }
    return _fallbackRepo.getAllMovies();
  }

  @override
  Future<Movie?> getMovieById(int id) async {
    final res = await _get('/movie/$id', {'append_to_response': 'credits,videos'});
    if (res != null) {
      try {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        return Movie.fromJson(data);
      } catch (_) {
        _fallbackActive = true;
      }
    }
    return _fallbackRepo.getMovieById(id);
  }

  @override
  Future<List<Movie>> searchMovies(String query) async {
    if (query.trim().isEmpty) return getAllMovies();
    final res = await _get('/search/movie', {'query': query});
    if (res != null) {
      try {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final results = data['results'] as List<dynamic>? ?? [];
        return results.map((e) => Movie.fromJson(e as Map<String, dynamic>)).toList();
      } catch (_) {
        _fallbackActive = true;
      }
    }
    return _fallbackRepo.searchMovies(query);
  }
}
