/// Thrown when the server returns 401.
class InquiryUnauthorizedException implements Exception {
  @override
  String toString() => 'Session expired or invalid. Please log in again.';
}

/// Thrown when the server returns 422.
class InquiryValidationException implements Exception {
  InquiryValidationException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Thrown when WhatsApp / upstream returns 502.
class InquiryServiceUnavailableException implements Exception {
  InquiryServiceUnavailableException([this.message = 'WhatsApp service unavailable.']);

  final String message;

  @override
  String toString() => message;
}
