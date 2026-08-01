import 'package:flutter/material.dart';
import 'package:travel_crm/core/constants/string_constants.dart';
import 'package:travel_crm/core/theme/app_theme.dart';
import 'package:travel_crm/core/widgets/date_range_picker/app_date_range_picker.dart';
import '../models/room_guests.dart';

/// Top search-summary bar for the hotel booking form.
/// Four segments: City or Location | Check-In | Check Out | Room & Guests.
class HotelSearchBar extends StatelessWidget {
  const HotelSearchBar({
    super.key,
    required this.city,
    required this.checkInDate,
    this.checkInDateEnd,
    required this.checkOutDate,
    this.checkOutDateEnd,
    required this.rooms,
    required this.adults,
    required this.onCityChanged,
    required this.onCheckInChanged,
    required this.onCheckInEndChanged,
    required this.onCheckOutChanged,
    required this.onCheckOutEndChanged,
    required this.onRoomsChanged,
    required this.onAdultsChanged,
    this.cityError,
    this.checkInError,
    this.checkOutError,
    this.roomGuestsError,
  });

  final String city;
  final DateTime? checkInDate;

  /// End of the check-in flexible window (renders a range when after start).
  final DateTime? checkInDateEnd;
  final DateTime? checkOutDate;

  /// End of the check-out flexible window (renders a range when after start).
  final DateTime? checkOutDateEnd;
  final int rooms;
  final int adults;
  final ValueChanged<String> onCityChanged;
  final ValueChanged<DateTime> onCheckInChanged;
  final ValueChanged<DateTime?> onCheckInEndChanged;
  final ValueChanged<DateTime> onCheckOutChanged;
  final ValueChanged<DateTime?> onCheckOutEndChanged;
  final ValueChanged<int> onRoomsChanged;
  final ValueChanged<int> onAdultsChanged;
  final String? cityError;
  final String? checkInError;
  final String? checkOutError;
  final String? roomGuestsError;

  static const List<String> _months = [
    'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
    'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC',
  ];
  static const List<String> _weekdays = [
    'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN',
  ];

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final weekday = _weekdays[date.weekday - 1];
    return '$weekday, ${date.day} ${_months[date.month - 1]}';
  }

  /// Displays a single date, or a flexible window "07 Aug – 09 Aug" when [end]
  /// is a real day after [start] (mirrors the Air Ticket date field).
  String _formatWindow(DateTime? start, DateTime? end) {
    if (start == null) return '';
    if (end == null || !end.isAfter(start)) return _formatDate(start);
    return '${formatAppDateCompact(start)} – ${formatAppDateCompact(end)}';
  }

  /// Opens the range calendar for the **check-in** flexible window: 1st tap =
  /// window start, 2nd tap = window end. Same-day (single day) is allowed and
  /// carries no window end.
  Future<void> _pickCheckInWindow(BuildContext context) async {
    final now = DateTime.now();
    final result = await showAppDateRangePicker(
      context,
      initialStart: checkInDate,
      initialEnd: checkInDateEnd,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 5, 12, 31),
    );
    if (result != null) {
      onCheckInChanged(result.start);
      onCheckInEndChanged(result.end);
    }
  }

  /// Opens the range calendar for the **check-out** flexible window. The window
  /// cannot start before the check-in day.
  Future<void> _pickCheckOutWindow(BuildContext context) async {
    final now = DateTime.now();
    final result = await showAppDateRangePicker(
      context,
      initialStart: checkOutDate,
      initialEnd: checkOutDateEnd,
      firstDate: checkInDate ?? DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 5, 12, 31),
    );
    if (result != null) {
      onCheckOutChanged(result.start);
      onCheckOutEndChanged(result.end);
    }
  }

  Future<void> _editRoomGuests(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (_) => _RoomGuestsDialog(
        rooms: rooms,
        adults: adults,
        onRoomsChanged: onRoomsChanged,
        onAdultsChanged: onAdultsChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);

    return Container(
      decoration: BoxDecoration(
        color: colors.inputBackground.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.borderSecondary.withOpacity(0.5), width: 1),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: _CitySegment(
                city: city,
                errorText: cityError,
                onChanged: onCityChanged,
              ),
            ),
            _divider(colors),
            Expanded(
              flex: 2,
              child: _TapSegment(
                label: StringConstant.checkIn,
                value: _formatWindow(checkInDate, checkInDateEnd),
                hint: StringConstant.selectCheckInWindow,
                errorText: checkInError,
                onTap: () => _pickCheckInWindow(context),
              ),
            ),
            _divider(colors),
            Expanded(
              flex: 2,
              child: _TapSegment(
                label: StringConstant.checkOut,
                value: _formatWindow(checkOutDate, checkOutDateEnd),
                hint: StringConstant.selectCheckOutWindow,
                errorText: checkOutError,
                onTap: () => _pickCheckOutWindow(context),
              ),
            ),
            _divider(colors),
            Expanded(
              flex: 2,
              child: _TapSegment(
                label: StringConstant.roomAndGuests,
                value: RoomGuests.displayLabel(rooms: rooms, adults: adults),
                hint: '',
                errorText: roomGuestsError,
                onTap: () => _editRoomGuests(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider(dynamic colors) => Container(
        width: 1,
        color: colors.borderSecondary.withOpacity(0.4),
      );
}

/// Segment label style helpers shared across segments.
class _SegmentLabel extends StatelessWidget {
  const _SegmentLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);
    final textStyles = AppTheme.textStyles(context);
    return Text(
      label,
      style: textStyles.bodySmall.copyWith(color: colors.textSecondary),
    );
  }
}

/// City segment with an inline editable text field.
class _CitySegment extends StatefulWidget {
  const _CitySegment({
    required this.city,
    required this.onChanged,
    this.errorText,
  });

  final String city;
  final ValueChanged<String> onChanged;
  final String? errorText;

  @override
  State<_CitySegment> createState() => _CitySegmentState();
}

class _CitySegmentState extends State<_CitySegment> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.city);
  }

  @override
  void didUpdateWidget(covariant _CitySegment oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.city != _controller.text) {
      _controller.text = widget.city;
      _controller.selection =
          TextSelection.collapsed(offset: _controller.text.length);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);
    final textStyles = AppTheme.textStyles(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const _SegmentLabel(StringConstant.cityOrLocation),
          const SizedBox(height: 4),
          TextField(
            controller: _controller,
            onChanged: widget.onChanged,
            style: textStyles.bodyLarge.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
              hintText: StringConstant.enterCityOrLocation,
              hintStyle: textStyles.bodyLarge.copyWith(color: colors.textTertiary),
            ),
          ),
          if (widget.errorText != null) ...[
            const SizedBox(height: 4),
            Text(
              widget.errorText!,
              style: textStyles.formError.copyWith(color: colors.error),
            ),
          ],
        ],
      ),
    );
  }
}

