import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_crm/core/theme/app_colors.dart';
import 'package:travel_crm/core/theme/app_theme.dart';

import '../bloc/calendar_bloc.dart';
import '../bloc/calendar_event.dart';
import '../bloc/calendar_state.dart';
import '../models/calendar_category.dart';

/// The three category tabs (All Events / Follow Up / Payment) with badge counts.
class CalendarCategoryTabs extends StatelessWidget {
  const CalendarCategoryTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CalendarBloc, CalendarState>(
      builder: (context, state) {
        return Row(
          children: [
            for (final category in CalendarCategory.values) ...[
              Expanded(
                child: _CategoryTab(
                  category: category,
                  count: state.countFor(category),
                  selected: state.category == category,
                  onTap: () => context
                      .read<CalendarBloc>()
                      .add(CalendarCategoryChanged(category)),
                ),
              ),
              if (category != CalendarCategory.values.last)
                const SizedBox(width: 12),
            ],
          ],
        );
      },
    );
  }
}

class _CategoryTab extends StatelessWidget {
  const _CategoryTab({
    required this.category,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final CalendarCategory category;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);
    final textStyles = AppTheme.textStyles(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        decoration: BoxDecoration(
          gradient: selected
              ? LinearGradient(colors: [colors.accent, colors.secondary])
              : null,
          color: selected ? null : colors.backgroundMedium,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? colors.secondary : colors.borderPrimary,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                category.label,
                overflow: TextOverflow.ellipsis,
                style: textStyles.bodyMedium.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            _Badge(count: count, category: category, colors: colors),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.count,
    required this.category,
    required this.colors,
  });

  final int count;
  final CalendarCategory category;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final badgeColor = switch (category) {
      CalendarCategory.all => colors.accentLight,
      CalendarCategory.followUp => colors.info,
      CalendarCategory.payment => colors.warning,
    };
    return Container(
      constraints: const BoxConstraints(minWidth: 24),
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 7),
      alignment: Alignment.center,
      decoration: BoxDecoration(color: badgeColor, shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(12)),
      child: Text(
        '$count',
        style: TextStyle(
          color: colors.textOnPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
