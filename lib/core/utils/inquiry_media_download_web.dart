import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

void viewBytesInBrowser(Uint8List bytes, String mimeType) {
  final blob = web.Blob(
    <JSUint8Array>[bytes.toJS].toJS,
    web.BlobPropertyBag(type: mimeType),
  );
  final url = web.URL.createObjectURL(blob);
  web.window.open(url, '_blank');
  web.URL.revokeObjectURL(url);
}

Future<void> downloadBytes(Uint8List bytes, String fileName, String mimeType) async {
  final blob = web.Blob(
    <JSUint8Array>[bytes.toJS].toJS,
    web.BlobPropertyBag(type: mimeType),
  );
  final url = web.URL.createObjectURL(blob);
  final anchor = web.document.createElement('a') as web.HTMLAnchorElement
    ..href = url
    ..download = fileName
    ..style.display = 'none';
  web.document.body?.appendChild(anchor);
  anchor.click();
  anchor.remove();
  web.URL.revokeObjectURL(url);
}

Future<void> saveAndOpenBytes(
  Uint8List bytes,
  String fileName,
  String mimeType,
) async {
  viewBytesInBrowser(bytes, mimeType);
}
