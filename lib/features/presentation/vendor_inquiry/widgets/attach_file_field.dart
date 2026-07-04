import 'package:flutter/material.dart';
import 'package:travel_crm/core/constants/string_constants.dart';
import 'package:travel_crm/core/theme/app_theme.dart';

import '../models/vendor_attachment.dart';

/// Input-styled attachment field.
/// - Empty: shows an upload hint + icon; the whole box is tappable → [onPick].
/// - Filled: shows the file name with a "Remove" action → [onRemove].
///
/// Keeps I/O out of the widget — [onPick] is wired by the screen to run the
/// file picker and dispatch the result to the BLoC.
class AttachFileField extends StatelessWidget {
  const AttachFileField({
    super.key,
    required this.attachment,
    required this.hint,
    required this.onPick,
    required this.onRemove,
    this.errorText,
  });

  final VendorAttachment? attachment;
  final String hint;
  final VoidCallback onPick;
  final VoidCallback onRemove;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);
    final textStyles = AppTheme.textStyles(context);
    final hasFile = attachment != null;
    final borderColor =
        errorText != null ? colors.inputErrorBorder : colors.inputBorder;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: hasFile ? null : onPick,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: colors.inputBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor, width: 1),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      hasFile ? attachment!.fileName : hint,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: hasFile
                          ? textStyles.formInput
                          : textStyles.formHint,
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (hasFile)
                    InkWell(
                      onTap: onRemove,
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 4,
                        ),
                        child: Text(
                          StringConstant.attachmentRemove,
                          style: textStyles.bodySmall.copyWith(
                            color: colors.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                  else
                    Icon(
                      Icons.upload_file_outlined,
                      size: 20,
                      color: colors.textSecondary,
                    ),
                ],
              ),
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Text(
            errorText!,
            style: textStyles.formError,
          ),
        ],
      ],
    );
  }
}
