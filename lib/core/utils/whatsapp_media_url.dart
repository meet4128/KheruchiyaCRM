import 'package:travel_crm/core/network/apis.dart';

/// Builds a public URL for WhatsApp document send ([Apis.inquiryHost] + upload path).
String buildWhatsappMediaUrl(String mediaPath) {
  final trimmed = mediaPath.trim();
  if (trimmed.isEmpty) return trimmed;
  if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
    return trimmed;
  }
  final base = Apis.whatsappPublicBaseUrl.replaceAll(RegExp(r'/$'), '');
  final path = trimmed.startsWith('/') ? trimmed : '/$trimmed';
  return '$base$path';
}
