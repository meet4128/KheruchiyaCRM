class Apis {
  /// base api live
  static const baseUrl = 'https://test.mixergy.io/api/v2';
  static const graphqlBaseurl = 'https://test.mixergy.io/api/';
  static const baseUrlConfig = 'https://bacancy-dev.mixsrvr.co.uk/config';

  /// Base URL for Create Inquiry API (Node server on same Mac, port 5001).
  /// - Same Mac / iOS Simulator / Flutter web: localhost works.
  /// - Android Emulator: use 'http://10.0.2.2:5001' to reach host Mac.
  /// - Physical device: use your Mac's LAN IP, e.g. 'http://192.168.1.x:5001'.
  static const String inquiryBaseUrl = 'http://localhost:5001';

  /// Public URL for WhatsApp / Meta document fetch (ngrok in dev).
  static const String whatsappPublicBaseUrl =
      'https://determinatively-volumetric-sloane.ngrok-free.dev';

  /// Inquiry server auth (no Authorization header)
  static const String inquiryAuthLoginPath = '/api/v1/auth/login';
  static const String inquiryAuthRefreshTokenPath = '/api/v1/auth/refresh-token';

  /// Public password / invite flows (no Authorization header).
  /// All four endpoints below are whitelisted in [DioClient._needsAuth].
  static const String inquiryAuthForgotPasswordPath = '/api/v1/auth/forgot-password';
  static const String inquiryAuthTokenValidatePath = '/api/v1/auth/token/validate';
  static const String inquiryAuthSetPasswordPath = '/api/v1/auth/set-password';
  static const String inquiryAuthResetPasswordPath = '/api/v1/auth/reset-password';

  /// Members CRUD (same inquiry host as [inquiryBaseUrl]).
  static const String membersPath = '/api/v1/members';

  /// Authed admin endpoint for re-issuing an invite token + email.
  /// Path uses `{id}` placeholder for the member's `_id`.
  static const String membersResendInvitePathTemplate =
      '/api/v1/members/{id}/invitations/resend';

  // static const baseUrl = 'https://bacancy-dev.mixsrvr.co.uk/api/v2';

  /// list of all other apis
  static const login = '$baseUrl/account/login';
  static const forgotPassword = '$baseUrl/account/unauthenticated/passwordreset';
  /// Refresh access token using refresh token (no Authorization header).
  static const refreshTokenUrl = '$baseUrl/account/refresh';
}