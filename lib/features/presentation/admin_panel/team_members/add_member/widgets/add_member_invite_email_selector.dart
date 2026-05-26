import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_crm/core/constants/string_constants.dart';
import 'package:travel_crm/core/theme/app_colors.dart';
import 'package:travel_crm/core/widgets/app_text_field.dart';
import 'package:travel_crm/features/presentation/admin_panel/team_members/add_member/bloc/add_member_bloc.dart';
import 'package:travel_crm/features/presentation/admin_panel/team_members/add_member/bloc/add_member_event.dart';
import 'package:travel_crm/features/presentation/admin_panel/team_members/add_member/bloc/add_member_state.dart';

/// Admin-only "where do we send the invite?" picker, shown at the bottom of
/// the Operation Information step on the CREATE flow only.
///
/// Three radio options + a checkbox:
///   - Personal email      → backend uses `personalEmail`, we omit `inviteEmail`
///   - Work email          → reserved, currently disabled (no field on member)
///   - Other               → text field + email validation; sent as `inviteEmail`
///   - "Don't send now"    → toggles `sendInvite: false`
///
/// On EDIT flow the parent never renders this widget — the invite is only
/// initiated on member creation.
class AddMemberInviteEmailSelector extends StatefulWidget {
  const AddMemberInviteEmailSelector({super.key});

  @override
  State<AddMemberInviteEmailSelector> createState() =>
      _AddMemberInviteEmailSelectorState();
}

class _AddMemberInviteEmailSelectorState
    extends State<AddMemberInviteEmailSelector> {
  late final TextEditingController _customEmailController;

  @override
  void initState() {
    super.initState();
    _customEmailController = TextEditingController(
      text: context.read<AddMemberBloc>().state.customInviteEmail,
    );
  }

  @override
  void dispose() {
    _customEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.dark();

    return BlocBuilder<AddMemberBloc, AddMemberState>(
      buildWhen: (previous, current) =>
          previous.inviteEmailChoice != current.inviteEmailChoice ||
          previous.sendInvite != current.sendInvite ||
          previous.personalEmail != current.personalEmail ||
          previous.customInviteEmailError != current.customInviteEmailError ||
          previous.status != current.status,
      builder: (context, state) {
        final busy = state.status == AddMemberSubmitStatus.submitting;
        final personalEmail = state.personalEmail.trim();
        final personalEmailEmpty = personalEmail.isEmpty;

        return Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            color: colors.backgroundMedium.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colors.borderPrimary.withValues(alpha: 0.45),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.mark_email_unread_outlined,
                    color: colors.textSecondary,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    StringConstant.addMemberInviteSectionTitle,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                StringConstant.addMemberInviteSectionSubtitle,
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 11,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 10),
              RadioGroup<AddMemberInviteEmailChoice>(
                groupValue: state.inviteEmailChoice,
                // The callback fires only when a tappable Radio is selected.
                // Individual Radios are disabled (via `enabled: false`) when
                // busy / sendInvite=false, so this callback won't fire in
                // those states even though we always pass a real function.
                onChanged: (v) {
                  if (v == null) return;
                  context
                      .read<AddMemberBloc>()
                      .add(AddMemberInviteEmailChoiceChanged(v));
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _RadioRow(
                      label: StringConstant.addMemberInviteEmailPersonal,
                      detail: personalEmailEmpty
                          ? StringConstant.addMemberInviteEmailPersonalEmpty
                          : personalEmail,
                      value: AddMemberInviteEmailChoice.personal,
                      disabled: busy ||
                          !state.sendInvite ||
                          personalEmailEmpty,
                    ),
                    _RadioRow(
                      label: StringConstant.addMemberInviteEmailWork,
                      detail: StringConstant
                          .addMemberInviteEmailWorkUnavailable,
                      value: AddMemberInviteEmailChoice.work,
                      disabled: true,
                    ),
                    _RadioRow(
                      label: StringConstant.addMemberInviteEmailCustom,
                      value: AddMemberInviteEmailChoice.custom,
                      disabled: busy || !state.sendInvite,
                    ),
                  ],
                ),
              ),
              if (state.inviteEmailChoice ==
                  AddMemberInviteEmailChoice.custom) ...[
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(left: 30),
                  child: AppTextField(
                    controller: _customEmailController,
                    hint: StringConstant.addMemberInviteEmailHint,
                    enabled: !busy && state.sendInvite,
                    errorText: state.customInviteEmailError,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (value) {
                      context
                          .read<AddMemberBloc>()
                          .add(AddMemberCustomInviteEmailChanged(value));
                    },
                  ),
                ),
              ],
              const SizedBox(height: 6),
              InkWell(
                onTap: busy
                    ? null
                    : () => context
                        .read<AddMemberBloc>()
                        .add(AddMemberSendInviteToggled(!state.sendInvite)),
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 22,
                        height: 22,
                        child: Checkbox(
                          value: !state.sendInvite,
                          onChanged: busy
                              ? null
                              : (v) => context.read<AddMemberBloc>().add(
                                    AddMemberSendInviteToggled(!(v ?? false)),
                                  ),
                          side: BorderSide(
                            color: colors.borderPrimary.withValues(alpha: 0.6),
                          ),
                          fillColor: WidgetStateProperty.resolveWith((states) {
                            if (states.contains(WidgetState.selected)) {
                              return colors.accent.withValues(alpha: 0.85);
                            }
                            return Colors.transparent;
                          }),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          StringConstant.addMemberSendInviteToggle,
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Row containing a single [Radio] + label + optional detail line. The
/// surrounding [RadioGroup] manages selection state — this widget only knows
/// its own [value].
class _RadioRow extends StatelessWidget {
  const _RadioRow({
    required this.label,
    required this.value,
    this.detail,
    this.disabled = false,
  });

  final String label;
  final String? detail;
  final AddMemberInviteEmailChoice value;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.dark();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 22,
            height: 22,
            child: Radio<AddMemberInviteEmailChoice>(
              value: value,
              enabled: !disabled,
              fillColor: WidgetStateProperty.resolveWith((states) {
                if (disabled) return colors.textTertiary;
                if (states.contains(WidgetState.selected)) {
                  return colors.accent;
                }
                return colors.borderPrimary;
              }),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: disabled ? colors.textTertiary : colors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (detail != null && detail!.isNotEmpty)
                  Text(
                    detail!,
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
