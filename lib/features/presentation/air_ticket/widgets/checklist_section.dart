import 'package:flutter/material.dart';
import 'package:travel_crm/core/constants/string_constants.dart';
import 'package:travel_crm/core/theme/app_theme.dart';
import 'package:travel_crm/core/widgets/app_date_picker.dart';
import 'package:travel_crm/core/widgets/app_dropdown.dart';
import 'package:travel_crm/core/widgets/app_text_field.dart';
import '../models/checklist_item.dart';
import '../models/priority.dart';

/// Checklist section widget
/// Displays checklist input fields and action buttons
class ChecklistSection extends StatelessWidget {
  const ChecklistSection({
    super.key,
    required this.items,
    required this.user,
    this.dueDate,
    this.priority,
    required this.category,
    required this.inLoop,
    required this.repeat,
    required this.onUserChanged,
    required this.onDueDateChanged,
    required this.onPriorityChanged,
    required this.onCategoryChanged,
    required this.onInLoopChanged,
    required this.onRepeatChanged,
    required this.onAddItem,
    required this.onRemoveItem,
    required this.onSubmit,
    this.isSubmitting = false,
    this.isValid = false,
  });

  final List<ChecklistItem> items;
  final String user;
  final DateTime? dueDate;
  final Priority? priority;
  final String category;
  final bool inLoop;
  final bool repeat;
  final ValueChanged<String> onUserChanged;
  final ValueChanged<DateTime?> onDueDateChanged;
  final ValueChanged<Priority> onPriorityChanged;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<bool> onInLoopChanged;
  final ValueChanged<bool> onRepeatChanged;
  final VoidCallback onAddItem;
  final ValueChanged<int> onRemoveItem;
  final VoidCallback onSubmit;
  final bool isSubmitting;
  final bool isValid;

  static const List<Priority> priorities = Priority.values;
  static const List<String> categories = [
    StringConstant.documentation,
    StringConstant.payment,
    StringConstant.visa,
    StringConstant.other,
  ];

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);
    final textStyles = AppTheme.textStyles(context);

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1F1A2E),
            Color(0xFF2A2338),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            StringConstant.addChecklist,
            style: textStyles.heading5.copyWith(
              fontWeight: FontWeight.bold,
            ),//
          ),
          const SizedBox(height: 24),
          // Checklist input fields in a row with icons
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  hint: StringConstant.user,
                  value: user,
                  onChanged: onUserChanged,
                  prefixIcon: Icons.person,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppDatePicker(
                  hint: StringConstant.dueDate,
                  value: dueDate,
                  onChanged: (date) => onDueDateChanged(date),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppDropdown<Priority>(
                  hintText: StringConstant.medium,
                  items: priorities,
                  itemLabel: (p) => p.label,
                  value: priority,
                  onChanged: (value) {
                    if (value != null) {
                      onPriorityChanged(value);
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppDropdown<String>(
                  hintText: StringConstant.category,
                  items: categories,
                  itemLabel: (c) => c,
                  value: category.isEmpty ? null : category,
                  onChanged: (value) {
                    if (value != null) {
                      onCategoryChanged(value);
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: colors.inputBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colors.borderSecondary.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.loop,
                        size: 20,
                        color: colors.textSecondary,
                      ),
                      const SizedBox(width: 12),
                      Checkbox(
                        value: inLoop,
                        onChanged: (value) => onInLoopChanged(value ?? false),
                        activeColor: colors.secondary,
                      ),
                      Text(
                        StringConstant.inLoop,
                        style: textStyles.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Action bar
          Row(
            children: [
              Checkbox(
                value: repeat,
                onChanged: (value) => onRepeatChanged(value ?? false),
                activeColor: colors.secondary,
              ),
                  Text(
                    StringConstant.repeat,
                style: textStyles.bodyMedium,
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: Icon(Icons.refresh, color: colors.textSecondary),
                onPressed: () {},
                    tooltip: StringConstant.refresh,
              ),
              IconButton(
                icon: Icon(Icons.access_time, color: colors.textSecondary),
                onPressed: () {},
                    tooltip: StringConstant.time,
              ),
              IconButton(
                icon: Icon(Icons.delete, color: colors.textSecondary),
                onPressed: () {},
                    tooltip: StringConstant.delete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

