import '../models/movie.dart';

abstract class MovieRepository {
  Future<List<Movie>> getNowShowing();
  Future<List<Movie>> getTrending();
  Future<List<Movie>> getTopRated();
  Future<List<Movie>> getComingSoon();
  Future<List<Movie>> getAllMovies();
  Future<Movie?> getMovieById(int id);
  Future<List<Movie>> searchMovies(String query);

  /// Indicates whether the repository is serving from the local offline reel archive.
  bool get isOfflineSource;
}
