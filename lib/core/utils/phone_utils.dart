/// Normalizes inquiry phone to E.164 digits only (no +), 10–15 digits.
String? normalizePeerPhoneE164({String? countryCode, String? number}) {
  final cc = countryCode?.replaceAll(RegExp(r'\D'), '') ?? '';
  final nn = number?.replaceAll(RegExp(r'\D'), '') ?? '';
  if (cc.isEmpty && nn.isEmpty) return null;
  final combined = '$cc$nn';
  if (combined.length < 10 || combined.length > 15) return null;
  return combined;
}

String? normalizePeerPhoneRaw(String? raw) {
  if (raw == null) return null;
  final digits = raw.replaceAll(RegExp(r'\D'), '');
  if (digits.length < 10 || digits.length > 15) return null;
  return digits;
}

/// Human-readable phone for inquiry information UI.
String formatPeerPhoneDisplay(String? e164) {
  final digits = e164?.replaceAll(RegExp(r'\D'), '') ?? '';
  if (digits.length < 10) return '—';
  if (digits.length == 12 && digits.startsWith('91')) {
    final local = digits.substring(2);
    if (local.length == 10) {
      return '+91 ${local.substring(0, 5)} ${local.substring(5)}';
    }
  }
  if (digits.length == 10) {
    return '+91 ${digits.substring(0, 5)} ${digits.substring(5)}';
  }
  return '+$digits';
}
