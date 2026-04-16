import 'package:flutter/material.dart';
import 'package:travel_crm/core/theme/app_colors.dart';
import 'package:travel_crm/features/presentation/admin_panel/team_members/add_member/bloc/add_member_state.dart';

class AddMemberGenderField extends StatelessWidget {
  const AddMemberGenderField({
    super.key,
    required this.value,
    required this.errorText,
    required this.onChanged,
  });

  final AddMemberGender? value;
  final String? errorText;
  final ValueChanged<AddMemberGender> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender',
          style: TextStyle(
            color: AppColors.dark().textSecondary,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _GenderOption(
              label: 'Male',
              selected: value == AddMemberGender.male,
              onTap: () => onChanged(AddMemberGender.male),
            ),
            const SizedBox(width: 18),
            _GenderOption(
              label: 'Female',
              selected: value == AddMemberGender.female,
              onTap: () => onChanged(AddMemberGender.female),
            ),
          ],
        ),
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Text(
            errorText!,
            style: TextStyle(
              color: AppColors.dark().error,
              fontSize: 11.5,
            ),
          ),
        ],
      ],
    );
  }
}

class _GenderOption extends StatelessWidget {
  const _GenderOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: selected ? AppColors.dark().secondary : Colors.transparent,
              border: Border.all(color: AppColors.dark().borderPrimary),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: AppColors.dark().textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
