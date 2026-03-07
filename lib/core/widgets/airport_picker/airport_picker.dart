import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_crm/core/theme/app_theme.dart';
import 'package:travel_crm/core/widgets/airport_picker/bloc/airport_picker_bloc.dart';

const Color _kDialogBackground = Color(0xFF161424);

/// Shows airport picker dialog: search field + filtered list.
/// [onSelect] is called with the selected airport string (e.g. "AMD - Ahmedabad").
void showAirportPicker(
  BuildContext context, {
  required ValueChanged<String> onSelect,
  Color? barrierColor,
  Color? dialogBackgroundColor,
}) {
  final bgColor = dialogBackgroundColor ?? _kDialogBackground;
  final barrier = barrierColor ?? Colors.black.withOpacity(0.7);

  showDialog<void>(
    context: context,
    barrierColor: barrier,
    builder: (context) => BlocProvider(
      create: (_) => AirportPickerCubit(),
      child: _AirportPickerDialog(
        backgroundColor: bgColor,
        onSelect: (selected) {
          onSelect(selected);
          Navigator.of(context).pop();
        },
        onClose: () => Navigator.of(context).pop(),
      ),
    ),
  );
}

/// Dialog: search + list of airports. List and filter state from [AirportPickerCubit].
class _AirportPickerDialog extends StatefulWidget {
  const _AirportPickerDialog({
    required this.backgroundColor,
    required this.onSelect,
    required this.onClose,
  });

  final Color backgroundColor;
  final ValueChanged<String> onSelect;
  final VoidCallback onClose;

  @override
  State<_AirportPickerDialog> createState() => _AirportPickerDialogState();
}

class _AirportPickerDialogState extends State<_AirportPickerDialog> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchFocus.requestFocus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);
    final textStyle = TextStyle(
      color: colors.textPrimary,
      fontSize: 14,
    );
    final hintStyle = textStyle.copyWith(color: Colors.white54);

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: MediaQuery.sizeOf(context).width > 400 ? 400 : double.infinity,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.6,
          ),
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocus,
                  style: textStyle,
                  decoration: InputDecoration(
                    hintText: 'Search airport or city',
                    hintStyle: hintStyle,
                    prefixIcon: Icon(
                      Icons.search,
                      color: textStyle.color ?? Colors.white,
                      size: 20,
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.08),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.white12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (value) =>
                      context.read<AirportPickerCubit>().searchChanged(value),
                ),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: BlocBuilder<AirportPickerCubit, AirportPickerState>(
                  builder: (context, state) {
                    if (state.filteredAirports.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'No airport found',
                          style: hintStyle.copyWith(fontSize: 14),
                        ),
                      );
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: state.filteredAirports.length,
                      itemBuilder: (context, index) {
                        final airport = state.filteredAirports[index];
                        return InkWell(
                          onTap: () => widget.onSelect(airport),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Text(
                              airport,
                              style: textStyle,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: TextButton(
                  onPressed: widget.onClose,
                  child: Text(
                    'Close',
                    style: hintStyle.copyWith(fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
