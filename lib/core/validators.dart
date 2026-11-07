// CONCEPT: Forms & Validation
// Centralized validators for Login, Sign-up, Reviews, Profile, and Contact forms.

class CinemaValidators {
  CinemaValidators._();

  static final RegExp _emailRegExp = RegExp(
    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
  );

  /// Validates full name or display name.
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Film patron name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  /// Validates email address format with strict regex.
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email address is required';
    }
    if (!_emailRegExp.hasMatch(value.trim())) {
      return 'Please enter a valid cinema dispatch email';
    }
    return null;
  }

  /// Validates password (min 8 chars, at least one number).
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Passcode is required to enter projection room';
    }
    if (value.length < 8) {
      return 'Passcode must be at least 8 characters';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Passcode must contain at least one digit [0-9]';
    }
    return null;
  }

  /// Validates password confirmation matches original.
  static String? validateConfirmPassword(String? value, String originalPassword) {
    if (value == null || value.isEmpty) {
      return 'Please re-type your passcode';
    }
    if (value != originalPassword) {
      return 'Passcodes do not match';
    }
    return null;
  }

  /// Validates review rating selection (1 to 5 reels).
  static String? validateRating(double rating) {
    if (rating <= 0.0) {
      return 'Please turn at least one reel (1-5 rating)';
    }
    return null;
  }

  /// Validates user review body (10 to 500 characters).
  static String? validateReviewText(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please write your cinema critique';
    }
    final length = value.trim().length;
    if (length < 10) {
      return 'Critique must be at least 10 characters ($length/10)';
    }
    if (length > 500) {
      return 'Critique cannot exceed 500 characters ($length/500)';
    }
    return null;
  }

  /// Validates contact / feedback form message.
  static String? validateFeedbackMessage(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Feedback message cannot be empty';
    }
    if (value.trim().length < 10) {
      return 'Message must be at least 10 characters';
    }
    return null;
  }
}
