import 'package:flutter/material.dart';
import 'package:travel_crm/core/constants/string_constants.dart';
import 'package:travel_crm/core/theme/app_theme.dart';
import 'package:travel_crm/core/widgets/airport_picker/airport_picker.dart';
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
    this.showTravellerClass = true,
    this.showAddAnotherCity = false,
    this.addAnotherButtonLabel,
    this.onRemove,
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
  /// When true, show Traveller & Class in this section (typically first segment only).
  final bool showTravellerClass;
  /// When true, show Add another City/field button (typically last segment only).
  final bool showAddAnotherCity;
  /// Label for add button when [showAddAnotherCity] is true (e.g. "Add another City").
  final String? addAnotherButtonLabel;
  /// When non-null, show a delete button to remove this segment (extra segments only).
  final VoidCallback? onRemove;

  static const List<int> travellerCounts = [1, 2, 3, 4, 5, 6, 7, 8, 9];
  static const List<String> classTypes = [
    StringConstant.economy,
    StringConstant.business,
    StringConstant.first,
  ];

  static Future<void> _showDatePicker(
    BuildContext context, {
    required DateTime initialDate,
    required DateTime firstDate,
    ValueChanged<DateTime>? onSelected,
    ValueChanged<DateTime?>? onSelectedNullable,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime(firstDate.year + 2, 12, 31),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppTheme.colors(context).secondary,
              onPrimary: AppTheme.colors(context).textOnPrimary,
              surface: AppTheme.colors(context).surface,
              onSurface: AppTheme.colors(context).textPrimary,
            ),
            dialogBackgroundColor: AppTheme.colors(context).backgroundMedium,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      onSelected?.call(picked);
      onSelectedNullable?.call(picked);
    } else {
      onSelectedNullable?.call(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);

    // Format traveller and class display
    final travellerClassDisplay = classType.isNotEmpty
        ? '$travellerCount Traveller${travellerCount > 1 ? 's' : ''}, $classType'
        : travellerCount > 0
            ? '$travellerCount Traveller${travellerCount > 1 ? 's' : ''}'
            : StringConstant.defaultTraveller;

    return Container(
      decoration: BoxDecoration(
        color: colors.inputBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colors.borderSecondary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // From
              _LocationField(
                label: StringConstant.from,
                isRequired: true,
                value: from.isNotEmpty ? from : StringConstant.defaultFromLocation,
                sublabel: from.isNotEmpty ? '' : StringConstant.defaultAirportFrom,
                errorText: fromError,
                showBorder: true,
                onSelectAirport: onFromChanged,
              ),
              // Swap (square with light grey border)
              _SwapSegment(onSwap: onSwapLocations),
              // To
              _LocationField(
                label: StringConstant.to,
                isRequired: true,
                value: to.isNotEmpty ? to : StringConstant.defaultToLocation,
                sublabel: to.isNotEmpty ? '' : StringConstant.defaultAirportTo,
                errorText: toError,
                showBorder: true,
                onSelectAirport: onToChanged,
              ),
              // Departure
              _DateField(
                label: StringConstant.departure,
                isRequired: true,
                value: departureDate,
                errorText: departureDateError,
                dateFormat: _formatDate,
                hint: StringConstant.selectDepartureDate,
                onTap: () => _showDatePicker(
                  context,
                  initialDate: departureDate ?? DateTime.now(),
                  firstDate: DateTime.now(),
                  onSelected: onDepartureDateChanged,
                ),
              ),
              // Return (always visible, can be blank)
              _DateField(
                label: StringConstant.returnLabel,
                isRequired: false,
                value: returnDate,
                errorText: returnDateError,
                dateFormat: _formatDate,
                hint: '',
                onTap: () => _showDatePicker(
                  context,
                  initialDate: returnDate ?? departureDate ?? DateTime.now(),
                  firstDate: departureDate ?? DateTime.now(),
                  onSelectedNullable: onReturnDateChanged,
                ),
              ),
              // Traveller & Class (first segment only per design)
              if (showTravellerClass)
                _TravellerClassField(
                  label: StringConstant.travellerAndClass,
                  isRequired: true,
                  value: travellerClassDisplay,
                  errorText: travellerCountError,
                  travellerCount: travellerCount,
                  classType: classType,
                  onTravellerChanged: onTravellerCountChanged,
                  onClassChanged: onClassTypeChanged,
                  showBorder: true,
                ),
              if (showAddAnotherCity && onAddAnotherField != null)
                _AddAnotherFieldButton(
                  onTap: onAddAnotherField!,
                  label: addAnotherButtonLabel ?? StringConstant.addAnotherField,
                ),
              if (onRemove != null) _RemoveSegmentButton(onRemove: onRemove!),
            ],
          ),
        ),
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

/// Segment with light grey right border
Widget _segmentBorder(Widget child, Color borderColor, {bool showBorder = true}) {
  return Container(
    decoration: showBorder
        ? BoxDecoration(
            border: Border(
              right: BorderSide(
                color: borderColor.withOpacity(0.4),
                width: 1,
              ),
            ),
          )
        : null,
    child: child,
  );
}

/// Swap segment: vertical divider with T-junction (horizontal line at top) and white rounded swap button centered on the line.
class _SwapSegment extends StatelessWidget {
  const _SwapSegment({required this.onSwap});

