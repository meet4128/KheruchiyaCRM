import 'dart:convert';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:travel_crm/core/constants/dimension_constant.dart';

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
      builder: (context) => _SearchOnlyDialCodeDialog(
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
  List<CountryCode> _allCountries = [];
  List<CountryCode> _filtered = [];
  /// English names by country code (from package's en.json). Null until loaded.
  Map<String, String>? _englishNames;

  @override
  void initState() {
    super.initState();
    _searchFocus.requestFocus();
    _loadEnglishNamesAndCountries();
  }

  Future<void> _loadEnglishNamesAndCountries() async {
    try {
      final jsonString = await rootBundle.loadString(
        'packages/country_code_picker/src/i18n/en.json',
      );
      final Map<String, dynamic> decoded = jsonDecode(jsonString);
      final Map<String, String> names = {};
      for (final e in decoded.entries) {
        if (e.key == 'no_country') continue;
        final v = e.value;
        names[e.key] = v is List ? (v.isNotEmpty ? v.first.toString() : '') : v.toString();
      }
      final all = codes
          .map((e) => CountryCode.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      if (mounted) {
        setState(() {
          _englishNames = names;
          _allCountries = all;
          _filtered = List.from(all);
        });
      }
    } catch (_) {
      // Fallback: show with original names if en.json fails to load
      final all = codes
          .map((e) => CountryCode.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      if (mounted) {
        setState(() {
          _allCountries = all;
          _filtered = List.from(all);
        });
      }
    }
  }

  String _englishName(CountryCode c) {
    final code = c.code;
    if (code == null) return c.name ?? '';
    return _englishNames?[code] ?? c.name ?? '';
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    final q = query.trim().toUpperCase();
    if (q.isEmpty) {
      setState(() => _filtered = List.from(_allCountries));
      return;
    }
    setState(() {
      _filtered = _allCountries.where((c) {
        final name = _englishName(c).toUpperCase();
        final code = (c.code ?? '').toUpperCase();
        final dial = c.dialCode ?? '';
        return name.contains(q) || code.contains(q) || dial.contains(q);
      }).toList();
    });
  }

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
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Search only
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
                  onChanged: _onSearchChanged,
                ),
              ),
              const SizedBox(height: 8),
              // Full list at first; when user types, only searched/filtered data. English names only.
              Flexible(
                child: _allCountries.isEmpty
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
                    : _filtered.isEmpty
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
                            itemCount: _filtered.length,
                            itemBuilder: (context, index) {
                              final c = _filtered[index];
                              final dial = c.dialCode ?? '';
                              final label =
                                  '$dial ${_englishName(c)}';
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
              // Close
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
  }
}
