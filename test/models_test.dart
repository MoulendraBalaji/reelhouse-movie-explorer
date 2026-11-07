import 'package:flutter_test/flutter_test.dart';
import 'package:reelhouse/models/movie.dart';
import 'package:reelhouse/models/cast_member.dart';
import 'package:reelhouse/models/review.dart';
import 'package:reelhouse/models/user_profile.dart';

void main() {
  group('Data Models Unit Tests', () {
    test('CastMember fromJson and toJson serialization', () {
      final json = {
        'name': 'Cillian Murphy',
        'character': 'J. Robert Oppenheimer',
        'profile_path': '/path.jpg',
      };
      final member = CastMember.fromJson(json);
      expect(member.name, 'Cillian Murphy');
      expect(member.character, 'J. Robert Oppenheimer');
      expect(member.profilePath, '/path.jpg');
      expect(member.toJson(), json);
    });

    test('Movie fromJson and runtime formatting', () {
      final json = {
        'id': 101,
        'title': 'Casablanca',
        'tagline': 'They have a date with fate.',
        'year': 1942,
        'release_date': '1942-11-26',
        'genres': ['Drama', 'Romance'],
        'rating': 8.5,
        'runtime': 102,
        'overview': 'Classic WWII drama in French Morocco.',
        'director': 'Michael Curtiz',
        'poster_url': 'https://image.tmdb.org/t/p/w500/casablanca.jpg',
        'backdrop_url': 'https://image.tmdb.org/t/p/original/casablanca_bg.jpg',
        'trailer_key': 'trailer123',
        'category': 'top_rated',
      };

      final movie = Movie.fromJson(json);
      expect(movie.id, 101);
      expect(movie.title, 'Casablanca');
      expect(movie.formattedRuntime, '1h 42m');
      expect(movie.genres, contains('Romance'));
      expect(movie.rating, 8.5);
    });

    test('Review fromJson and toJson serialization', () {
      final now = DateTime.now();
      final review = Review(
        id: 'rev_1',
        movieId: 101,
        userName: 'Arthur Vance',
        rating: 5.0,
        comment: 'Masterpiece of American cinema storytelling.',
        createdAt: now,
      );

      final json = review.toJson();
      final reconstructed = Review.fromJson(json);

      expect(reconstructed.id, 'rev_1');
      expect(reconstructed.movieId, 101);
      expect(reconstructed.userName, 'Arthur Vance');
      expect(reconstructed.rating, 5.0);
    });

    test('UserProfile copyWith updates specific fields', () {
      const user = UserProfile(
        name: 'Arthur Pendelton',
        email: 'archivist@reelhouse.cinema',
        bio: 'Projectionist apprentice.',
        memberSince: '1974',
        favoriteGenre: 'Sci-Fi',
      );

      final updated = user.copyWith(favoriteGenre: 'Film Noir');
      expect(updated.name, 'Arthur Pendelton');
      expect(updated.favoriteGenre, 'Film Noir');
    });
  });
}
