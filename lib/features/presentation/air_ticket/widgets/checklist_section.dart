import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:travel_crm/core/constants/asset_constants.dart';
import 'package:travel_crm/core/constants/string_constants.dart';
import 'package:travel_crm/core/theme/app_theme.dart';
import 'package:travel_crm/core/widgets/app_date_picker.dart';
import 'package:travel_crm/core/widgets/app_dropdown.dart';
import '../models/checklist_item.dart';
import '../models/checklist_priority.dart';

/// Checklist section widget
/// Displays checklist input fields and action buttons
class ChecklistSection extends StatelessWidget {
  const ChecklistSection({
    super.key,
    required this.items,
    required this.user,
    this.dueDate,
    this.priority,
    required this.category,
    required this.inLoop,
    required this.repeat,
    required this.onUserChanged,
    required this.onDueDateChanged,
    required this.onPriorityChanged,
    required this.onCategoryChanged,
    required this.onInLoopChanged,
    required this.onRepeatChanged,
    required this.onAddItem,
    required this.onRemoveItem,
    required this.onSubmit,
    this.onAttachmentPicked,
    this.isSubmitting = false,
    this.isValid = false,
  });

  /// Called when user attaches a document (PDF or image) via the link icon.
  final void Function(PlatformFile file)? onAttachmentPicked;

  final List<ChecklistItem> items;
  final String user;
  final DateTime? dueDate;
  final ChecklistPriority? priority;
  final String category;
  final bool inLoop;
  final bool repeat;
  final ValueChanged<String> onUserChanged;
  final ValueChanged<DateTime?> onDueDateChanged;
  final ValueChanged<ChecklistPriority> onPriorityChanged;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<bool> onInLoopChanged;
  final ValueChanged<bool> onRepeatChanged;
  final VoidCallback onAddItem;
  final ValueChanged<int> onRemoveItem;
  final VoidCallback onSubmit;
  final bool isSubmitting;
  final bool isValid;

