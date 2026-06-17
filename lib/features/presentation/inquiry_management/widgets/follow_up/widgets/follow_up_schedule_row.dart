import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_crm/core/constants/string_constants.dart';
import 'package:travel_crm/core/theme/app_colors.dart';
import 'package:travel_crm/core/widgets/app_date_picker.dart';
import 'package:travel_crm/core/widgets/app_dropdown.dart';
import 'package:travel_crm/data/models/members/member_directory_item.dart';
import 'package:travel_crm/features/presentation/inquiry_management/bloc/put_follow_up/put_follow_up_bloc.dart';
import 'package:travel_crm/features/presentation/inquiry_management/bloc/put_follow_up/put_follow_up_event.dart';
import 'package:travel_crm/features/presentation/inquiry_management/bloc/put_follow_up/put_follow_up_state.dart';
import 'package:travel_crm/features/presentation/inquiry_management/utils/member_directory_display.dart';

class FollowUpScheduleRow extends StatelessWidget {
  const FollowUpScheduleRow({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PutFollowUpBloc, PutFollowUpState>(
      buildWhen: (p, c) =>
          p.reminderDate != c.reminderDate ||
          p.reminderTime != c.reminderTime ||
          p.selectedAgent != c.selectedAgent ||
          p.agents != c.agents ||
          p.directoryStatus != c.directoryStatus ||
          p.directoryErrorMessage != c.directoryErrorMessage ||
          p.agentError != c.agentError,
      builder: (context, state) {
        final selectedAgent = memberDirectoryItemById(state.agents, state.selectedAgent);
        final agentsLoading = state.directoryStatus == PutFollowUpDirectoryStatus.loading;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AppDatePicker(
                label: StringConstant.putFollowUpSetDate,
                hint: StringConstant.putFollowUpSetDate,
                value: state.reminderDate,
                onChanged: (date) {
                  context.read<PutFollowUpBloc>().add(PutFollowUpDateChanged(date));
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _FollowUpTimeField(
                value: state.reminderTime,
                onChanged: (time) {
                  context.read<PutFollowUpBloc>().add(PutFollowUpTimeChanged(time));
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppDropdown<MemberDirectoryItem>(
                    label: StringConstant.putFollowUpSelectAgent,
                    hintText: StringConstant.putFollowUpSelectUser,
                    isRequired: true,
                    enabled: !agentsLoading && state.agents.isNotEmpty,
                    items: state.agents,
                    value: selectedAgent,
                    itemLabel: memberDirectoryDisplayName,
                    errorText: state.agentError ??
                        (state.directoryStatus == PutFollowUpDirectoryStatus.failure
                            ? state.directoryErrorMessage
                            : null),
                    onChanged: (agent) {
                      if (agent != null) {
                        context.read<PutFollowUpBloc>().add(PutFollowUpAgentChanged(agent));
                      }
                    },
                  ),
                  if (state.directoryStatus == PutFollowUpDirectoryStatus.failure)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () {
                          context
                              .read<PutFollowUpBloc>()
                              .add(const PutFollowUpMemberDirectoryRequested());
                        },
                        child: Text(StringConstant.putFollowUpRetryLoadAgents),
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FollowUpTimeField extends StatelessWidget {
  const _FollowUpTimeField({
    required this.value,
    required this.onChanged,
  });

  final TimeOfDay? value;
  final ValueChanged<TimeOfDay?> onChanged;

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  Future<void> _pickTime(BuildContext context) async {
    final colors = AppColors.dark();
    final picked = await showTimePicker(
      context: context,
      initialTime: value ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: colors.accent,
              onPrimary: colors.textOnPrimary,
              surface: colors.backgroundMedium,
              onSurface: colors.textPrimary,
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
    if (picked != null) {
      onChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.dark();
    final label = StringConstant.putFollowUpTime;
    final display = value == null ? '' : _formatTime(value!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _pickTime(context),
          borderRadius: BorderRadius.circular(10),
          child: InputDecorator(
            decoration: InputDecoration(
              hintText: StringConstant.putFollowUpSelectTime,
              hintStyle: TextStyle(color: colors.textSecondary.withValues(alpha: 0.75)),
              filled: true,
              fillColor: colors.inputBackground,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: colors.inputBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: colors.inputBorderFocused, width: 1.5),
              ),
              suffixIcon: Icon(Icons.access_time, color: colors.textSecondary, size: 20),
            ),
            child: Text(
              display,
              style: TextStyle(
                color: display.isEmpty ? colors.textSecondary.withValues(alpha: 0.75) : colors.textPrimary,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
