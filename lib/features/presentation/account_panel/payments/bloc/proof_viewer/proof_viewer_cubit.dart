import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_crm/core/utils/inquiry_media_service.dart';

import 'proof_viewer_state.dart';

/// Loads a payment-proof file for the in-app viewer. Image proofs are fetched
/// (with the inquiry Bearer token) and held as bytes so the UI can zoom them;
/// non-image proofs (e.g. PDF) are flagged [ProofViewerStatus.unsupported] so
/// the viewer can offer an "open externally" fallback.
class ProofViewerCubit extends Cubit<ProofViewerState> {
  ProofViewerCubit({
    required this.url,
    required this.fileName,
    this.mimeType,
  }) : super(const ProofViewerState());

  final String url;
  final String fileName;
  final String? mimeType;

  Future<void> load() async {
    if (url.trim().isEmpty) {
      emit(state.copyWith(
        status: ProofViewerStatus.failure,
        errorMessage: 'No proof file is attached.',
      ));
      return;
    }

    if (!_isImage) {
      emit(state.copyWith(status: ProofViewerStatus.unsupported));
      return;
    }

    emit(state.copyWith(status: ProofViewerStatus.loading));
    try {
      final bytes = await fetchInquiryMediaBytes(url);
      emit(state.copyWith(status: ProofViewerStatus.image, bytes: bytes));
    } catch (e) {
      emit(state.copyWith(
        status: ProofViewerStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Opens the proof in the OS/browser viewer — used for non-image proofs and
  /// as a "download / open" affordance for images.
  Future<void> openExternally() => viewInquiryMediaFile(
        mediaPathOrUrl: url,
        fileName: fileName,
        mimeType: mimeType,
      );

  bool get _isImage {
    final type = mimeType?.trim().toLowerCase() ?? '';
    if (type.startsWith('image/')) return true;
    if (type.isNotEmpty) return false;
    // Fall back to the file/url extension when no mime type is known.
    final lower = (fileName.isNotEmpty ? fileName : url).toLowerCase();
    return RegExp(r'\.(png|jpe?g|gif|webp|bmp|heic)(\?|$)').hasMatch(lower);
  }
}