/// Tappable segment showing a label + value (or hint) that opens a picker.
class _TapSegment extends StatelessWidget {
  const _TapSegment({
    required this.label,
    required this.value,
    required this.hint,
    required this.onTap,
    this.errorText,
  });

  final String label;
  final String value;
  final String hint;
  final VoidCallback onTap;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);
    final textStyles = AppTheme.textStyles(context);
    final hasValue = value.isNotEmpty;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _SegmentLabel(label),
            const SizedBox(height: 4),
            Text(
              hasValue ? value : hint,
              style: textStyles.bodyLarge.copyWith(
                color: hasValue ? colors.textPrimary : colors.textTertiary,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (errorText != null) ...[
              const SizedBox(height: 4),
              Text(
                errorText!,
                style: textStyles.formError.copyWith(color: colors.error),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Dialog with rooms + adults steppers.
class _RoomGuestsDialog extends StatefulWidget {
  const _RoomGuestsDialog({
    required this.rooms,
    required this.adults,
    required this.onRoomsChanged,
    required this.onAdultsChanged,
  });

  final int rooms;
  final int adults;
  final ValueChanged<int> onRoomsChanged;
  final ValueChanged<int> onAdultsChanged;

  @override
  State<_RoomGuestsDialog> createState() => _RoomGuestsDialogState();
}

class _RoomGuestsDialogState extends State<_RoomGuestsDialog> {
  late int _rooms;
  late int _adults;

  @override
  void initState() {
    super.initState();
    _rooms = widget.rooms;
    _adults = widget.adults;
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);
    final textStyles = AppTheme.textStyles(context);

    return Dialog(
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              StringConstant.roomAndGuests,
              style: textStyles.heading6.copyWith(color: colors.textPrimary),
            ),
            const SizedBox(height: 20),
            _StepperRow(
              label: StringConstant.rooms,
              value: _rooms,
              minValue: 1,
              maxValue: RoomGuests.maxRooms,
              onChanged: (v) {
                setState(() => _rooms = v);
                widget.onRoomsChanged(v);
              },
            ),
            const SizedBox(height: 16),
            _StepperRow(
              label: StringConstant.adults,
              value: _adults,
              minValue: 1,
              maxValue: RoomGuests.maxAdults,
              onChanged: (v) {
                setState(() => _adults = v);
                widget.onAdultsChanged(v);
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  backgroundColor: colors.secondary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  StringConstant.continueAction,
                  style: textStyles.labelLarge.copyWith(
                    color: colors.textOnPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A single themed stepper row (label + minus / value / plus).
class _StepperRow extends StatelessWidget {
  const _StepperRow({
    required this.label,
    required this.value,
    required this.minValue,
    required this.maxValue,
    required this.onChanged,
  });

  final String label;
  final int value;
  final int minValue;
  final int maxValue;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);
    final textStyles = AppTheme.textStyles(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: textStyles.bodyLarge.copyWith(color: colors.textPrimary),
        ),
        Row(
          children: [
            _StepperButton(
              icon: Icons.remove,
              enabled: value > minValue,
              onTap: () => onChanged(value - 1),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '$value',
                style: textStyles.bodyLarge.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            _StepperButton(
              icon: Icons.add,
              enabled: value < maxValue,
              onTap: () => onChanged(value + 1),
            ),
          ],
        ),
      ],
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({
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
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: enabled
                ? colors.secondary.withOpacity(0.8)
                : colors.borderSecondary.withOpacity(0.4),
          ),
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled ? colors.secondary : colors.textTertiary,
        ),
      ),
    );
  }
}