  static const List<ChecklistPriority> checklistPriorities =
      ChecklistPriority.values;
  static const List<String> categories = [
    StringConstant.documentation,
    StringConstant.payment,
    StringConstant.visa,
    StringConstant.other,
  ];

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);
    final textStyles = AppTheme.textStyles(context);
    final borderColor = colors.secondary.withOpacity(0.5);
    final fieldDecoration = BoxDecoration(
      color: colors.inputBackground,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: borderColor, width: 1),
      boxShadow: [
        BoxShadow(
          color: colors.secondary.withOpacity(0.12),
          blurRadius: 8,
          spreadRadius: 0,
        ),
      ],
    );

    // No separate border/container — section is part of the screen; only inner elements have styling.
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title: Add Checklist
          Text(
            StringConstant.addChecklist,
            style: textStyles.heading5.copyWith(
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          // Top row: User, Due Date, Set Priority, Category, In Loop (icon + field, glowing border); max height 55px
          SizedBox(
            height: 55,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              Expanded(
                child: _ChecklistFieldWrap(
                  decoration: fieldDecoration,
                  icon: Icons.person_outline,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _openUsersDialog(context),
                      borderRadius: BorderRadius.circular(8),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Text(
                            user.trim().isEmpty ? StringConstant.user : user,
                            style: textStyles.bodyMedium.copyWith(
                              color: user.trim().isEmpty
                                  ? colors.textSecondary.withValues(alpha: 0.75)
                                  : colors.textPrimary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ChecklistFieldWrap(
                  decoration: fieldDecoration,
                  icon: Icons.calendar_today_outlined,
                  child: AppDatePicker(
                    hint: StringConstant.dueDate,
                    value: dueDate,
                    onChanged: (date) => onDueDateChanged(date),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ChecklistFieldWrap(
                  decoration: fieldDecoration,
                  icon: Icons.bar_chart,
                  child: AppDropdown<ChecklistPriority>(
                    hintText: StringConstant.setPriorityHint,
                    items: checklistPriorities,
                    itemLabel: (p) => p.displayLabel,
                    value: priority,
                    onChanged: (value) {
                      if (value != null) onPriorityChanged(value);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ChecklistFieldWrap(
                  decoration: fieldDecoration,
                  icon: Icons.filter_list,
                  child: AppDropdown<String>(
                    hintText: StringConstant.category,
                    items: categories,
                    itemLabel: (c) => c,
                    value: category.isEmpty ? null : category,
                    onChanged: (value) {
                      if (value != null) onCategoryChanged(value);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  decoration: fieldDecoration,
                  child: Row(
                    children: [
                      Icon(Icons.loop, size: 20, color: colors.textSecondary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          StringConstant.inLoop,
                          style: textStyles.bodyMedium.copyWith(
                            color: colors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Divider: thin horizontal glowing line
          Container(
            height: 1,
            width: double.infinity,
            decoration: BoxDecoration(
              color: borderColor,
              boxShadow: [
                BoxShadow(
                  color: colors.secondary.withOpacity(0.3),
                  blurRadius: 4,
                  spreadRadius: 0,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Bottom row: Repeat checkbox, three icons (left) | vertical dots + Submit (right, grouped)
          Row(
            children: [
              Checkbox(
                value: repeat,
                onChanged: (value) => onRepeatChanged(value ?? false),
                activeColor: colors.secondary,
                fillColor: WidgetStateProperty.resolveWith((_) => colors.inputBackground),
                side: BorderSide(color: colors.borderSecondary),
              ),
              const SizedBox(width: 8),
              Text(
                StringConstant.repeat,
                style: textStyles.bodyMedium.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(width: 16),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _pickAttachment(context),
                  borderRadius: BorderRadius.circular(24),
                  child: Tooltip(
                    message: 'Attach document (PDF or image)',
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: SvgPicture.asset(
                        AssetConstants.icLink,
                        width: 30,
                        height: 30,
                        colorFilter: ColorFilter.mode(colors.textSecondary, BlendMode.srcIn),
                      ),
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: SvgPicture.asset(
                  AssetConstants.icClock,
                  width: 30,
                  height: 30,
                  colorFilter: ColorFilter.mode(colors.textSecondary, BlendMode.srcIn),
                ),
                onPressed: () {},
                tooltip: StringConstant.time,
              ),
              IconButton(
                icon: SvgPicture.asset(
                  AssetConstants.icMicrophoneSlash,
                  width: 30,
                  height: 30,
                  colorFilter: ColorFilter.mode(colors.textSecondary, BlendMode.srcIn),
                ),
                onPressed: () {},
                tooltip: 'Mute',
              ),
              const Spacer(),
              // Vertical dots directly adjacent to Submit button (match screenshot)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.more_vert, color: colors.textSecondary, size: 22),
                    onPressed: () {},
                    tooltip: 'More',
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                    style: IconButton.styleFrom(
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: !isSubmitting ? onSubmit : null,
                  borderRadius: BorderRadius.circular(12),
                  child: Opacity(
                    opacity: isSubmitting ? 0.7 : 1,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            colors.secondary,
                            colors.secondary.withOpacity(0.85),
                            Color(0xFFEC4899),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: colors.secondary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: isSubmitting
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(colors.textOnPrimary),
                            ),
                          )
                        : Text(
                            StringConstant.submit,
                            style: textStyles.labelLarge.copyWith(
                              color: colors.textOnPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                    ),
                  ),
                ),
              ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openUsersDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => _ChecklistUsersDialog(
        initialUser: user,
        onDone: onUserChanged,
      ),
    );
  }

  /// Opens file picker for PDF or image only; calls [onAttachmentPicked] if provided.
  static const List<String> _allowedAttachmentExtensions = [
    'pdf',
    'jpg',
    'jpeg',
    'png',
    'gif',
    'webp',
    'bmp',
  ];

  Future<void> _pickAttachment(BuildContext context) async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    try {
      // Call pickFiles immediately (no await before this) so on web the file dialog
      // is triggered in the same user gesture and not blocked by the browser.
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: _allowedAttachmentExtensions,
      );
      if (!context.mounted) return;
      if (result == null || result.files.isEmpty) return;
      final file = result.files.first;
      onAttachmentPicked?.call(file);
      if (context.mounted) {
        messenger?.showSnackBar(
          SnackBar(content: Text('Attached: ${file.name}')),
        );
      }
    } catch (e, st) {
      if (context.mounted) {
        messenger?.showSnackBar(
          SnackBar(
            content: Text('Could not open file picker: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
      debugPrint('ChecklistSection._pickAttachment error: $e\n$st');
    }
  }
}


List<String> _parseUserList(String raw) {
  return raw
      .split(',')
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();
}

class _ChecklistUsersDialog extends StatefulWidget {
  const _ChecklistUsersDialog({
    required this.initialUser,
    required this.onDone,
  });

  final String initialUser;
  final ValueChanged<String> onDone;

  @override
  State<_ChecklistUsersDialog> createState() => _ChecklistUsersDialogState();
}

class _ChecklistUsersDialogState extends State<_ChecklistUsersDialog> {
  late List<String> _names;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _names = _parseUserList(widget.initialUser);
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addCurrent() {
    final t = _controller.text.trim();
    if (t.isEmpty) return;
    final exists = _names.any((n) => n.toLowerCase() == t.toLowerCase());
    if (exists) {
      _controller.clear();
      return;
    }
    setState(() {
      _names.add(t);
      _controller.clear();
    });
  }

  void _removeAt(int index) {
    setState(() => _names.removeAt(index));
  }

  void _onDone() {
    widget.onDone(_names.join(', '));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);
    final textStyles = AppTheme.textStyles(context);
    final borderColor = colors.secondary.withOpacity(0.5);

    return Dialog(
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: borderColor, width: 1),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440, maxHeight: 520),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                StringConstant.addUsersTitle,
                style: textStyles.heading5.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.inputBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor, width: 1),
                  ),
                  child: _names.isEmpty
                      ? Center(
                          child: Icon(
                            Icons.group_outlined,
                            size: 44,
                            color: colors.textSecondary.withValues(alpha: 0.35),
                          ),
                        )
                      : SingleChildScrollView(
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            alignment: WrapAlignment.start,
                            children: List.generate(_names.length, (i) {
                              return InputChip(
                                label: Text(
                                  _names[i],
                                  style: textStyles.bodyMedium.copyWith(
                                    color: colors.textPrimary,
                                  ),
                                ),
                                deleteIcon: Icon(
                                  Icons.close_rounded,
                                  size: 18,
                                  color: colors.textSecondary,
                                ),
                                onDeleted: () => _removeAt(i),
                                backgroundColor: colors.backgroundMedium,
                                side: BorderSide(
                                  color: colors.borderSecondary.withOpacity(0.5),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 0,
                                ),
                              );
                            }),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _controller,
                style: textStyles.formInput.copyWith(color: colors.textPrimary),
                cursorColor: colors.inputBorderFocused,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _addCurrent(),
                decoration: InputDecoration(
                  hintText: StringConstant.userTypeNamePressEnter,
                  hintStyle: textStyles.formHint,
                  filled: true,
                  fillColor: colors.inputBackground,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colors.inputBorder, width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colors.inputBorder, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: colors.inputBorderFocused,
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _onDone,
                    borderRadius: BorderRadius.circular(12),
                    child: Ink(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            colors.secondary,
                            colors.secondary.withOpacity(0.85),
                            const Color(0xFFEC4899),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        StringConstant.done,
                        style: textStyles.labelLarge.copyWith(
                          color: colors.textOnPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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

/// Wraps a checklist field with icon + glowing border container (no label above).
class _ChecklistFieldWrap extends StatelessWidget {
  const _ChecklistFieldWrap({
    required this.decoration,
    required this.icon,
    required this.child,
  });

  final BoxDecoration decoration;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);
    return Container(
      decoration: decoration,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: colors.textSecondary),
          const SizedBox(width: 10),
          Expanded(child: child),
        ],
      ),
    );
  }
}

