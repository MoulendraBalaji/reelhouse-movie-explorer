// CONCEPT: State Management with Provider
// Manages community and user critique reviews per movie with local persistence.

import 'package:flutter/foundation.dart';
import '../data/local_storage_service.dart';
import '../models/review.dart';

class ReviewsProvider extends ChangeNotifier {
  final LocalStorageService _storage;
  List<Review> _reviews = [];

  ReviewsProvider(this._storage) {
    _loadReviews();
  }

  void _loadReviews() {
    final saved = _storage.getReviews();
    if (saved.isNotEmpty) {
      _reviews = saved;
    } else {
      // Seed default reviews for a rich experience
      _reviews = [
        Review(
          id: 'rev_1',
          movieId: 1, // Oppenheimer
          userName: 'Arthur Vance',
          rating: 5.0,
          comment: 'The sound design alone shook the theater walls. Cillian Murphy delivers the performance of a lifetime.',
          createdAt: DateTime.now().subtract(const Duration(days: 4)),
        ),
        Review(
          id: 'rev_2',
          movieId: 1,
          userName: 'Elena Rostova',
          rating: 4.5,
          comment: 'Spectacular tension during the Trinity test sequence. Truly felt like real 70mm celluloid power.',
          createdAt: DateTime.now().subtract(const Duration(days: 12)),
        ),
        Review(
          id: 'rev_3',
          movieId: 2, // Dune: Part Two
          userName: 'Miles Holloway',
          rating: 5.0,
          comment: 'A visual triumph and masterclass in modern science fiction world-building.',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
      ];
    }
    notifyListeners();
  }

  List<Review> getReviewsForMovie(int movieId) {
    return _reviews.where((r) => r.movieId == movieId).toList();
  }

  Future<void> addReview({
    required int movieId,
    required String userName,
    required double rating,
    required String comment,
  }) async {
    final newRev = Review(
      id: 'rev_${DateTime.now().millisecondsSinceEpoch}',
      movieId: movieId,
      userName: userName,
      rating: rating,
      comment: comment,
      createdAt: DateTime.now(),
    );
    _reviews.insert(0, newRev);
    await _storage.saveReviews(_reviews);
    notifyListeners();
  }
}
