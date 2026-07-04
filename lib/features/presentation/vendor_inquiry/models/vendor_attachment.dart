import 'dart:typed_data';

import 'package:equatable/equatable.dart';

/// A file picked for a vendor attachment (Visiting Card / QR).
/// Holds the display [fileName] plus the raw [bytes] (web) and/or [path]
/// (mobile/desktop) so it can later be uploaded to the backend.
class VendorAttachment extends Equatable {
  const VendorAttachment({
    required this.fileName,
    this.bytes,
    this.path,
  });

  final String fileName;
  final Uint8List? bytes;
  final String? path;

  @override
  List<Object?> get props => [fileName, bytes, path];
}
