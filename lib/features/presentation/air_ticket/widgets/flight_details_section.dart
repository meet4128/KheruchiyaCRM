import 'package:flutter/material.dart';
import 'package:travel_crm/core/constants/string_constants.dart';
import 'package:travel_crm/core/theme/app_theme.dart';
import 'package:travel_crm/core/widgets/app_date_picker.dart';
import 'package:travel_crm/core/widgets/app_dropdown.dart';
import 'package:travel_crm/core/widgets/app_swap_button.dart';
import 'package:travel_crm/core/widgets/app_text_field.dart';
import 'package:travel_crm/core/widgets/form_field_wrapper.dart';
import '../models/booking_type.dart';

/// Flight details section widget
/// Contains From, To, Departure Date, Return Date, Traveller & Class in a single row
class FlightDetailsSection extends StatelessWidget {
  const FlightDetailsSection({
    super.key,
    required this.from,
    required this.to,
    required this.departureDate,
    this.returnDate,
    required this.bookingType,
    required this.travellerCount,
    required this.classType,
    this.fromError,
    this.toError,
    this.departureDateError,
    this.returnDateError,
    this.travellerCountError,
    required this.onFromChanged,
    required this.onToChanged,
    required this.onDepartureDateChanged,
    this.onReturnDateChanged,
    required this.onSwapLocations,
    this.onTravellerCountChanged,
    this.onClassTypeChanged,
    this.onAddAnotherField,
  });

  final String from;
  final String to;
  final DateTime? departureDate;
  final DateTime? returnDate;
  final AirTicketBookingType? bookingType;
  final int travellerCount;
  final String classType;
  final String? fromError;
  final String? toError;
  final String? departureDateError;
  final String? returnDateError;
  final String? travellerCountError;
  final ValueChanged<String> onFromChanged;
  final ValueChanged<String> onToChanged;
  final ValueChanged<DateTime> onDepartureDateChanged;
  final ValueChanged<DateTime?>? onReturnDateChanged;
  final VoidCallback onSwapLocations;
  final ValueChanged<int>? onTravellerCountChanged;
  final ValueChanged<String>? onClassTypeChanged;
  final VoidCallback? onAddAnotherField;

  static const List<int> travellerCounts = [1, 2, 3, 4, 5, 6, 7, 8, 9];
  static const List<String> classTypes = [
    StringConstant.economy,
    StringConstant.business,
    StringConstant.first,
  ];

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);
    final textStyles = AppTheme.textStyles(context);
    final showReturnDate = bookingType == AirTicketBookingType.roundTrip;

    // Format traveller and class display
    final travellerClassDisplay = classType.isNotEmpty
        ? '$travellerCount Traveller${travellerCount > 1 ? 's' : ''}, $classType'
        : travellerCount > 0
            ? '$travellerCount Traveller${travellerCount > 1 ? 's' : ''}'
            : '';

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // From field
          _LocationField(
            label: StringConstant.from,
            isRequired: true,
            value: from.isNotEmpty ? from : StringConstant.defaultFromLocation,
            sublabel: from.isNotEmpty ? '' : StringConstant.defaultAirportFrom,
            errorText: fromError,
            onTap: () {
              // TODO: Open location picker
            },
          ),
          const SizedBox(width: 12),
          // Swap button
          Padding(
            padding: const EdgeInsets.only(top: 24),
            child: AppSwapButton(
              onSwap: onSwapLocations,
              size: 40,
              iconSize: 20,
            ),
          ),
          const SizedBox(width: 12),
          // To field
          _LocationField(
            label: StringConstant.to,
            isRequired: true,
            value: to.isNotEmpty ? to : StringConstant.defaultToLocation,
            sublabel: to.isNotEmpty ? '' : StringConstant.defaultAirportTo,
            errorText: toError,
            onTap: () {
              // TODO: Open location picker
            },
          ),
          const SizedBox(width: 12),
          // Departure date
          _DateField(
            label: StringConstant.departure,
            isRequired: true,
            value: departureDate,
            errorText: departureDateError,
            onTap: () {
              // Date picker will be handled by AppDatePicker
            },
            child: AppDatePicker(
              hint: StringConstant.selectDepartureDate,
              value: departureDate,
              errorText: departureDateError,
              onChanged: onDepartureDateChanged,
              firstDate: DateTime.now(),
              dateFormat: _formatDate,
            ),
          ),
          if (showReturnDate) ...[
            const SizedBox(width: 12),
            // Return date
            _DateField(
              label: StringConstant.returnLabel,
              isRequired: false,
              value: returnDate,
              errorText: returnDateError,
              onTap: () {
                // Date picker will be handled by AppDatePicker
              },
              child: AppDatePicker(
                hint: StringConstant.selectReturnDate,
                value: returnDate,
                errorText: returnDateError,
                onChangedNullable: onReturnDateChanged,
                firstDate: departureDate ?? DateTime.now(),
                dateFormat: _formatDate,
              ),
            ),
          ],
          const SizedBox(width: 12),
          // Traveller & Class
          _TravellerClassField(
            label: StringConstant.travellerAndClass,
            isRequired: true,
            value: travellerClassDisplay,
            errorText: travellerCountError,
            travellerCount: travellerCount,
            classType: classType,
            onTravellerChanged: onTravellerCountChanged,
            onClassChanged: onClassTypeChanged,
          ),
          if (onAddAnotherField != null) ...[
            const SizedBox(width: 12),
            // Add another field button
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: InkWell(
                onTap: onAddAnotherField,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF8B5CF6),  // Purple
                        Color(0xFFEC4899),  // Pink
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        StringConstant.addAnotherField,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Format date as "DAY, DD MMM"
  static String _formatDate(DateTime date) {
    const days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    const months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    
    final dayName = days[date.weekday - 1];
    final day = date.day.toString().padLeft(2, '0');
    final month = months[date.month - 1];
    
    return '$dayName, $day $month';
  }
}

