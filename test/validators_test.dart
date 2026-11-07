import 'package:flutter_test/flutter_test.dart';
import 'package:reelhouse/core/validators.dart';

void main() {
  group('CinemaValidators Unit Tests', () {
    test('Name validation checks non-empty and minimum length', () {
      expect(CinemaValidators.validateName(null), isNotNull);
      expect(CinemaValidators.validateName(''), isNotNull);
      expect(CinemaValidators.validateName('A'), isNotNull);
      expect(CinemaValidators.validateName('Christopher Nolan'), isNull);
    });

    test('Email validation enforces regex patterns', () {
      expect(CinemaValidators.validateEmail(null), isNotNull);
      expect(CinemaValidators.validateEmail('invalid-email'), isNotNull);
      expect(CinemaValidators.validateEmail('no-domain@'), isNotNull);
      expect(CinemaValidators.validateEmail('patron@reelhouse.cinema'), isNull);
    });

    test('Password validation enforces min 8 characters and at least one digit', () {
      expect(CinemaValidators.validatePassword(null), isNotNull);
      expect(CinemaValidators.validatePassword('short1'), isNotNull);
      expect(CinemaValidators.validatePassword('allcharactersnodigit'), isNotNull);
      expect(CinemaValidators.validatePassword('projector1934'), isNull);
    });

    test('Confirm password requires exact match', () {
      expect(CinemaValidators.validateConfirmPassword('pass1234', 'pass1234'), isNull);
      expect(CinemaValidators.validateConfirmPassword('pass1234', 'different1234'), isNotNull);
    });

    test('Review rating requires > 0 reels', () {
      expect(CinemaValidators.validateRating(0.0), isNotNull);
      expect(CinemaValidators.validateRating(4.5), isNull);
    });

    test('Review text enforces 10 to 500 characters', () {
      expect(CinemaValidators.validateReviewText(null), isNotNull);
      expect(CinemaValidators.validateReviewText('Too short'), isNotNull);
      expect(CinemaValidators.validateReviewText('A phenomenal 35mm cinematic tour de force.'), isNull);
      expect(CinemaValidators.validateReviewText('A' * 501), isNotNull);
    });
  });
}
