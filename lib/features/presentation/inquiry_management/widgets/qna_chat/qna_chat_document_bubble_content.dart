import 'package:flutter/material.dart';
import 'package:travel_crm/core/constants/color_constants.dart';
import 'package:travel_crm/core/constants/dimension_constant.dart';
import 'package:travel_crm/core/constants/font_constant.dart';
import 'package:travel_crm/core/constants/string_constants.dart';
import 'package:travel_crm/core/utils/inquiry_media_service.dart';
import 'package:travel_crm/features/presentation/inquiry_management/models/qna_chat_message.dart';

/// Document row inside [QnaChatBubble] — view / download with auth via [InquiryMediaService].
class QnaChatDocumentBubbleContent extends StatefulWidget {
  const QnaChatDocumentBubbleContent({super.key, required this.message});

  final QnaChatMessage message;

  @override
  State<QnaChatDocumentBubbleContent> createState() =>
      _QnaChatDocumentBubbleContentState();
}

class _QnaChatDocumentBubbleContentState extends State<QnaChatDocumentBubbleContent> {
  bool _busy = false;

  String? get _mediaPath => widget.message.mediaUrl;

  Future<void> _view() async {
    final path = _mediaPath;
    if (path == null || path.isEmpty) return;
    setState(() => _busy = true);
    try {
      await viewInquiryMediaFile(
        mediaPathOrUrl: path,
        fileName: widget.message.fileName ?? 'document',
        mimeType: widget.message.mimeType,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _download() async {
    final path = _mediaPath;
    if (path == null || path.isEmpty) return;
    setState(() => _busy = true);
    try {
      await downloadInquiryMediaFile(
        mediaPathOrUrl: path,
        fileName: widget.message.fileName ?? 'document',
        mimeType: widget.message.mimeType,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fileName = widget.message.fileName ?? 'Document';
    final caption = widget.message.caption;
    final canAct = widget.message.hasMedia && !_busy;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.insert_drive_file_outlined,
              color: ColorConstant.whiteColor.withValues(alpha: 0.85),
              size: DimensionConstant.d20,
            ),
            const SizedBox(width: DimensionConstant.d10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fileName,
                    style: FontConstant.interMedium(
                      color: ColorConstant.whiteColor,
                      fontSize: DimensionConstant.d12,
                    ),
                  ),
                  if (caption != null && caption.isNotEmpty) ...[
                    const SizedBox(height: DimensionConstant.d4),
                    Text(
                      caption,
                      style: FontConstant.interNormal(
                        color: ColorConstant.whiteColor.withValues(alpha: 0.75),
                        fontSize: DimensionConstant.d12,
                        height: 1.35,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        if (_busy)
          const Padding(
            padding: EdgeInsets.only(top: DimensionConstant.d8),
            child: LinearProgressIndicator(minHeight: 2),
          )
        else if (widget.message.hasMedia)
          Padding(
            padding: const EdgeInsets.only(top: DimensionConstant.d10),
            child: Row(
              children: [
                _ActionChip(
                  label: StringConstant.qnaChatViewDocument,
                  onTap: canAct ? _view : null,
                ),
                const SizedBox(width: DimensionConstant.d8),
                _ActionChip(
                  label: StringConstant.qnaChatDownloadDocument,
                  onTap: canAct ? _download : null,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DimensionConstant.d4),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: DimensionConstant.d10,
            vertical: DimensionConstant.d6,
          ),
          decoration: BoxDecoration(
            border: Border.all(color: ColorConstant.whiteColor.withValues(alpha: 0.35)),
            borderRadius: BorderRadius.circular(DimensionConstant.d4),
          ),
          child: Text(
            label,
            style: FontConstant.interMedium(
              color: onTap != null
                  ? ColorConstant.whiteColor
                  : ColorConstant.whiteColor.withValues(alpha: 0.4),
              fontSize: DimensionConstant.d12,
            ),
          ),
        ),
      ),
    );
  }
}
