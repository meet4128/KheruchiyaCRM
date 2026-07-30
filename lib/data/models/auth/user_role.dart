/// Typed view over the backend's `user.role` string returned by `/auth/login`
/// (and `/auth/me`, `/refresh-token`). The persisted value in
/// `SharedPrefUtilsKeys.userRole` is intentionally still a lowercase string
/// so the existing `globalRedirect` role comparison (`_sessionRole()` →
/// `landingPathForRole`) keeps working; new call sites should funnel through
/// [UserRoleX.fromString].
enum UserRole {
  admin,
  sales,
  purchase,
  account,
  user,

  /// Anything the server returned that we don't recognise. Routed defensively
  /// to the dashboard (`/`) by `landingPathForRole`.
  unknown,
}

extension UserRoleX on UserRole {
  /// Parse the raw role string returned by the API. Trims + lowercases before
  /// matching; returns [UserRole.unknown] for any unrecognised value so the
  /// app never bricks if the backend introduces a new role.
  static UserRole fromString(String? value) {
    switch ((value ?? '').trim().toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'sales':
        return UserRole.sales;
      case 'purchase':
        return UserRole.purchase;
      case 'account':
        return UserRole.account;
      case 'user':
        return UserRole.user;
      default:
        return UserRole.unknown;
    }
  }

  /// Lowercase wire-format value (what the backend sends + what we persist).
  String get wireValue {
    switch (this) {
      case UserRole.admin:
        return 'admin';
      case UserRole.sales:
        return 'sales';
      case UserRole.purchase:
        return 'purchase';
      case UserRole.account:
        return 'account';
      case UserRole.user:
        return 'user';
      case UserRole.unknown:
        return '';
    }
  }

  bool get isAdmin => this == UserRole.admin;
}
