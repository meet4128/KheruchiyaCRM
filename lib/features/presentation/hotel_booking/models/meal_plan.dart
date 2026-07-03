/// Meal plan options for hotel booking (single-select).
enum MealPlan {
  continental('Continental Plan'),
  onlyBreakfast('Only Breakfast'),
  breakfastDinner('Breakfast & Dinner'),
  allMeal('All Meal');

  const MealPlan(this.label);
  final String label;
}
