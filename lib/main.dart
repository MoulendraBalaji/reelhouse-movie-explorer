// REELHOUSE — Movie Explorer Web Application
// Concept: An old single-screen cinema projection booth. Physical 35mm film aesthetic.

import 'package:flutter/material.dart';
import 'app.dart';
import 'data/local_storage_service.dart';
import 'data/tmdb_movie_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize persistent LocalStorage service (shared_preferences)
  final storage = await LocalStorageService.init();

  // Initialize resilient MovieRepository (TMDB with automatic offline JSON fallback)
  final repository = TmdbMovieRepository();

  runApp(ReelhouseApp(
    storage: storage,
    repository: repository,
  ));
}
