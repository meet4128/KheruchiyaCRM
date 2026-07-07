import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_crm/core/constants/string_constants.dart';
import 'package:travel_crm/core/theme/app_colors.dart';
import 'package:travel_crm/features/presentation/inquiry_management/bloc/put_follow_up/put_follow_up_bloc.dart';
import 'package:travel_crm/features/presentation/inquiry_management/bloc/put_follow_up/put_follow_up_event.dart';
import 'package:travel_crm/features/presentation/inquiry_management/bloc/put_follow_up/put_follow_up_state.dart';

class FollowUpDialogFooter extends StatelessWidget {
  const FollowUpDialogFooter({super.key, this.onSaved});

  final VoidCallback? onSaved;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.dark();

    return BlocConsumer<PutFollowUpBloc, PutFollowUpState>(
      listenWhen: (p, c) => p.submitStatus != c.submitStatus,
      listener: (context, state) {
        if (state.submitStatus == PutFollowUpSubmitStatus.success) {
          onSaved?.call();
          final messenger = ScaffoldMessenger.maybeOf(context);
          // Pop the created event's date so the caller can redirect the Calendar
          // to that month (null when no calendar event was created).
          Navigator.of(context).pop(state.redirectFocusDate);
          messenger?.showSnackBar(
            SnackBar(content: Text(StringConstant.putFollowUpSaveSuccess)),
          );
        } else if (state.submitStatus == PutFollowUpSubmitStatus.failure) {
          final message = (state.submitErrorMessage?.trim().isNotEmpty ?? false)
              ? state.submitErrorMessage!.trim()
              : StringConstant.putFollowUpSaveErrorGeneric;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        }
      },
      buildWhen: (p, c) =>
          p.isRepeatEnabled != c.isRepeatEnabled ||
          p.canSubmit != c.canSubmit ||
          p.submitStatus != c.submitStatus,
      builder: (context, state) {
        final submitting = state.submitStatus == PutFollowUpSubmitStatus.submitting;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Row(
                children: [
                  SizedBox(
                    height: 24,
                    width: 24,
                    child: Checkbox(
                      value: state.isRepeatEnabled,
                      onChanged: submitting
                          ? null
                          : (value) {
                              context.read<PutFollowUpBloc>().add(
                                    PutFollowUpRepeatToggled(value ?? false),
                                  );
                            },
                      activeColor: colors.accent,
                      side: BorderSide(color: colors.borderPrimary),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    StringConstant.putFollowUpRepeat,
                    style: TextStyle(color: colors.textPrimary, fontSize: 14),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              enabled: !submitting,
              icon: Icon(Icons.more_vert, color: colors.textSecondary),
              color: colors.backgroundMedium,
              onSelected: (value) {
                if (value == 'clear') {
                  context.read<PutFollowUpBloc>().add(const PutFollowUpFormClearRequested());
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem<String>(
                  value: 'clear',
                  child: Text(
                    StringConstant.putFollowUpClearForm,
                    style: TextStyle(color: colors.textPrimary),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: state.canSubmit
                    ? () {
                        context.read<PutFollowUpBloc>().add(const PutFollowUpSavePressed());
                      }
                    : null,
                borderRadius: BorderRadius.circular(10),
                child: Ink(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: LinearGradient(
                      colors: state.canSubmit
                          ? [colors.accent, colors.secondary, colors.primaryLight]
                          : [
                              colors.borderSecondary,
                              colors.borderSecondary,
                              colors.borderSecondary,
                            ],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: submitting
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colors.textOnPrimary,
                            ),
                          )
                        : Text(
                            StringConstant.saveFollowUpReminder,
                            style: TextStyle(
                              color: colors.textOnPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
