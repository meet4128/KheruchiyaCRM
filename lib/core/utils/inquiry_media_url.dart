import 'package:travel_crm/core/network/apis.dart';

/// Full URL for session/amendment media paths served by the inquiry API host.
///
/// Example path: `/uploads/amendments/inbound/{inquiryId}/{sessionId}/file.pdf`
String buildInquiryMediaUrl(String mediaPath) {
  final trimmed = mediaPath.trim();
  if (trimmed.isEmpty) return trimmed;
  if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
    return trimmed;
  }
  final base = Apis.inquiryHost.replaceAll(RegExp(r'/$'), '');
  final path = trimmed.startsWith('/') ? trimmed : '/$trimmed';
  return '$base$path';
}