/// Location field widget that displays airport code and full name
class _LocationField extends StatelessWidget {
  const _LocationField({
    required this.label,
    required this.value,
    required this.sublabel,
    this.isRequired = false,
    this.errorText,
    this.onTap,
  });

  final String label;
  final String value;
  final String sublabel;
  final bool isRequired;
  final String? errorText;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);
    final textStyles = AppTheme.textStyles(context);
    final isFromField = label == StringConstant.from;

    return SizedBox(
      width: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          Row(
            children: [
              Text(
                label,
                style: textStyles.formLabel.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              if (isRequired) ...[
                const SizedBox(width: 4),
                Text(
                  '*',
                  style: textStyles.formLabel.copyWith(
                    color: colors.error,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          // Value container
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: colors.inputBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: errorText != null
                      ? colors.error
                      : colors.inputBorder,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  if (isFromField) ...[
                    Icon(
                      Icons.flight_takeoff,
                      size: 18,
                      color: colors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          value,
                          style: textStyles.formInput.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (sublabel.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            sublabel,
                            style: textStyles.bodySmall.copyWith(
                              color: colors.textSecondary,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (errorText != null) ...[
            const SizedBox(height: 4),
            Text(
              errorText!,
              style: textStyles.formError.copyWith(
                color: colors.error,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Date field widget that displays formatted date
class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.child,
    this.isRequired = false,
    this.errorText,
    this.onTap,
  });

  final String label;
  final DateTime? value;
  final Widget child;
  final bool isRequired;
  final String? errorText;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: FormFieldWrapper(
        label: label,
        isRequired: isRequired,
        child: child,
      ),
    );
  }
}

/// Traveller & Class field widget that displays combined value
class _TravellerClassField extends StatelessWidget {
  const _TravellerClassField({
    required this.label,
    required this.value,
    required this.travellerCount,
    required this.classType,
    this.isRequired = false,
    this.errorText,
    this.onTravellerChanged,
    this.onClassChanged,
  });

  final String label;
  final String value;
  final int travellerCount;
  final String classType;
  final bool isRequired;
  final String? errorText;
  final ValueChanged<int>? onTravellerChanged;
  final ValueChanged<String>? onClassChanged;

  static const List<int> travellerCounts = [1, 2, 3, 4, 5, 6, 7, 8, 9];
  static const List<String> classTypes = [
    StringConstant.economy,
    StringConstant.business,
    StringConstant.first,
  ];

  void _showSelectionBottomSheet(BuildContext context) {
    final colors = AppTheme.colors(context);
    final textStyles = AppTheme.textStyles(context);
    int selectedTravellerCount = travellerCount;
    String selectedClassType = classType;

    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Traveller & Class',
                    style: textStyles.heading3.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Traveller Count Section
                  Text(
                    'Number of Travellers',
                    style: textStyles.formLabel.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: travellerCounts.map((count) {
                      final isSelected = count == selectedTravellerCount;
                      return InkWell(
                        onTap: () {
                          setState(() {
                            selectedTravellerCount = count;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? colors.secondary : colors.inputBackground,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected ? colors.secondary : colors.inputBorder,
                            ),
                          ),
                          child: Text(
                            '$count',
                            style: TextStyle(
                              color: isSelected ? colors.textOnPrimary : colors.textPrimary,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  // Class Type Section
                  Text(
                    'Class Type',
                    style: textStyles.formLabel.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: classTypes.map((type) {
                      final isSelected = type == selectedClassType;
                      return InkWell(
                        onTap: () {
                          setState(() {
                            selectedClassType = type;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? colors.secondary : colors.inputBackground,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected ? colors.secondary : colors.inputBorder,
                            ),
                          ),
                          child: Text(
                            type,
                            style: TextStyle(
                              color: isSelected ? colors.textOnPrimary : colors.textPrimary,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  // Apply Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (onTravellerChanged != null) {
                          onTravellerChanged!(selectedTravellerCount);
                        }
                        if (onClassChanged != null) {
                          onClassChanged!(selectedClassType);
                        }
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.secondary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Apply',
                        style: TextStyle(
                          color: colors.textOnPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);
    final textStyles = AppTheme.textStyles(context);

    return SizedBox(
      width: 220,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          Row(
            children: [
              Text(
                label,
                style: textStyles.formLabel.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              if (isRequired) ...[
                const SizedBox(width: 4),
                Text(
                  '*',
                  style: textStyles.formLabel.copyWith(
                    color: colors.error,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          // Value container - single display with dropdown
          InkWell(
            onTap: () => _showSelectionBottomSheet(context),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: colors.inputBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: errorText != null
                      ? colors.error
                      : colors.inputBorder,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      value.isNotEmpty ? value : '1 Traveller, Economy',
                      style: textStyles.formInput.copyWith(
                        color: colors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    Icons.arrow_drop_down,
                    color: colors.textSecondary,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
          if (errorText != null) ...[
            const SizedBox(height: 4),
            Text(
              errorText!,
              style: textStyles.formError.copyWith(
                color: colors.error,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

