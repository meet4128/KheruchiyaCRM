import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_crm/core/constants/string_constants.dart';
import 'package:travel_crm/core/theme/app_colors.dart';
import 'package:travel_crm/features/presentation/air_ticket/models/checklist_priority.dart';
import 'package:travel_crm/features/presentation/air_ticket/models/checklist_user.dart';
import 'package:travel_crm/features/presentation/air_ticket/widgets/checklist_users_picker_dialog.dart';
import 'package:travel_crm/features/presentation/inquiry_management/bloc/put_follow_up/put_follow_up_bloc.dart';
import 'package:travel_crm/features/presentation/inquiry_management/bloc/put_follow_up/put_follow_up_event.dart';
import 'package:travel_crm/features/presentation/inquiry_management/bloc/put_follow_up/put_follow_up_state.dart';

class FollowUpChecklistBar extends StatelessWidget {
  const FollowUpChecklistBar({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.dark();

    return BlocBuilder<PutFollowUpBloc, PutFollowUpState>(
      buildWhen: (p, c) =>
          p.checklistUsers != c.checklistUsers ||
          p.checklistPriority != c.checklistPriority ||
          p.attachmentFileName != c.attachmentFileName ||
          p.inLoopUsers != c.inLoopUsers,
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.inputBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.borderPrimary.withValues(alpha: 0.45)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                StringConstant.addChecklist,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: colors.backgroundMedium,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colors.borderPrimary.withValues(alpha: 0.35)),
                ),
                child: Row(
                  children: [
                    _ChecklistActionCell(
                      label: StringConstant.user,
                      icon: Icons.person_outline,
                      isActive: state.checklistUsers.isNotEmpty,
                      onTap: () => _openUsersPicker(
                        context,
                        initial: state.checklistUsers,
                        onDone: (users) {
                          context.read<PutFollowUpBloc>().add(
                                PutFollowUpChecklistUsersChanged(
                                  users.map((u) => u.displayName).toList(),
                                ),
                              );
                        },
                      ),
                    ),
                    _divider(colors),
                    _ChecklistActionCell(
                      label: StringConstant.setPriorityHint,
                      icon: Icons.tune,
                      isActive: state.checklistPriority != null,
                      onTap: () => _openPriorityPicker(context, state.checklistPriority),
                    ),
                    _divider(colors),
                    _ChecklistActionCell(
                      label: StringConstant.attachment,
                      icon: Icons.attach_file,
                      isActive: state.attachmentFileName?.trim().isNotEmpty ?? false,
                      onTap: () => _pickAttachment(context),
                    ),
                    _divider(colors),
                    _ChecklistActionCell(
                      label: StringConstant.inLoop,
                      icon: Icons.loop,
                      isActive: state.inLoopUsers.isNotEmpty,
                      onTap: () => _openUsersPicker(
                        context,
                        initial: state.inLoopUsers,
                        onDone: (users) {
                          context.read<PutFollowUpBloc>().add(
                                PutFollowUpInLoopUsersChanged(
                                  users.map((u) => u.displayName).toList(),
                                ),
                              );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _divider(AppColors colors) {
    return Container(
      width: 1,
      height: 28,
      color: colors.borderPrimary.withValues(alpha: 0.35),
    );
  }

  Future<void> _openUsersPicker(
    BuildContext context, {
    required List<String> initial,
    required ValueChanged<List<ChecklistUser>> onDone,
  }) {
    return showChecklistUsersPickerDialog(
      context,
      initialUsers: initial.map(ChecklistUser.fromName).toList(),
      onDone: onDone,
    );
  }

  Future<void> _openPriorityPicker(
    BuildContext context,
    ChecklistPriority? current,
  ) async {
    final colors = AppColors.dark();
    final selected = await showDialog<ChecklistPriority>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: colors.backgroundMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: colors.borderPrimary.withValues(alpha: 0.55)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  StringConstant.setPriorityHint,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              for (final priority in ChecklistPriority.values)
                ListTile(
                  title: Text(
                    priority.displayLabel,
                    style: TextStyle(color: colors.textPrimary),
                  ),
                  trailing: current == priority
                      ? Icon(Icons.check, color: colors.accent)
                      : null,
                  onTap: () => Navigator.pop(ctx, priority),
                ),
            ],
          ),
        ),
      ),
    );

    if (selected != null && context.mounted) {
      context.read<PutFollowUpBloc>().add(PutFollowUpChecklistPriorityChanged(selected));
    }
  }

  Future<void> _pickAttachment(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(withData: false);
    if (!context.mounted) return;
    final fileName = result?.files.single.name;
    context.read<PutFollowUpBloc>().add(
          PutFollowUpChecklistAttachmentPicked(fileName),
        );
  }
}

class _ChecklistActionCell extends StatelessWidget {
  const _ChecklistActionCell({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isActive = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.dark();
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isActive ? colors.accent : colors.textSecondary,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
