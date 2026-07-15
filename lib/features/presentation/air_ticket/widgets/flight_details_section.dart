import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_crm/core/constants/string_constants.dart';
import 'package:travel_crm/core/theme/app_theme.dart';
import 'package:travel_crm/core/widgets/airport_picker/airport_picker.dart';
import '../models/booking_type.dart';
import '../models/traveller_breakdown.dart';
import '../bloc/traveller_class_picker_cubit.dart';

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
    required this.adultCount,
    required this.childCount,
    required this.infantCount,
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
    this.onTravellerBreakdownChanged,
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
  final int adultCount;
  final int childCount;
  final int infantCount;
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
  final ValueChanged<TravellerBreakdown>? onTravellerBreakdownChanged;
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

  /// Parses stored airport string "CODE - City|Airport Name|Country" (country optional).
  static ({String value, String sublabel}) _airportDisplay(String raw, String defaultValue, String defaultSublabel) {
    if (raw.isEmpty) return (value: defaultValue, sublabel: defaultSublabel);
    final parts = raw.split('|');
    if (parts.length == 1) return (value: raw.trim(), sublabel: '');
    return (
      value: parts[0].trim(),
      sublabel: parts[1].trim(),
    );
  }

  static Future<void> _showDatePicker(
    BuildContext context, {
    required DateTime initialDate,
    required DateTime firstDate,
    ValueChanged<DateTime>? onSelected,
    ValueChanged<DateTime?>? onSelectedNullable,
  }) async {
    final colors = AppTheme.colors(context);
    // Custom dialog with CalendarDatePicker so tapping a day selects it
    // immediately (no OK/Cancel confirmation step).
    final picked = await showDialog<DateTime>(
      context: context,
      builder: (dialogContext) {
        return Theme(
          data: Theme.of(dialogContext).copyWith(
            colorScheme: ColorScheme.dark(
              primary: colors.secondary,
              onPrimary: colors.textOnPrimary,
              surface: colors.surface,
              onSurface: colors.textPrimary,
            ),
            dialogBackgroundColor: colors.backgroundMedium,
          ),
          child: Dialog(
            backgroundColor: colors.backgroundMedium,
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 40,
              vertical: 24,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: SizedBox(
                width: 360,
                height: 400,
                child: CalendarDatePicker(
                  initialDate: initialDate,
                  firstDate: firstDate,
                  lastDate: DateTime(firstDate.year + 2, 12, 31),
                  onDateChanged: (date) => Navigator.pop(dialogContext, date),
                ),
              ),
            ),
          ),
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

    final travellerClassDisplay = TravellerBreakdown(
      adultCount: adultCount,
      childCount: childCount,
      infantCount: infantCount,
    ).displayLabelWithClass(classType.isNotEmpty ? classType : null);

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
                value: _airportDisplay(from, StringConstant.defaultFromLocation, StringConstant.defaultAirportFrom).value,
                sublabel: _airportDisplay(from, StringConstant.defaultFromLocation, StringConstant.defaultAirportFrom).sublabel,
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
                value: _airportDisplay(to, StringConstant.defaultToLocation, StringConstant.defaultAirportTo).value,
                sublabel: _airportDisplay(to, StringConstant.defaultToLocation, StringConstant.defaultAirportTo).sublabel,
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
              // Return — only for Round Trip (mandatory; same date selection as Departure)
              if (bookingType == AirTicketBookingType.roundTrip)
                _DateField(
                  label: StringConstant.returnLabel,
                  isRequired: true,
                  value: returnDate,
                  errorText: returnDateError,
                  dateFormat: _formatDate,
                  hint: StringConstant.selectReturnDate,
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
                  adultCount: adultCount,
                  childCount: childCount,
                  infantCount: infantCount,
                  classType: classType,
                  onTravellerBreakdownChanged: onTravellerBreakdownChanged,
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
/// When [onSelectAirport] is set, tap opens airport picker bottom sheet and calls it with selected value.
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
                  ? () => showAirportPickerBottomSheet(
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
    required this.adultCount,
    required this.childCount,
    required this.infantCount,
    required this.classType,
    this.isRequired = false,
    this.errorText,
    this.showBorder = false,
    this.onTravellerBreakdownChanged,
    this.onClassChanged,
  });

  final String label;
  final String value;
  final int adultCount;
  final int childCount;
  final int infantCount;
  final String classType;
  final bool isRequired;
  final String? errorText;
  final bool showBorder;
  final ValueChanged<TravellerBreakdown>? onTravellerBreakdownChanged;
  final ValueChanged<String>? onClassChanged;

  void _showSelectionBottomSheet(BuildContext context) {
    final colors = AppTheme.colors(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext sheetContext) {
        return BlocProvider(
          create: (_) => TravellerClassPickerCubit(
            initialBreakdown: TravellerBreakdown(
              adultCount: adultCount,
              childCount: childCount,
              infantCount: infantCount,
            ),
            initialClassType: classType,
          ),
          child: _TravellerClassSheetContent(
            onApply: (breakdown, classType) {
              onTravellerBreakdownChanged?.call(breakdown);
              onClassChanged?.call(classType);
              Navigator.pop(sheetContext);
            },
          ),
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

/// Bottom sheet content for Traveller & Class selection; uses [TravellerClassPickerCubit], no setState.
class _TravellerClassSheetContent extends StatelessWidget {
  const _TravellerClassSheetContent({required this.onApply});

  final void Function(TravellerBreakdown breakdown, String classType) onApply;

  static const List<String> _classTypes = [
    StringConstant.economy,
    StringConstant.business,
    StringConstant.first,
  ];

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);
    final textStyles = AppTheme.textStyles(context);

    return BlocBuilder<TravellerClassPickerCubit, TravellerClassPickerState>(
      builder: (context, state) {
        final cubit = context.read<TravellerClassPickerCubit>();
        final canApply = state.canApply;

        return SafeArea(
          child: SingleChildScrollView(
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
              Text(
                'Number of Travellers',
                style: textStyles.formLabel.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              _TravellerCounterRow(
                label: StringConstant.adultTravellerLabel,
                count: state.adultCount,
                canDecrement: state.adultCount > 1,
                canIncrement:
                    state.totalCount < TravellerBreakdown.maxTravellers,
                onDecrement: cubit.decrementAdult,
                onIncrement: cubit.incrementAdult,
              ),
              const SizedBox(height: 12),
              _TravellerCounterRow(
                label: StringConstant.childTravellerLabel,
                count: state.childCount,
                canDecrement: state.childCount > 0,
                canIncrement:
                    state.totalCount < TravellerBreakdown.maxTravellers,
                onDecrement: cubit.decrementChild,
                onIncrement: cubit.incrementChild,
              ),
              const SizedBox(height: 12),
              _TravellerCounterRow(
                label: StringConstant.infantTravellerLabel,
                count: state.infantCount,
                canDecrement: state.infantCount > 0,
                canIncrement: state.totalCount <
                        TravellerBreakdown.maxTravellers &&
                    state.infantCount < state.adultCount,
                onDecrement: cubit.decrementInfant,
                onIncrement: cubit.incrementInfant,
              ),
              const SizedBox(height: 24),
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
                children: _classTypes.map((type) {
                  final isSelected = type == state.classType;
                  return InkWell(
                    onTap: () => cubit.selectClassType(type),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colors.secondary
                            : colors.inputBackground,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? colors.secondary
                              : colors.inputBorder,
                        ),
                      ),
                      child: Text(
                        type,
                        style: TextStyle(
                          color: isSelected
                              ? colors.textOnPrimary
                              : colors.textPrimary,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: canApply
                      ? () => onApply(state.breakdown, state.classType)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.secondary,
                    disabledBackgroundColor:
                        colors.secondary.withOpacity(0.4),
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
          ),
        );
      },
    );
  }
}

/// Single traveller category row with minus / count / plus controls.
class _TravellerCounterRow extends StatelessWidget {
  const _TravellerCounterRow({
    required this.label,
    required this.count,
    required this.canDecrement,
    required this.canIncrement,
    required this.onDecrement,
    required this.onIncrement,
  });

  final String label;
  final int count;
  final bool canDecrement;
  final bool canIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);
    final textStyles = AppTheme.textStyles(context);

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: textStyles.bodyMedium.copyWith(
              color: colors.textPrimary,
            ),
          ),
        ),
        _CounterButton(
          icon: Icons.remove,
          enabled: canDecrement,
          onTap: onDecrement,
        ),
        SizedBox(
          width: 36,
          child: Text(
            '$count',
            textAlign: TextAlign.center,
            style: textStyles.formInput.copyWith(
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),
        ),
        _CounterButton(
          icon: Icons.add,
          enabled: canIncrement,
          onTap: onIncrement,
        ),
      ],
    );
  }
}

class _CounterButton extends StatelessWidget {
  const _CounterButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: enabled
                ? colors.inputBackground
                : colors.inputBackground.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: enabled
                  ? colors.inputBorder
                  : colors.inputBorder.withOpacity(0.4),
            ),
          ),
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 18,
            color: enabled ? colors.textPrimary : colors.textSecondary,
          ),
        ),
      ),
    );
  }
}