  final VoidCallback onSwap;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);
    final dividerColor = colors.borderSecondary.withOpacity(0.5);
    const segmentWidth = 56.0;

    return SizedBox(
      width: segmentWidth,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          // Horizontal gray line at top (T-junction with vertical)
          Container(
            height: 1,
            width: double.infinity,
            color: dividerColor,
          ),
          // Vertical divider with swap button centered on it
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Vertical gray divider line (full height, centered)
                Center(
                  child: Container(
                    width: 1,
                    color: dividerColor,
                  ),
                ),
                // White rounded button with two-way arrows centered on the line
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onSwap,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.arrow_forward,
                            size: 14,
                            color: Colors.grey.shade700,
                          ),
                          const SizedBox(height: 2),
                          Icon(
                            Icons.arrow_back,
                            size: 14,
                            color: Colors.grey.shade700,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Delete segment button (trash icon) for extra flight segments
class _RemoveSegmentButton extends StatelessWidget {
  const _RemoveSegmentButton({required this.onRemove});

  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Align(
        alignment: Alignment.center,
        child: Material(
          color: Colors.transparent,
          child: IconButton(
            onPressed: onRemove,
            icon: Icon(
              Icons.delete_outline,
              color: colors.textSecondary,
              size: 22,
            ),
            tooltip: 'Remove this segment',
            style: IconButton.styleFrom(
              backgroundColor: colors.inputBackground.withOpacity(0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Add another field/city button (purple gradient)
class _AddAnotherFieldButton extends StatelessWidget {
  const _AddAnotherFieldButton({
    required this.onTap,
    this.label,
  });

  final VoidCallback onTap;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Align(
        alignment: Alignment.center,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color(0xFF8B5CF6), // deep purple
                    Color(0xFFEC4899), // magenta/pink
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        label ?? StringConstant.addAnotherField,
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
      ),
    );
  }
}

/// Location field widget that displays airport code and full name.
/// When [onSelectAirport] is set, tap opens airport picker dialog and calls it with selected value.
class _LocationField extends StatelessWidget {
  const _LocationField({
    required this.label,
    required this.value,
    required this.sublabel,
    this.isRequired = false,
    this.errorText,
    this.showBorder = false,
    this.onTap,
    this.onSelectAirport,
  });

  final String label;
  final String value;
  final String sublabel;
  final bool isRequired;
  final String? errorText;
  final bool showBorder;
  final VoidCallback? onTap;
  final ValueChanged<String>? onSelectAirport;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);
    final textStyles = AppTheme.textStyles(context);

    final content = SizedBox(
      width: 200,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  label,
                  style: textStyles.formLabel.copyWith(
                    color: colors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                if (isRequired) ...[
                  const SizedBox(width: 4),
                  Text(
                    '*',
                    style: textStyles.formLabel.copyWith(
                      color: colors.error,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: onSelectAirport != null
                  ? () => showAirportPicker(
                        context,
                        onSelect: onSelectAirport!,
                      )
                  : onTap,
              borderRadius: BorderRadius.circular(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: textStyles.formInput.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                      fontSize: 14,
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
            if (errorText != null) ...[
              const SizedBox(height: 4),
              Text(
                errorText!,
                style: textStyles.formError.copyWith(
                  color: colors.error,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );

    return _segmentBorder(
      content,
      colors.borderSecondary,
      showBorder: showBorder,
    );
  }
}

/// Date field widget: label + value/hint, tap opens date picker
class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.dateFormat,
    required this.hint,
    required this.onTap,
    this.isRequired = false,
    this.errorText,
  });

  final String label;
  final DateTime? value;
  final String Function(DateTime) dateFormat;
  final String hint;
  final VoidCallback onTap;
  final bool isRequired;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);
    final textStyles = AppTheme.textStyles(context);
    final displayText = value != null ? dateFormat(value!) : (hint.isNotEmpty ? hint : '');

    final content = SizedBox(
      width: 160,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  label,
                  style: textStyles.formLabel.copyWith(
                    color: colors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                if (isRequired) ...[
                  const SizedBox(width: 4),
                  Text(
                    '*',
                    style: textStyles.formLabel.copyWith(
                      color: colors.error,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(8),
              child: Text(
                displayText,
                style: textStyles.formInput.copyWith(
                  fontWeight: FontWeight.w600,
                  color: value != null ? colors.textPrimary : colors.textSecondary,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (errorText != null) ...[
              const SizedBox(height: 4),
              Text(
                errorText!,
                style: textStyles.formError.copyWith(
                  color: colors.error,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );

    return _segmentBorder(
      content,
      colors.borderSecondary,
      showBorder: true,
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
    this.showBorder = false,
    this.onTravellerChanged,
    this.onClassChanged,
  });

  final String label;
  final String value;
  final int travellerCount;
  final String classType;
  final bool isRequired;
  final String? errorText;
  final bool showBorder;
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

    final content = SizedBox(
      width: 220,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  label,
                  style: textStyles.formLabel.copyWith(
                    color: colors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                if (isRequired) ...[
                  const SizedBox(width: 4),
                  Text(
                    '*',
                    style: textStyles.formLabel.copyWith(
                      color: colors.error,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _showSelectionBottomSheet(context),
              borderRadius: BorderRadius.circular(8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      value.isNotEmpty ? value : StringConstant.defaultTraveller,
                      style: textStyles.formInput.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                        fontSize: 14,
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
            if (errorText != null) ...[
              const SizedBox(height: 4),
              Text(
                errorText!,
                style: textStyles.formError.copyWith(
                  color: colors.error,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );

    return _segmentBorder(
      content,
      colors.borderSecondary,
      showBorder: showBorder,
    );
  }
}

