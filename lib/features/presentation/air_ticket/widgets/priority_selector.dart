import 'package:flutter/material.dart';
import 'package:travel_crm/core/theme/app_theme.dart';
import '../models/priority.dart';

/// Priority selector widget
/// Displays pill-shaped buttons for High, Medium, Low with orange selected state
class PrioritySelector extends StatelessWidget {
  const PrioritySelector({
    super.key,
    required this.selectedPriority,
    required this.onChanged,
    this.errorText,
  });

  final Priority? selectedPriority;
  final ValueChanged<Priority> onChanged;
  final String? errorText;

  // Only show High, Medium, Low (exclude Urgent for form priority)
  static const List<Priority> formPriorities = [
    Priority.high,
    Priority.medium,
    Priority.low,
  ];

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Custom pill buttons with orange selected state
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: formPriorities.map((priority) {
            final isSelected = selectedPriority == priority;
            
            return InkWell(
              onTap: () => onChanged(priority),
              borderRadius: BorderRadius.circular(24),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Color(0xFFFF9800) // Orange color for selected
                      : colors.inputBackground.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSelected
                        ? Color(0xFFFF9800)
                        : colors.borderSecondary.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSelected) ...[
                      Icon(
                        Icons.check,
                        size: 18,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      priority.label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected
                            ? Colors.white
                            : colors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        
        // Error text
        if (errorText != null) ...[
          const SizedBox(height: 8),
          Text(
            errorText!,
            style: TextStyle(
              fontSize: 12,
              color: colors.error,
            ),
          ),
        ],
      ],
    );
  }
}




