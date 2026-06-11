class Apis {
  /// Third-party airport search (no CORS on web — use [inquirySearchAirportsUrl] there).
  static const String airportRoutesHost = 'https://www.airportroutes.com';
  static const String airportRoutesSearchPath = '/api/search-airports/';
  static const String airportRoutesSearchUrl =
      '$airportRoutesHost$airportRoutesSearchPath';

  /// Inquiry API proxy for airport search (same-origin on web; forwards to airportroutes).
  static const String inquirySearchAirportsPath = '/reference/search-airports/';

  /// Production site origin (uploads / public media — not under `/api/v1`).
  static const String inquiryHost = 'https://kheruchiyagroup.com';

  /// Inquiry CRM API root — Dio + Retrofit paths are relative to this (no `/api/v1` prefix).
  static const String inquiryBaseUrl = '$inquiryHost/api/v1';

  /// Public URL for WhatsApp / Meta document fetch (same origin as [inquiryHost]).
  static const String whatsappPublicBaseUrl = inquiryHost;

  /// Inquiry server auth (no Authorization header). Paths relative to [inquiryBaseUrl].
  static const String inquiryAuthLoginPath = '/auth/login';
  static const String inquiryAuthRefreshTokenPath = '/auth/refresh-token';

  /// Public password / invite flows (no Authorization header).
  /// All four endpoints below are whitelisted in [DioClient._needsAuth].
  static const String inquiryAuthForgotPasswordPath = '/auth/forgot-password';
  static const String inquiryAuthTokenValidatePath = '/auth/token/validate';
  static const String inquiryAuthSetPasswordPath = '/auth/set-password';
  static const String inquiryAuthResetPasswordPath = '/auth/reset-password';

  /// Members CRUD (same inquiry host as [inquiryBaseUrl]).
  static const String membersPath = '/members';

  /// Authed admin endpoint for re-issuing an invite token + email.
  /// Path uses `{id}` placeholder for the member's `_id`.
  static const String membersResendInvitePathTemplate =
      '/members/{id}/invitations/resend';
}
