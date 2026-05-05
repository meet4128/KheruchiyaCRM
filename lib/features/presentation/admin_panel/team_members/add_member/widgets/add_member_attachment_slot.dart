import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_crm/core/constants/string_constants.dart';
import 'package:travel_crm/core/theme/app_colors.dart';
import 'package:travel_crm/features/presentation/admin_panel/team_members/add_member/bloc/add_member_bloc.dart';
import 'package:travel_crm/features/presentation/admin_panel/team_members/add_member/bloc/add_member_event.dart';
import 'package:travel_crm/features/presentation/admin_panel/team_members/add_member/bloc/add_member_state.dart';

/// Single document slot ([add_member_submit.md] Phase 4).
class AddMemberAttachmentSlot extends StatelessWidget {
  const AddMemberAttachmentSlot({
    super.key,
    required this.kind,
    required this.label,
    required this.attachment,
    required this.enabled,
  });

  final AddMemberAttachmentKind kind;
  final String label;
  final AddMemberAttachment? attachment;
  final bool enabled;

  Future<void> _pick(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );
    if (!context.mounted) return;
    if (result == null || result.files.isEmpty) return;
    final f = result.files.single;
    context.read<AddMemberBloc>().add(
          AddMemberAttachmentPicked(
            kind: kind,
            fileName: f.name,
            path: f.path,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.dark();
    final hasFile = attachment != null && attachment!.fileName.isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? () => _pick(context) : null,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: BoxDecoration(
            color: colors.inputBackground,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: colors.inputBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: colors.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    hasFile ? Icons.insert_drive_file_outlined : Icons.attach_file,
                    color: colors.textSecondary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      hasFile ? attachment!.fileName : StringConstant.addMemberAttachmentPickHint,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: hasFile ? colors.textPrimary : colors.textTertiary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  if (hasFile && enabled)
                    IconButton(
                      tooltip: MaterialLocalizations.of(context).deleteButtonTooltip,
                      onPressed: () {
                        context.read<AddMemberBloc>().add(AddMemberAttachmentCleared(kind));
                      },
                      icon: Icon(Icons.delete_outline, color: colors.error, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
