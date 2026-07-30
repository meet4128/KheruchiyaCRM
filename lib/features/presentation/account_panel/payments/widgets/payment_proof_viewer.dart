import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_crm/core/theme/app_theme.dart';
import 'package:travel_crm/core/utils/snackbar_utils.dart';

import '../bloc/proof_viewer/proof_viewer_cubit.dart';
import '../bloc/proof_viewer/proof_viewer_state.dart';

/// Opens the payment proof in a full-screen, zoomable viewer.
///
/// Image proofs render inline with pinch / double-tap / button zoom; non-image
/// proofs (e.g. PDF) offer an "open externally" fallback.
Future<void> showPaymentProofViewer(
  BuildContext context, {
  required String url,
  String? fileName,
  String? mimeType,
}) {
  final resolvedName = (fileName != null && fileName.trim().isNotEmpty)
      ? fileName.trim()
      : _fileNameFromUrl(url);

  return showDialog<void>(
    context: context,
    barrierColor: Colors.black87,
    builder: (_) => BlocProvider(
      create: (_) => ProofViewerCubit(
        url: url,
        fileName: resolvedName,
        mimeType: mimeType,
      )..load(),
      child: _PaymentProofViewerDialog(fileName: resolvedName),
    ),
  );
}

String _fileNameFromUrl(String url) {
  final path = Uri.tryParse(url)?.path ?? url;
  final segment = path.split('/').where((s) => s.isNotEmpty).lastOrNull;
  if (segment == null || segment.isEmpty) return 'Payment proof';
  return Uri.decodeComponent(segment);
}

class _PaymentProofViewerDialog extends StatelessWidget {
  const _PaymentProofViewerDialog({required this.fileName});

  final String fileName;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      backgroundColor: Colors.black,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.85,
        child: Column(
          children: [
            _Header(fileName: fileName),
            const Divider(height: 1, color: Colors.white24),
            const Expanded(child: _Body()),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.fileName});

  final String fileName;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      child: Row(
        children: [
          const Icon(Icons.receipt_long_outlined, color: Colors.white70, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              fileName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
          IconButton(
            tooltip: 'Open externally',
            icon: const Icon(Icons.open_in_new, color: Colors.white70, size: 20),
            onPressed: () => _openExternally(context),
          ),
          IconButton(
            tooltip: 'Close',
            icon: const Icon(Icons.close, color: Colors.white, size: 22),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Future<void> _openExternally(BuildContext context) async {
    try {
      await context.read<ProofViewerCubit>().openExternally();
    } catch (e) {
      if (context.mounted) {
        SnackBarUtils.showError(context, 'Could not open the proof: $e');
      }
    }
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProofViewerCubit, ProofViewerState>(
      builder: (context, state) {
        switch (state.status) {
          case ProofViewerStatus.loading:
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          case ProofViewerStatus.failure:
            return _Message(
              icon: Icons.error_outline,
              title: 'Could not load proof',
              message: state.errorMessage ?? 'Something went wrong.',
              actionLabel: 'Retry',
              onAction: () => context.read<ProofViewerCubit>().load(),
            );
          case ProofViewerStatus.unsupported:
            return _Message(
              icon: Icons.picture_as_pdf_outlined,
              title: 'Preview not available',
              message:
                  'This proof is not an image. Open it externally to view or '
                  'download the file.',
              actionLabel: 'Open externally',
              onAction: () => _openExternally(context),
            );
          case ProofViewerStatus.image:
            return _ZoomableImage(bytes: state.bytes!);
        }
      },
    );
  }

  Future<void> _openExternally(BuildContext context) async {
    try {
      await context.read<ProofViewerCubit>().openExternally();
    } catch (e) {
      if (context.mounted) {
        SnackBarUtils.showError(context, 'Could not open the proof: $e');
      }
    }
  }
}

/// Pinch / double-tap / button zoom over the proof image.
class _ZoomableImage extends StatefulWidget {
  const _ZoomableImage({required this.bytes});

  final Uint8List bytes;

  @override
  State<_ZoomableImage> createState() => _ZoomableImageState();
}

class _ZoomableImageState extends State<_ZoomableImage> {
  final _controller = TransformationController();
  TapDownDetails? _doubleTapDetails;

  static const _minScale = 1.0;
  static const _maxScale = 5.0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double get _currentScale => _controller.value.getMaxScaleOnAxis();

  void _zoomBy(double factor) {
    final target = (_currentScale * factor).clamp(_minScale, _maxScale);
    _animateTo(Matrix4.identity()..scaleByDouble(target, target, target, 1));
  }

  void _reset() => _animateTo(Matrix4.identity());

  void _handleDoubleTap() {
    if (_currentScale > _minScale + 0.01) {
      _reset();
      return;
    }
    final position = _doubleTapDetails?.localPosition;
    final matrix = Matrix4.identity();
    if (position != null) {
      const scale = 2.5;
      matrix
        ..translateByDouble(
            -position.dx * (scale - 1), -position.dy * (scale - 1), 0, 1)
        ..scaleByDouble(scale, scale, scale, 1);
    } else {
      matrix.scaleByDouble(2.5, 2.5, 2.5, 1);
    }
    _animateTo(matrix);
  }

  void _animateTo(Matrix4 target) {
    // Simple set — InteractiveViewer clamps within bounds on the next gesture.
    _controller.value = target;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onDoubleTapDown: (d) => _doubleTapDetails = d,
            onDoubleTap: _handleDoubleTap,
            child: InteractiveViewer(
              transformationController: _controller,
              minScale: _minScale,
              maxScale: _maxScale,
              child: Center(
                child: Image.memory(
                  widget.bytes,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const _Message(
                    icon: Icons.broken_image_outlined,
                    title: 'Cannot display image',
                    message: 'The proof file could not be rendered.',
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          right: 12,
          bottom: 12,
          child: _ZoomControls(
            onZoomIn: () => _zoomBy(1.4),
            onZoomOut: () => _zoomBy(1 / 1.4),
            onReset: _reset,
          ),
        ),
      ],
    );
  }
}

class _ZoomControls extends StatelessWidget {
  const _ZoomControls({
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onReset,
  });

  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ZoomButton(icon: Icons.remove, tooltip: 'Zoom out', onTap: onZoomOut),
          _ZoomButton(
              icon: Icons.center_focus_strong, tooltip: 'Reset', onTap: onReset),
          _ZoomButton(icon: Icons.add, tooltip: 'Zoom in', onTap: onZoomIn),
        ],
      ),
    );
  }
}

class _ZoomButton extends StatelessWidget {
  const _ZoomButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      icon: Icon(icon, color: Colors.white, size: 20),
      onPressed: onTap,
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final textStyles = AppTheme.textStyles(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 44, color: Colors.white54),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: textStyles.heading5.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: textStyles.bodySmall.copyWith(color: Colors.white70),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: onAction,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white38),
                ),
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
