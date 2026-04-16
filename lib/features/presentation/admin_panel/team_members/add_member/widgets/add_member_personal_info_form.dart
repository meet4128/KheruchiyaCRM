import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_crm/core/theme/app_colors.dart';
import 'package:travel_crm/core/widgets/app_date_picker.dart';
import 'package:travel_crm/core/widgets/app_text_field.dart';
import 'package:travel_crm/features/presentation/admin_panel/team_members/add_member/bloc/add_member_bloc.dart';
import 'package:travel_crm/features/presentation/admin_panel/team_members/add_member/bloc/add_member_event.dart';
import 'package:travel_crm/features/presentation/admin_panel/team_members/add_member/bloc/add_member_state.dart';
import 'package:travel_crm/features/presentation/admin_panel/team_members/add_member/widgets/add_member_gender_field.dart';
import 'package:travel_crm/features/presentation/admin_panel/team_members/add_member/widgets/add_member_phone_field.dart';

class AddMemberPersonalInfoForm extends StatelessWidget {
  const AddMemberPersonalInfoForm({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddMemberBloc, AddMemberState>(
      builder: (context, state) {
        return Column(
          children: [
            _TwoColumn(
              left: AppTextField(
                label: 'Full name',
                hint: 'Enter your Full Name',
                errorText: state.fullNameError,
                onChanged: (value) {
                  context.read<AddMemberBloc>().add(AddMemberFullNameChanged(value));
                },
              ),
              right: AppTextField(
                label: 'Personal E-mail Id',
                hint: 'Enter your e-mail',
                errorText: state.personalEmailError,
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) {
                  context.read<AddMemberBloc>().add(AddMemberPersonalEmailChanged(value));
                },
              ),
            ),
            const SizedBox(height: 14),
            _TwoColumn(
              left: AddMemberPhoneField(
                label: 'Phone Number*',
                selectedCode: state.phoneDialCode,
                numberError: state.phoneNumberError,
                onCodeChanged: (dialCode) {
                  context.read<AddMemberBloc>().add(
                        AddMemberPhoneChanged(dialCode: dialCode, number: state.phoneNumber),
                      );
                },
                onNumberChanged: (number) {
                  context.read<AddMemberBloc>().add(
                        AddMemberPhoneChanged(dialCode: state.phoneDialCode, number: number),
                      );
                },
              ),
              right: AddMemberPhoneField(
                label: 'Home Phone Number*',
                selectedCode: state.homePhoneDialCode,
                numberError: state.homePhoneNumberError,
                onCodeChanged: (dialCode) {
                  context.read<AddMemberBloc>().add(
                        AddMemberHomePhoneChanged(
                          dialCode: dialCode,
                          number: state.homePhoneNumber,
                        ),
                      );
                },
                onNumberChanged: (number) {
                  context.read<AddMemberBloc>().add(
                        AddMemberHomePhoneChanged(
                          dialCode: state.homePhoneDialCode,
                          number: number,
                        ),
                      );
                },
              ),
            ),
            const SizedBox(height: 14),
            _TwoColumn(
              left: AppDatePicker(
                label: 'D.O.B',
                hint: 'Enter your date of birth',
                value: state.dob,
                firstDate: DateTime(1950, 1, 1),
                lastDate: DateTime.now(),
                errorText: state.dobError,
                onChanged: (value) {
                  context.read<AddMemberBloc>().add(AddMemberDobChanged(value));
                },
              ),
              right: AddMemberGenderField(
                value: state.gender,
                errorText: state.genderError,
                onChanged: (gender) {
                  context.read<AddMemberBloc>().add(AddMemberGenderChanged(gender));
                },
              ),
            ),
            const SizedBox(height: 14),
            _TwoColumn(
              left: _MaritalStatusDropdown(
                value: state.maritalStatus.isEmpty ? null : state.maritalStatus,
                errorText: state.maritalStatusError,
                onChanged: (value) {
                  if (value != null) {
                    context.read<AddMemberBloc>().add(AddMemberMaritalStatusChanged(value));
                  }
                },
              ),
              right: AppDatePicker(
                label: 'Date of Anniversary',
                hint: 'Enter your work e-mail',
                value: state.anniversaryDate,
                firstDate: DateTime(1950, 1, 1),
                lastDate: DateTime(2100, 12, 31),
                onChanged: (value) {
                  context.read<AddMemberBloc>().add(AddMemberAnniversaryChanged(value));
                },
              ),
            ),
            const SizedBox(height: 14),
            _TwoColumn(
              left: AppTextField(
                label: 'Address',
                hint: 'Building/Flat No., Floor, etc.',
                errorText: state.addressError,
                onChanged: (value) {
                  context.read<AddMemberBloc>().add(AddMemberAddressChanged(value));
                },
              ),
              right: AppTextField(
                label: 'Address Line 2',
                hint: 'Landmark',
                onChanged: (value) {
                  context.read<AddMemberBloc>().add(AddMemberAddressLine2Changed(value));
                },
              ),
            ),
            const SizedBox(height: 14),
            _TwoColumn(
              left: AppTextField(
                label: 'Zip code',
                hint: 'Enter your pin code',
                errorText: state.zipCodeError,
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  context.read<AddMemberBloc>().add(AddMemberZipCodeChanged(value));
                },
              ),
              right: AppTextField(
                label: 'City',
                hint: 'Select City',
                errorText: state.cityError,
                onChanged: (value) {
                  context.read<AddMemberBloc>().add(AddMemberCityChanged(value));
                },
              ),
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

class _MaritalStatusDropdown extends StatelessWidget {
  const _MaritalStatusDropdown({
    required this.value,
    required this.errorText,
    required this.onChanged,
  });

  final String? value;
  final String? errorText;
  final ValueChanged<String?> onChanged;

  static const _options = ['Married', 'Unmarried', 'Widow'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Marital Status',
          style: TextStyle(
            color: AppColors.dark().textSecondary,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          dropdownColor: AppColors.dark().backgroundMedium,
          iconEnabledColor: AppColors.dark().textSecondary,
          style: TextStyle(color: AppColors.dark().textPrimary, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Married/unmarried/widow',
            hintStyle: TextStyle(color: AppColors.dark().textTertiary),
            errorText: errorText,
            filled: true,
            fillColor: AppColors.dark().inputBackground,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.dark().inputBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.dark().inputBorderFocused),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.dark().inputErrorBorder),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.dark().inputErrorBorder),
            ),
          ),
          items: _options
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
