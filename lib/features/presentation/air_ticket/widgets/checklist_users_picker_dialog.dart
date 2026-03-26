import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_crm/core/constants/string_constants.dart';
import 'package:travel_crm/core/theme/app_theme.dart';
import 'package:travel_crm/features/presentation/air_ticket/bloc/checklist_users_picker_cubit.dart';

/// Shows the themed "Add users" dialog. State is driven by [ChecklistUsersPickerCubit].
Future<void> showChecklistUsersPickerDialog(
  BuildContext context, {
  required String initialUser,
  required ValueChanged<String> onDone,
}) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => BlocProvider(
      create: (_) => ChecklistUsersPickerCubit(parseChecklistUserList(initialUser)),
      child: _ChecklistUsersPickerDialog(onDone: onDone),
    ),
  );
}

/// Holds [TextEditingController] and [FocusNode] only; list updates via [BlocBuilder].
class _ChecklistUsersPickerDialog extends StatefulWidget {
  const _ChecklistUsersPickerDialog({required this.onDone});

  final ValueChanged<String> onDone;

  @override
  State<_ChecklistUsersPickerDialog> createState() => _ChecklistUsersPickerDialogState();
}

class _ChecklistUsersPickerDialogState extends State<_ChecklistUsersPickerDialog> {
  late final TextEditingController _controller;
  late final FocusNode _fieldFocusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _fieldFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _fieldFocusNode.dispose();
    super.dispose();
  }

  void _refocusField() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _fieldFocusNode.requestFocus();
    });
  }

  void _submitDraft(BuildContext context) {
    context.read<ChecklistUsersPickerCubit>().addName(_controller.text);
    _controller.clear();
    _refocusField();
  }

  void _onDonePressed(BuildContext context) {
    final joined = context.read<ChecklistUsersPickerCubit>().joinedForField();
    widget.onDone(joined);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);
    final textStyles = AppTheme.textStyles(context);
    final borderColor = colors.secondary.withValues(alpha: 0.5);

    return Dialog(
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: borderColor, width: 1),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440, maxHeight: 520),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                StringConstant.addUsersTitle,
                style: textStyles.heading5.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.inputBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor, width: 1),
                  ),
                  child: BlocBuilder<ChecklistUsersPickerCubit, ChecklistUsersPickerState>(
                    buildWhen: (prev, curr) => prev.names != curr.names,
                    builder: (context, state) {
                      if (state.names.isEmpty) {
                        return Center(
                          child: Icon(
                            Icons.group_outlined,
                            size: 44,
                            color: colors.textSecondary.withValues(alpha: 0.35),
                          ),
                        );
                      }
                      return SingleChildScrollView(
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.start,
                          children: List.generate(state.names.length, (i) {
                            return InputChip(
                              label: Text(
                                state.names[i],
                                style: textStyles.bodyMedium.copyWith(
                                  color: colors.textPrimary,
                                ),
                              ),
                              deleteIcon: Icon(
                                Icons.close_rounded,
                                size: 18,
                                color: colors.textSecondary,
                              ),
                              onDeleted: () =>
                                  context.read<ChecklistUsersPickerCubit>().removeAt(i),
                              backgroundColor: colors.backgroundMedium,
                              side: BorderSide(
                                color: colors.borderSecondary.withValues(alpha: 0.5),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 0,
                              ),
                            );
                          }),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _controller,
                focusNode: _fieldFocusNode,
                style: textStyles.formInput.copyWith(color: colors.textPrimary),
                cursorColor: colors.inputBorderFocused,
                autofocus: true,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _submitDraft(context),
                decoration: InputDecoration(
                  hintText: StringConstant.userTypeNamePressEnter,
                  hintStyle: textStyles.formHint,
                  filled: true,
                  fillColor: colors.inputBackground,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colors.inputBorder, width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colors.inputBorder, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: colors.inputBorderFocused,
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _onDonePressed(context),
                    borderRadius: BorderRadius.circular(12),
                    child: Ink(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            colors.secondary,
                            colors.secondary.withValues(alpha: 0.85),
                            const Color(0xFFEC4899),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        StringConstant.done,
                        style: textStyles.labelLarge.copyWith(
                          color: colors.textOnPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
