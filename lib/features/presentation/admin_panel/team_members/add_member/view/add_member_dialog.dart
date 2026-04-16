import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_crm/core/theme/app_colors.dart';
import 'package:travel_crm/features/presentation/admin_panel/team_members/add_member/bloc/add_member_bloc.dart';
import 'package:travel_crm/features/presentation/admin_panel/team_members/add_member/bloc/add_member_event.dart';
import 'package:travel_crm/features/presentation/admin_panel/team_members/add_member/bloc/add_member_state.dart';
import 'package:travel_crm/features/presentation/admin_panel/team_members/add_member/widgets/add_member_personal_info_form.dart';

class AddMemberDialog extends StatelessWidget {
  const AddMemberDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        width: 900,
        constraints: const BoxConstraints(maxWidth: 900, maxHeight: 760),
        decoration: BoxDecoration(
          color: AppColors.dark().backgroundMedium.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.dark().borderPrimary.withValues(alpha: 0.55)),
        ),
        child: Column(
          children: [
            _DialogHeader(
              onClose: () {
                context.read<AddMemberBloc>().add(const AddMemberDialogClosed());
                Navigator.of(context).pop();
              },
            ),
            Divider(color: AppColors.dark().borderPrimary.withValues(alpha: 0.35), height: 1),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: _PersonalInfoHeading(),
            ),
            Divider(color: AppColors.dark().borderPrimary.withValues(alpha: 0.35), height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: const AddMemberPersonalInfoForm(),
              ),
            ),
            Divider(color: AppColors.dark().borderPrimary.withValues(alpha: 0.35), height: 1),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 18),
              child: _DialogFooter(),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        children: [
          const Spacer(),
          Text(
            'Add Member',
            style: TextStyle(
              color: AppColors.dark().textPrimary,
              fontSize: 42 * 0.8,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: onClose,
            icon: Icon(Icons.close, color: AppColors.dark().textSecondary),
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
    return Column(
      children: [
        Text(
          'Personal Information',
          style: TextStyle(
            color: AppColors.dark().textPrimary,
            fontSize: 34 * 0.68,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Fill the form with correct details',
          style: TextStyle(
            color: AppColors.dark().textSecondary,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _DialogFooter extends StatelessWidget {
  const _DialogFooter();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddMemberBloc, AddMemberState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == AddMemberSubmitStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Personal information validated. Next step pending.')),
          );
        }
      },
      builder: (context, state) {
        return Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  context.read<AddMemberBloc>().add(const AddMemberNextPressed());
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.dark().textPrimary,
                  side: BorderSide(color: AppColors.dark().borderPrimary.withValues(alpha: 0.65)),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Next'),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Please fill all the required details and then click to the next to move on operational form',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.dark().textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        );
      },
    );
  }
}
