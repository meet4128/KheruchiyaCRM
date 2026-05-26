import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_crm/core/constants/string_constants.dart';
import 'package:travel_crm/core/theme/app_colors.dart';
import 'package:travel_crm/features/presentation/admin_panel/team_members/add_member/bloc/add_member_bloc.dart';
import 'package:travel_crm/features/presentation/admin_panel/team_members/add_member/bloc/add_member_event.dart';
import 'package:travel_crm/features/presentation/admin_panel/team_members/add_member/bloc/add_member_state.dart';
import 'package:travel_crm/features/presentation/admin_panel/team_members/add_member/widgets/add_member_operation_info_form.dart';
import 'package:travel_crm/features/presentation/admin_panel/team_members/add_member/widgets/add_member_personal_info_form.dart';

class AddMemberDialog extends StatelessWidget {
  const AddMemberDialog({super.key, this.onMemberSaved});

  /// Called after a successful create or update (before the dialog is popped).
  final void Function(AddMemberState state)? onMemberSaved;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.dark();
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        width: 900,
        constraints: const BoxConstraints(maxWidth: 900, maxHeight: 760),
        decoration: BoxDecoration(
          color: colors.backgroundMedium.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: colors.borderPrimary.withValues(alpha: 0.55)),
        ),
        child: Column(
          children: [
            _DialogHeader(
              onClose: () {
                context.read<AddMemberBloc>().add(const AddMemberDialogClosed());
                Navigator.of(context).pop();
              },
            ),
            Divider(color: colors.borderPrimary.withValues(alpha: 0.35), height: 1),
            Expanded(
              child: BlocBuilder<AddMemberBloc, AddMemberState>(
                buildWhen: (previous, current) => previous != current,
                builder: (context, state) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        child: state.currentStep == AddMemberStep.personal
                            ? const _PersonalInfoHeading()
                            : const _OperationInfoHeading(),
                      ),
                      Divider(color: colors.borderPrimary.withValues(alpha: 0.35), height: 1),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(20),
                          child: state.currentStep == AddMemberStep.personal
                              ? const AddMemberPersonalInfoForm()
                              : const AddMemberOperationInfoForm(),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Divider(color: colors.borderPrimary.withValues(alpha: 0.35), height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
              child: _DialogFooter(colors: colors, onMemberSaved: onMemberSaved),
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogHeader extends StatelessWidget {
  const _DialogHeader({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.dark();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        children: [
          const Spacer(),
          Text(
            StringConstant.addMemberDialogTitle,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 42 * 0.8,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: onClose,
            icon: Icon(Icons.close, color: colors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _PersonalInfoHeading extends StatelessWidget {
  const _PersonalInfoHeading();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.dark();
    return Column(
      children: [
        Text(
          StringConstant.addMemberPersonalInformationTitle,
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: 34 * 0.68,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          StringConstant.addMemberFillFormSubtitle,
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _OperationInfoHeading extends StatelessWidget {
  const _OperationInfoHeading();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.dark();
    return Column(
      children: [
        Text(
          StringConstant.addMemberOperationInformationTitle,
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: 34 * 0.68,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          StringConstant.addMemberFillFormSubtitle,
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

/// Decides what to show in the success SnackBar based on whether the submit
/// was a CREATE (invite result available) vs an EDIT (no invite involved) and,
/// for creates, what the backend did about the invite email.
String _successSnackbarText(AddMemberState state) {
  // Edit flow: there is no invite involved.
  if (state.editingMemberId != null) {
    return StringConstant.addMemberSubmitSuccessMessage;
  }
  final invite = state.lastInviteResult;
  if (invite == null) {
    return StringConstant.addMemberSubmitSuccessMessage;
  }
  if (invite.sent) {
    final to = (invite.sentTo ?? '').trim();
    return to.isEmpty
        ? StringConstant.addMemberSubmitSuccessMessage
        : StringConstant.addMemberInviteSentMessage(to);
  }
  return StringConstant.addMemberSubmittedNoInviteMessage;
}

class _DialogFooter extends StatelessWidget {
  const _DialogFooter({required this.colors, this.onMemberSaved});

  final AppColors colors;
  final void Function(AddMemberState state)? onMemberSaved;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddMemberBloc, AddMemberState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == AddMemberSubmitStatus.success) {
          onMemberSaved?.call(state);
          final messenger = ScaffoldMessenger.maybeOf(context);
          Navigator.of(context).pop();
          messenger?.showSnackBar(
            SnackBar(content: Text(_successSnackbarText(state))),
          );
        } else if (state.status == AddMemberSubmitStatus.failure) {
          final messenger = ScaffoldMessenger.maybeOf(context);
          final text = (state.submitErrorMessage?.trim().isNotEmpty ?? false)
              ? state.submitErrorMessage!.trim()
              : StringConstant.addMemberSubmitErrorGeneric;
          messenger?.showSnackBar(SnackBar(content: Text(text)));
        }
      },
      buildWhen: (previous, current) =>
          previous.currentStep != current.currentStep || previous.status != current.status,
      builder: (context, state) {
        final submitting = state.status == AddMemberSubmitStatus.submitting;
        final busy = submitting;

        if (state.currentStep == AddMemberStep.operation) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: busy
                          ? null
                          : () {
                              context.read<AddMemberBloc>().add(const AddMemberBackPressed());
                            },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colors.textPrimary,
                        side: BorderSide(color: colors.borderPrimary.withValues(alpha: 0.65)),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(StringConstant.addMemberBack),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: busy
                            ? null
                            : () {
                                context.read<AddMemberBloc>().add(const AddMemberSubmitPressed());
                              },
                        borderRadius: BorderRadius.circular(10),
                        child: Ink(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: LinearGradient(
                              colors: [
                                colors.accent,
                                colors.secondary,
                                colors.primaryLight,
                              ],
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            child: Center(
                              child: submitting
                                  ? SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: colors.textOnPrimary,
                                      ),
                                    )
                                  : Text(
                                      StringConstant.addMemberSubmit,
                                      style: TextStyle(
                                        color: colors.textOnPrimary,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                StringConstant.addMemberSubmitFooterNote,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
            ],
          );
        }

        return Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  context.read<AddMemberBloc>().add(const AddMemberNextPressed());
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.textPrimary,
                  side: BorderSide(color: colors.borderPrimary.withValues(alpha: 0.65)),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(StringConstant.addMemberNext),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              StringConstant.addMemberNextStepHelper,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        );
      },
    );
  }
}
