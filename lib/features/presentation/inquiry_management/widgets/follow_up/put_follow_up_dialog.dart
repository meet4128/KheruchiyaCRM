import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_crm/core/theme/app_colors.dart';
import 'package:travel_crm/features/presentation/inquiry_management/bloc/put_follow_up/put_follow_up_bloc.dart';
import 'package:travel_crm/features/presentation/inquiry_management/bloc/put_follow_up/put_follow_up_event.dart';
import 'package:travel_crm/features/presentation/inquiry_management/widgets/follow_up/widgets/follow_up_checklist_bar.dart';
import 'package:travel_crm/features/presentation/inquiry_management/widgets/follow_up/widgets/follow_up_dialog_footer.dart';
import 'package:travel_crm/features/presentation/inquiry_management/widgets/follow_up/widgets/follow_up_dialog_header.dart';
import 'package:travel_crm/features/presentation/inquiry_management/widgets/follow_up/widgets/follow_up_note_field.dart';
import 'package:travel_crm/features/presentation/inquiry_management/widgets/follow_up/widgets/follow_up_schedule_row.dart';

class PutFollowUpDialog extends StatelessWidget {
  const PutFollowUpDialog({super.key, this.onSaved});

  final VoidCallback? onSaved;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.dark();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        width: 720,
        constraints: const BoxConstraints(maxWidth: 720, maxHeight: 640),
        decoration: BoxDecoration(
          color: colors.backgroundMedium.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: colors.borderPrimary.withValues(alpha: 0.55)),
        ),
        child: Column(
          children: [
            FollowUpDialogHeader(
              onClose: () {
                context.read<PutFollowUpBloc>().add(const PutFollowUpDialogClosed());
                Navigator.of(context).pop();
              },
            ),
            Divider(color: colors.borderPrimary.withValues(alpha: 0.35), height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: const [
                    FollowUpNoteField(),
                    SizedBox(height: 16),
                    FollowUpScheduleRow(),
                    SizedBox(height: 16),
                    FollowUpChecklistBar(),
                  ],
                ),
              ),
            ),
            Divider(color: colors.borderPrimary.withValues(alpha: 0.35), height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
              child: FollowUpDialogFooter(onSaved: onSaved),
            ),
          ],
        ),
      ),
    );
  }
}
