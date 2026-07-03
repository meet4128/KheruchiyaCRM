import 'package:flutter/material.dart';
import 'package:travel_crm/core/widgets/app_multi_pill_selector.dart';
import '../models/meal_plan.dart';

/// Multi-select pill selector for meal plan.
class MealPlanSelector extends StatelessWidget {
  const MealPlanSelector({
    super.key,
    required this.selectedMealPlans,
    required this.onToggle,
  });

  final Set<MealPlan> selectedMealPlans;
  final ValueChanged<MealPlan> onToggle;

  @override
  Widget build(BuildContext context) {
    return AppMultiPillSelector<MealPlan>(
      items: MealPlan.values,
      itemLabel: (plan) => plan.label,
      selectedValues: selectedMealPlans,
      onToggle: onToggle,
      showCheckmark: true,
      spacing: 12,
    );
  }
}
