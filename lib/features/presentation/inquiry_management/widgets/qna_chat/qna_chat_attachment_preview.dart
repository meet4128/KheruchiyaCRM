import 'package:flutter/material.dart';
import 'package:travel_crm/core/constants/color_constants.dart';
import 'package:travel_crm/core/constants/dimension_constant.dart';
import 'package:travel_crm/core/constants/font_constant.dart';
import 'package:travel_crm/core/constants/string_constants.dart';

/// Staged file row above the composer (shown after + pick, before send).
class QnaChatAttachmentPreview extends StatelessWidget {
  const QnaChatAttachmentPreview({
    super.key,
    required this.fileName,
    required this.onClear,
  });

  final String fileName;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: DimensionConstant.d8),
      padding: const EdgeInsets.symmetric(
        horizontal: DimensionConstant.d10,
        vertical: DimensionConstant.d8,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(DimensionConstant.d8),
        border: Border.all(color: ColorConstant.borderColorWhite30),
      ),
      child: Row(
        children: [
          Icon(
            Icons.insert_drive_file_outlined,
            size: DimensionConstant.d18,
            color: ColorConstant.whiteColor.withValues(alpha: 0.85),
          ),
          const SizedBox(width: DimensionConstant.d8),
          Expanded(
            child: Text(
              fileName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: FontConstant.interMedium(
                color: ColorConstant.whiteColor,
                fontSize: DimensionConstant.d12,
              ),
            ),
          ),
          IconButton(
            onPressed: onClear,
            icon: Icon(
              Icons.close,
              size: DimensionConstant.d18,
              color: ColorConstant.whiteColor.withValues(alpha: 0.75),
            ),
            tooltip: StringConstant.qnaChatRemoveAttachment,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: DimensionConstant.d32,
              minHeight: DimensionConstant.d32,
            ),
          ),
        ],
      ),
    );
  }
}
