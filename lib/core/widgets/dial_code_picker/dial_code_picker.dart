import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_crm/core/constants/dimension_constant.dart';
import 'package:travel_crm/core/widgets/dial_code_picker/bloc/dial_code_picker_bloc.dart';

const Color _kDialogBackground = Color(0xFF161424);

/// Reusable dial code picker widget.
/// Shows a search-only dialog: search field + filtered list (no full list, no favorites).
class DialCodePicker extends StatelessWidget {
  const DialCodePicker({
    super.key,
    required this.dialCode,
    required this.onChanged,
    this.favoriteCodes,
    this.showFlag,
    this.textStyle,
    this.dialogTextStyle,
    this.searchStyle,
    this.barrierColor,
    this.backgroundColor,
    this.dialogBackgroundColor,
  });

  final String dialCode;
  final ValueChanged<String> onChanged;
  final List<String>? favoriteCodes;
  final bool? showFlag;
  final TextStyle? textStyle;
  final TextStyle? dialogTextStyle;
  final TextStyle? searchStyle;
  final Color? barrierColor;
  final Color? backgroundColor;
  final Color? dialogBackgroundColor;

  @override
  Widget build(BuildContext context) {
    final effectiveTextStyle =
        textStyle ?? const TextStyle(color: Colors.white, fontSize: 14);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showSearchOnlyDialog(context),
        borderRadius: BorderRadius.circular(DimensionConstant.d12),
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor ?? _kDialogBackground,
            borderRadius: BorderRadius.circular(DimensionConstant.d12),
            border: Border.all(color: Colors.white12),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: DimensionConstant.d6,
            vertical: 12,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(dialCode, style: effectiveTextStyle),
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_drop_down,
                color: effectiveTextStyle.color ?? Colors.white,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSearchOnlyDialog(BuildContext context) {
    final bgColor = dialogBackgroundColor ?? _kDialogBackground;
    final barrier = barrierColor ?? Colors.black.withOpacity(0.7);
    final searchTextStyle =
        searchStyle ?? dialogTextStyle ?? const TextStyle(color: Colors.white);
    final listTextStyle =
        dialogTextStyle ?? const TextStyle(color: Colors.white);

    showDialog<void>(
      context: context,
      barrierColor: barrier,
      builder: (context) => BlocProvider(
        create: (_) => DialCodePickerCubit(),
        child: _SearchOnlyDialCodeDialog(
          initialDialCode: dialCode,
          backgroundColor: bgColor,
          searchStyle: searchTextStyle,
          listTextStyle: listTextStyle,
          showFlag: showFlag ?? false,
          onSelect: (selectedDialCode) {
            onChanged(selectedDialCode);
            Navigator.of(context).pop();
          },
          onClose: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }
}

/// Dialog that shows only search field + filtered results (no full list).
class _SearchOnlyDialCodeDialog extends StatefulWidget {
  const _SearchOnlyDialCodeDialog({
    required this.initialDialCode,
    required this.backgroundColor,
    required this.searchStyle,
    required this.listTextStyle,
    required this.showFlag,
    required this.onSelect,
    required this.onClose,
  });

  final String initialDialCode;
  final Color backgroundColor;
  final TextStyle searchStyle;
  final TextStyle listTextStyle;
  final bool showFlag;
  final ValueChanged<String> onSelect;
  final VoidCallback onClose;

  @override
  State<_SearchOnlyDialCodeDialog> createState() =>
      _SearchOnlyDialCodeDialogState();
}

class _SearchOnlyDialCodeDialogState extends State<_SearchOnlyDialCodeDialog> {
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
    return BlocBuilder<DialCodePickerCubit, DialCodePickerState>(
      builder: (context, state) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width:
                  MediaQuery.sizeOf(context).width > 400 ? 400 : double.infinity,
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
                      style: widget.searchStyle,
                      decoration: InputDecoration(
                        hintText: 'Search country or code',
                        hintStyle: widget.searchStyle.copyWith(
                          color: Colors.white54,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: widget.searchStyle.color ?? Colors.white,
                          size: 20,
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.08),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.white12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      onChanged: (value) =>
                          context.read<DialCodePickerCubit>().searchChanged(value),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Flexible(
                    child: state.isLoading
                        ? Padding(
                            padding: const EdgeInsets.all(24),
                            child: Center(
                              child: Text(
                                'Loading…',
                                style: widget.listTextStyle.copyWith(
                                  color: Colors.white54,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          )
                        : state.filteredCountries.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.all(24),
                                child: Text(
                                  'No country found',
                                  style: widget.listTextStyle.copyWith(
                                    color: Colors.white54,
                                    fontSize: 14,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                itemCount: state.filteredCountries.length,
                                itemBuilder: (context, index) {
                                  final c = state.filteredCountries[index];
                                  final dial = c.dialCode ?? '';
                                  final label =
                                      '$dial ${state.englishName(c)}';
                                  return InkWell(
                                    onTap: () => widget.onSelect(dial),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      child: Row(
                                        children: [
                                          if (widget.showFlag) ...[
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              child: Image.asset(
                                                c.flagUri!,
                                                package: 'country_code_picker',
                                                width: 24,
                                                height: 18,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) =>
                                                    const SizedBox(
                                                        width: 24, height: 18),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                          ],
                                          Expanded(
                                            child: Text(
                                              label,
                                              style: widget.listTextStyle,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
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
                        style: widget.listTextStyle.copyWith(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
