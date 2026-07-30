import 'dart:typed_data';

import 'package:equatable/equatable.dart';

/// - [loading]     → fetching the proof bytes (auth'd) is in flight.
/// - [image]       → an image proof was loaded; [bytes] holds it for zooming.
/// - [unsupported] → non-image proof (e.g. PDF); offer "open externally".
/// - [failure]     → fetch failed; [errorMessage] holds the copy.
enum ProofViewerStatus { loading, image, unsupported, failure }

class ProofViewerState extends Equatable {
  const ProofViewerState({
    this.status = ProofViewerStatus.loading,
    this.bytes,
    this.errorMessage,
  });

  final ProofViewerStatus status;
  final Uint8List? bytes;
  final String? errorMessage;

  ProofViewerState copyWith({
    ProofViewerStatus? status,
    Uint8List? bytes,
    String? errorMessage,
  }) {
    return ProofViewerState(
      status: status ?? this.status,
      bytes: bytes ?? this.bytes,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, bytes, errorMessage];
}
