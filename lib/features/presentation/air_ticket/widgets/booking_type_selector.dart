import 'package:flutter/material.dart';
import 'package:travel_crm/core/widgets/app_pill_selector.dart';
import '../models/booking_type.dart';

/// Booking type selector widget
/// Displays pill-shaped buttons for One Way, Round Trip, Multi City
class BookingTypeSelector extends StatelessWidget {
  const BookingTypeSelector({
    super.key,
    required this.selectedType,
    required this.onChanged,
    this.errorText,
  });

  final AirTicketBookingType? selectedType;
  final ValueChanged<AirTicketBookingType> onChanged;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return AppPillSelector<AirTicketBookingType>(
      items: AirTicketBookingType.values,
      itemLabel: (type) => type.label,
      selectedValue: selectedType,
      onChanged: onChanged,
      errorText: errorText,
      showCheckmark: true,
      spacing: 12,
    );
  }
}






