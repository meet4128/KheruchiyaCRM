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
    final borderColor = colors.secondary.withOpacity(0.5);
    final fieldDecoration = BoxDecoration(
      color: colors.inputBackground,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: borderColor, width: 1),
      boxShadow: [
        BoxShadow(
          color: colors.secondary.withOpacity(0.12),
          blurRadius: 8,
          spreadRadius: 0,
        ),
      ],
    );

    // No separate border/container — section is part of the screen; only inner elements have styling.
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title: Add Checklist
          Text(
            StringConstant.addChecklist,
            style: textStyles.heading5.copyWith(
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          // Top row: User, Due Date, Set Priority, Category, In Loop (icon + field, glowing border); max height 55px
          SizedBox(
            height: 55,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              Expanded(
                child: _ChecklistFieldWrap(
                  decoration: fieldDecoration,
                  icon: Icons.person_outline,
                  child: AppTextField(
                    hint: StringConstant.user,
                    value: user,
                    onChanged: onUserChanged,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ChecklistFieldWrap(
                  decoration: fieldDecoration,
                  icon: Icons.calendar_today_outlined,
                  child: AppDatePicker(
                    hint: StringConstant.dueDate,
                    value: dueDate,
                    onChanged: (date) => onDueDateChanged(date),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ChecklistFieldWrap(
                  decoration: fieldDecoration,
                  icon: Icons.bar_chart,
                  child: AppDropdown<Priority>(
                    hintText: StringConstant.setPriority,
                    items: priorities,
                    itemLabel: (p) => p.label,
                    value: priority,
                    onChanged: (value) {
                      if (value != null) onPriorityChanged(value);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ChecklistFieldWrap(
                  decoration: fieldDecoration,
                  icon: Icons.filter_list,
                  child: AppDropdown<String>(
                    hintText: StringConstant.category,
                    items: categories,
                    itemLabel: (c) => c,
                    value: category.isEmpty ? null : category,
                    onChanged: (value) {
                      if (value != null) onCategoryChanged(value);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  decoration: fieldDecoration,
                  child: Row(
                    children: [
                      Icon(Icons.loop, size: 20, color: colors.textSecondary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          StringConstant.inLoop,
                          style: textStyles.bodyMedium.copyWith(
                            color: colors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Divider: thin horizontal glowing line
          Container(
            height: 1,
            width: double.infinity,
            decoration: BoxDecoration(
              color: borderColor,
              boxShadow: [
                BoxShadow(
                  color: colors.secondary.withOpacity(0.3),
                  blurRadius: 4,
                  spreadRadius: 0,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Bottom row: Repeat checkbox, three icons, ellipsis, Submit button
          Row(
            children: [
              Checkbox(
                value: repeat,
                onChanged: (value) => onRepeatChanged(value ?? false),
                activeColor: colors.secondary,
                fillColor: WidgetStateProperty.resolveWith((_) => colors.inputBackground),
                side: BorderSide(color: colors.borderSecondary),
              ),
              const SizedBox(width: 8),
              Text(
                StringConstant.repeat,
                style: textStyles.bodyMedium.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: Icon(Icons.remove_circle_outline, color: colors.textSecondary, size: 22),
                onPressed: () {},
                tooltip: 'Remove',
              ),
              IconButton(
                icon: Icon(Icons.access_time, color: colors.textSecondary, size: 22),
                onPressed: () {},
                tooltip: StringConstant.time,
              ),
              IconButton(
                icon: Icon(Icons.volume_off, color: colors.textSecondary, size: 22),
                onPressed: () {},
                tooltip: 'Mute',
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.more_vert, color: colors.textSecondary, size: 22),
                onPressed: () {},
                tooltip: 'More',
              ),
              const Spacer(),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: isValid && !isSubmitting ? onSubmit : null,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          colors.secondary,
                          colors.secondary.withOpacity(0.85),
                          Color(0xFFEC4899),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: colors.secondary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: isSubmitting
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(colors.textOnPrimary),
                            ),
                          )
                        : Text(
                            StringConstant.submit,
                            style: textStyles.labelLarge.copyWith(
                              color: colors.textOnPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


/// Wraps a checklist field with icon + glowing border container (no label above).
class _ChecklistFieldWrap extends StatelessWidget {
  const _ChecklistFieldWrap({
    required this.decoration,
    required this.icon,
    required this.child,
  });

  final BoxDecoration decoration;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);
    return Container(
      decoration: decoration,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: colors.textSecondary),
          const SizedBox(width: 10),
          Expanded(child: child),
        ],
      ),
    );
  }
}

