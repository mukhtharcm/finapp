class ErrorUtils {
  static String getErrorMessage(String error) {
    // Common error messages
    if (error.contains('user-not-found')) {
      return 'No account found with this email';
    }
    if (error.contains('wrong-password')) {
      return 'Incorrect password';
    }
    if (error.contains('email-already-in-use')) {
      return 'An account already exists with this email';
    }
    if (error.contains('weak-password')) {
      return 'Password is too weak';
    }
    if (error.contains('invalid-email')) {
      return 'Invalid email address';
    }
    if (error.contains('network-request-failed')) {
      return 'Network error. Please check your connection';
    }
    if (error.contains('too-many-requests')) {
      return 'Too many attempts. Please try again later';
    }

    // Generic error fallback
    return 'Something went wrong. Please try again';
  }
}
