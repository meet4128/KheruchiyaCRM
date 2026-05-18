import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:travel_crm/core/utils/inquiry_media_url.dart';
import 'package:travel_crm/core/utils/shared_pref_utils.dart';

import 'inquiry_media_download_stub.dart'
    if (dart.library.html) 'inquiry_media_download_web.dart' as platform_download;

/// Fetches amendment/session media with the same Bearer token as other inquiry APIs.
Future<Uint8List> fetchInquiryMediaBytes(String mediaPathOrUrl) async {
  final url = buildInquiryMediaUrl(mediaPathOrUrl);
  final token =
      SharedPrefUtils.getValue(SharedPrefUtilsKeys.userToken, '').toString().trim();

  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
    ),
  );

  final response = await dio.get<List<int>>(
    url,
    options: Options(
      responseType: ResponseType.bytes,
      headers: token.isNotEmpty ? {'Authorization': 'Bearer $token'} : null,
    ),
  );

  final data = response.data;
  if (data == null || data.isEmpty) {
    throw Exception('File is empty or could not be downloaded.');
  }
  return Uint8List.fromList(data);
}

/// Opens media in a new tab/window (web) or external viewer where supported.
Future<void> viewInquiryMediaFile({
  required String mediaPathOrUrl,
  required String fileName,
  String? mimeType,
}) async {
  final bytes = await fetchInquiryMediaBytes(mediaPathOrUrl);
  final type = mimeType?.trim().isNotEmpty == true
      ? mimeType!.trim()
      : _guessMimeType(fileName);

  if (kIsWeb) {
    platform_download.viewBytesInBrowser(bytes, type);
    return;
  }

  // Mobile/desktop fallback: data URI via url is not used; use temp file open.
  await platform_download.saveAndOpenBytes(bytes, fileName, type);
}

/// Downloads media to the user's device.
Future<void> downloadInquiryMediaFile({
  required String mediaPathOrUrl,
  required String fileName,
  String? mimeType,
}) async {
  final bytes = await fetchInquiryMediaBytes(mediaPathOrUrl);
  final type = mimeType?.trim().isNotEmpty == true
      ? mimeType!.trim()
      : _guessMimeType(fileName);
  await platform_download.downloadBytes(bytes, fileName, type);
}

String _guessMimeType(String fileName) {
  final lower = fileName.toLowerCase();
  if (lower.endsWith('.pdf')) return 'application/pdf';
  if (lower.endsWith('.png')) return 'image/png';
  if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
  if (lower.endsWith('.doc')) return 'application/msword';
  if (lower.endsWith('.docx')) {
    return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
  }
  return 'application/octet-stream';
}
