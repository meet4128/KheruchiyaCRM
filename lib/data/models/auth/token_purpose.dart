/// Discriminator for the `purpose` query/body field of token-based auth
/// endpoints. Used by `validateToken`, `setPassword`, and `resetPassword`.
enum TokenPurpose {
  invite,
  reset,
}

extension TokenPurposeX on TokenPurpose {
  /// Wire value matching the backend contract — lowercase singular.
  String get wireValue {
    switch (this) {
      case TokenPurpose.invite:
        return 'invite';
      case TokenPurpose.reset:
        return 'reset';
    }
  }
}
