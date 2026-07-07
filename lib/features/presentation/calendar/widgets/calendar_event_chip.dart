import 'package:flutter/material.dart';
import 'package:travel_crm/core/theme/app_colors.dart';
import 'package:travel_crm/core/theme/app_theme.dart';

import '../models/calendar_event_ui.dart';

/// A compact event pill inside a month-grid day cell.
class CalendarEventChip extends StatelessWidget {
  const CalendarEventChip({super.key, required this.event, this.onTap});

  final CalendarEventUi event;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);
    final base = _colorFor(event.type, colors);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 3),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: base.withValues(alpha: 0.22),
          borderRadius: BorderRadius.circular(4),
          border: Border(left: BorderSide(color: base, width: 2)),
        ),
        child: Row(
          children: [
            Container(
              width: 5,
              height: 5,
              margin: const EdgeInsets.only(right: 5),
              decoration: BoxDecoration(color: base, shape: BoxShape.circle),
            ),
            Expanded(
              child: Text(
                event.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: colors.textPrimary, fontSize: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Color _colorFor(String type, AppColors colors) {
    switch (type) {
      case 'follow_up':
        return colors.success;
      case 'payment':
        return colors.warning;
      default:
        return colors.secondaryLight;
    }
  }
}
