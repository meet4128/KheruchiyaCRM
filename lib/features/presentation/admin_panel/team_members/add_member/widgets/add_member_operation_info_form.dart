import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_crm/core/constants/string_constants.dart';
import 'package:travel_crm/core/theme/app_colors.dart';
import 'package:travel_crm/core/widgets/app_date_picker.dart';
import 'package:travel_crm/core/widgets/app_text_field.dart';
import 'package:travel_crm/features/presentation/admin_panel/team_members/add_member/bloc/add_member_bloc.dart';
import 'package:travel_crm/features/presentation/admin_panel/team_members/add_member/bloc/add_member_event.dart';
import 'package:travel_crm/features/presentation/admin_panel/team_members/add_member/bloc/add_member_state.dart';
import 'package:travel_crm/features/presentation/admin_panel/team_members/add_member/widgets/add_member_attachment_slot.dart';
import 'package:travel_crm/features/presentation/admin_panel/team_members/add_member/widgets/add_member_phone_field.dart';

/// Step 2 — Operation Information ([add_member_submit.md] Phase 2).
class AddMemberOperationInfoForm extends StatelessWidget {
  const AddMemberOperationInfoForm({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddMemberBloc, AddMemberState>(
      builder: (context, state) {
        final colors = AppColors.dark();
        final attachmentsEnabled = state.status != AddMemberSubmitStatus.submitting;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _TwoColumn(
              left: AppTextField(
                label: StringConstant.firstName,
                hint: StringConstant.addMemberFirstNameHint,
                errorText: state.firstNameError,
                onChanged: (value) {
                  context.read<AddMemberBloc>().add(AddMemberFirstNameChanged(value));
                },
              ),
              right: AppTextField(
                label: StringConstant.lastName,
                hint: StringConstant.addMemberLastNameHint,
                errorText: state.lastNameError,
                onChanged: (value) {
                  context.read<AddMemberBloc>().add(AddMemberLastNameChanged(value));
                },
              ),
            ),
            const SizedBox(height: 14),
            _TwoColumn(
              left: AppTextField(
                label: StringConstant.addMemberEmployeeIdLabel,
                hint: StringConstant.addMemberEmployeeIdHint,
                errorText: state.employeeIdError,
                onChanged: (value) {
                  context.read<AddMemberBloc>().add(AddMemberEmployeeIdChanged(value));
                },
              ),
              right: AppTextField(
                label: StringConstant.addMemberDesignationLabel,
                hint: StringConstant.addMemberDesignationHint,
                errorText: state.designationError,
                onChanged: (value) {
                  context.read<AddMemberBloc>().add(AddMemberDesignationChanged(value));
                },
              ),
            ),
            const SizedBox(height: 14),
            _TwoColumn(
              left: _OperationDropdown(
                label: StringConstant.addMemberEmploymentStatusLabel,
                hint: StringConstant.addMemberEmploymentStatusHint,
                value: state.employmentStatus.isEmpty ? null : state.employmentStatus,
                errorText: state.employmentStatusError,
                items: const ['Active', 'Probation', 'On Leave', 'Contract'],
                onChanged: (value) {
                  if (value != null) {
                    context.read<AddMemberBloc>().add(AddMemberEmploymentStatusChanged(value));
                  }
                },
              ),
              right: AppDatePicker(
                label: StringConstant.addMemberDateOfJoiningLabel,
                hint: StringConstant.addMemberDateOfJoiningHint,
                value: state.dateOfJoining,
                firstDate: DateTime(2000, 1, 1),
                lastDate: DateTime(2100, 12, 31),
                errorText: state.dateOfJoiningError,
                onChanged: (value) {
                  context.read<AddMemberBloc>().add(AddMemberDateOfJoiningChanged(value));
                },
              ),
            ),
            const SizedBox(height: 18),
            Text(
              StringConstant.addMemberTypeOfRole,
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            for (var index = 0; index < state.roleRows.length; index++) ...[
              Padding(
                key: ValueKey<String>('role_row_$index'),
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _OperationDropdown(
                        label: StringConstant.addMemberSelectDepartmentLabel,
                        hint: StringConstant.addMemberSelectDepartmentHint,
                        value: state.roleRows[index].department.isEmpty
                            ? null
                            : state.roleRows[index].department,
                        errorText: null,
                        items: const ['Admin', 'Sales', 'Purchase', 'Accounts'],
                        onChanged: (value) {
                          if (value != null) {
                            context.read<AddMemberBloc>().add(
                                  AddMemberRoleRowDepartmentChanged(index: index, value: value),
                                );
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _OperationDropdown(
                        label: StringConstant.addMemberSelectRoleLabel,
                        hint: StringConstant.addMemberSelectRoleHint,
                        value: state.roleRows[index].role.isEmpty ? null : state.roleRows[index].role,
                        errorText: null,
                        items: const ['Manager', 'Lead', 'Executive', 'Associate'],
                        onChanged: (value) {
                          if (value != null) {
                            context.read<AddMemberBloc>().add(
                                  AddMemberRoleRowRoleChanged(index: index, value: value),
                                );
                          }
                        },
                      ),
                    ),
                    if (index == 0) ...[
                      const SizedBox(width: 12),
                      Padding(
                        padding: const EdgeInsets.only(top: 28),
                        child: _AddRoleGradientButton(
                          compact: true,
                          onPressed: () {
                            context.read<AddMemberBloc>().add(const AddMemberRoleRowAdded());
                          },
                        ),
                      ),
                    ],
                    if (index > 0)
                      Padding(
                        padding: const EdgeInsets.only(left: 4, top: 28),
                        child: IconButton(
                          tooltip: StringConstant.addMemberRemoveRoleTooltip,
                          onPressed: () {
                            context.read<AddMemberBloc>().add(AddMemberRoleRowRemoved(index));
                          },
                          icon: Icon(Icons.delete_outline, color: colors.error, size: 22),
                        ),
                      ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 14),
            AddMemberPhoneField(
              label: StringConstant.addMemberOfficePhoneLabel,
              requiredField: true,
              allottedNote: StringConstant.addMemberAllottedLabel,
              numberHint: StringConstant.addMemberOfficePhoneNumberHint,
              selectedCode: state.officePhoneDialCode,
              numberError: state.officePhoneNumberError,
              onCodeChanged: (dialCode) {
                context.read<AddMemberBloc>().add(
                      AddMemberOfficePhoneChanged(
                        dialCode: dialCode,
                        number: state.officePhoneNumber,
                      ),
                    );
              },
              onNumberChanged: (number) {
                context.read<AddMemberBloc>().add(
                      AddMemberOfficePhoneChanged(
                        dialCode: state.officePhoneDialCode,
                        number: number,
                      ),
                    );
              },
            ),
            const SizedBox(height: 18),
            Center(
              child: Text(
                StringConstant.addMemberAttachDocuments,
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AddMemberAttachmentSlot(
                    kind: AddMemberAttachmentKind.aadhar,
                    label: StringConstant.addMemberAttachmentAadhar,
                    attachment: state.aadharAttachment,
                    enabled: attachmentsEnabled,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AddMemberAttachmentSlot(
                    kind: AddMemberAttachmentKind.pan,
                    label: StringConstant.addMemberAttachmentPan,
                    attachment: state.panAttachment,
                    enabled: attachmentsEnabled,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AddMemberAttachmentSlot(
                    kind: AddMemberAttachmentKind.cancelCheque,
                    label: StringConstant.addMemberAttachmentCancelCheque,
                    attachment: state.cancelChequeAttachment,
                    enabled: attachmentsEnabled,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _TwoColumn extends StatelessWidget {
  const _TwoColumn({required this.left, required this.right});

  final Widget left;
  final Widget right;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        const SizedBox(width: 16),
        Expanded(child: right),
      ],
    );
  }
}

class _OperationDropdown extends StatelessWidget {
  const _OperationDropdown({
    required this.label,
    required this.hint,
    required this.value,
    required this.errorText,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String hint;
  final String? value;
  final String? errorText;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.dark();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          dropdownColor: colors.backgroundMedium,
          iconEnabledColor: colors.textSecondary,
          style: TextStyle(color: colors.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: colors.textTertiary),
            errorText: errorText,
            filled: true,
            fillColor: colors.inputBackground,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: colors.inputBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: colors.inputBorderFocused),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: colors.inputErrorBorder),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: colors.inputErrorBorder),
            ),
          ),
          items: items
              .map(
                (item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

/// Primary accent control ([add_member_submit.md] Phase 3 — theme).
class _AddRoleGradientButton extends StatelessWidget {
  const _AddRoleGradientButton({
    required this.onPressed,
    this.compact = false,
  });

  final VoidCallback onPressed;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.dark();
    final child = compact
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add, color: colors.textOnPrimary, size: 18),
              const SizedBox(width: 4),
              Text(
                StringConstant.addMemberAddRoleLabelCompact,
                style: TextStyle(
                  color: colors.textOnPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          )
        : Text(
            StringConstant.addMemberAddRoleButton,
            style: TextStyle(
              color: colors.textOnPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: LinearGradient(
              colors: [
                colors.accent,
                colors.secondary,
                colors.primaryLight,
              ],
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 12 : 16,
              vertical: compact ? 8 : 10,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
