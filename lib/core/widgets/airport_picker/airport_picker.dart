import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_crm/core/theme/app_theme.dart';
import 'package:travel_crm/core/widgets/airport_picker/bloc/airport_search_bloc.dart';
import 'package:travel_crm/core/widgets/airport_picker/bloc/airport_search_event.dart';
import 'package:travel_crm/core/widgets/airport_picker/bloc/airport_search_state.dart';
import 'package:travel_crm/data/repositories/airport_repository.dart';
import 'package:travel_crm/core/network/airport_api_client.dart';

const Color _kDialogBackground = Color(0xFF161424);

/// Shows airport picker dialog: search field + API-driven list.
/// [onSelect] is called with the selected airport string (e.g. "AMD - Ahmedabad").
void showAirportPicker(
  BuildContext context, {
  required ValueChanged<String> onSelect,
  Color? barrierColor,
  Color? dialogBackgroundColor,
}) {
  final bgColor = dialogBackgroundColor ?? _kDialogBackground;
  final barrier = barrierColor ?? Colors.black.withOpacity(0.7);

  final dio = createAirportApiDio();
  final apiClient = AirportApiClient(dio);
  final repository = AirportRepository(apiClient: apiClient);

  showDialog<void>(
    context: context,
    barrierColor: barrier,
    builder: (context) => BlocProvider(
      create: (_) => AirportSearchBloc(repository: repository),
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

/// Shows airport picker in a bottom sheet. Use for From/To in flight details.
/// [onSelect] is called with the selected airport string; sheet closes after selection.
void showAirportPickerBottomSheet(
  BuildContext context, {
  required ValueChanged<String> onSelect,
}) {
  final dio = createAirportApiDio();
  final apiClient = AirportApiClient(dio);
  final repository = AirportRepository(apiClient: apiClient);

  final maxHeight = MediaQuery.of(context).size.height * 0.6;
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => Container(
      height: maxHeight,
      decoration: BoxDecoration(
        color: _kDialogBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: BlocProvider(
        create: (_) => AirportSearchBloc(repository: repository),
        child: AirportPickerWidget(
          onSelect: (airport) {
            onSelect(airport);
            Navigator.of(sheetContext).pop();
          },
          onClose: () => Navigator.of(sheetContext).pop(),
        ),
      ),
    ),
  );
}

/// Picker content: search field + list. Must be used inside [BlocProvider]<[AirportSearchBloc]>.
class AirportPickerWidget extends StatefulWidget {
  const AirportPickerWidget({
    super.key,
    required this.onSelect,
    required this.onClose,
  });

  final ValueChanged<String> onSelect;
  final VoidCallback onClose;

  @override
  State<AirportPickerWidget> createState() => _AirportPickerWidgetState();
}

class _AirportPickerWidgetState extends State<AirportPickerWidget> {
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
    final textStyles = AppTheme.textStyles(context);
    final primaryStyle = textStyles.bodyMedium.copyWith(
      color: colors.textPrimary,
      fontSize: 14,
    );
    final secondaryStyle = textStyles.bodySmall.copyWith(
      color: colors.textSecondary,
      fontSize: 12,
    );
    final hintStyle = primaryStyle.copyWith(color: colors.textSecondary);

    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocus,
            style: primaryStyle,
            decoration: InputDecoration(
              hintText: 'Search airport or city',
              hintStyle: hintStyle,
              prefixIcon: Icon(
                Icons.search,
                color: colors.textSecondary,
                size: 22,
              ),
              filled: true,
              fillColor: colors.inputBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: colors.borderSecondary),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: colors.borderSecondary),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: colors.secondary, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            onChanged: (value) => context.read<AirportSearchBloc>().add(
                  AirportSearchQueryChanged(value),
                ),
          ),
        ),
        const SizedBox(height: 8),
        Flexible(
          child: BlocBuilder<AirportSearchBloc, AirportSearchState>(
            builder: (context, state) {
              if (state.isLoading) {
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(colors.secondary),
                    ),
                  ),
                );
              }
              if (state.errorMessage != null) {
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    state.errorMessage!,
                    style: secondaryStyle.copyWith(color: colors.error),
                  ),
                );
              }
              if (state.airports.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      'No airports found',
                      style: hintStyle.copyWith(fontSize: 14),
                    ),
                  ),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                itemCount: state.airports.length,
                itemBuilder: (context, index) {
                  final airport = state.airports[index];
                  final line1 = '${airport.code} — ${airport.name}';
                  final line2 = [airport.city, airport.country]
                      .where((s) => s.isNotEmpty)
                      .join(', ');
                  final displayText = '${airport.code} — ${airport.name}';
                  return InkWell(
                    onTap: () => widget.onSelect(displayText),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            line1,
                            style: primaryStyle.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (line2.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              line2,
                              style: secondaryStyle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
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
              style: secondaryStyle.copyWith(fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }
}

/// Dialog: search + list of airports. State from [AirportSearchBloc].
class _AirportPickerDialog extends StatelessWidget {
  const _AirportPickerDialog({
    required this.backgroundColor,
    required this.onSelect,
    required this.onClose,
  });

  final Color backgroundColor;
  final ValueChanged<String> onSelect;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: MediaQuery.sizeOf(context).width > 400 ? 400 : double.infinity,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.6,
          ),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white12),
          ),
          child: AirportPickerWidget(
            onSelect: onSelect,
            onClose: onClose,
          ),
        ),
      ),
    );
  }
}
