import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_crm/core/constants/string_constants.dart';
import 'package:travel_crm/core/theme/app_theme.dart';
import 'package:travel_crm/core/widgets/member_picker/bloc/member_search_bloc.dart';
import 'package:travel_crm/core/widgets/member_picker/bloc/member_search_event.dart';
import 'package:travel_crm/core/widgets/member_picker/bloc/member_search_state.dart';
import 'package:travel_crm/data/models/members/list_members_item.dart';
import 'package:travel_crm/data/repositories/members_repository.dart';
import 'package:travel_crm/di/injector.dart';
import 'package:travel_crm/features/presentation/air_ticket/bloc/checklist_users_picker_cubit.dart';

/// Display label for a searched member (fullName, falling back to
/// firstName+lastName, then employeeId).
String _memberDisplayName(ListMembersItem m) {
  final full = m.fullName?.trim();
  if (full != null && full.isNotEmpty) return full;
  final parts = [m.firstName, m.lastName]
      .where((s) => s != null && s.trim().isNotEmpty)
      .map((s) => s!.trim())
      .toList();
  if (parts.isNotEmpty) return parts.join(' ');
  return m.employeeId?.trim() ?? '';
}

/// Shows the themed "Add users" dialog. Selected members are held by
/// [ChecklistUsersPickerCubit]; the searchable member list is driven by
/// [MemberSearchBloc] (debounce + throttle against `/members/name-search`).
Future<void> showChecklistUsersPickerDialog(
  BuildContext context, {
  required String initialUser,
  required ValueChanged<String> onDone,
}) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              ChecklistUsersPickerCubit(parseChecklistUserList(initialUser)),
        ),
        BlocProvider(
          create: (_) =>
              MemberSearchBloc(repository: sl<MembersRepository>()),
        ),
      ],
      child: _ChecklistUsersPickerDialog(onDone: onDone),
    ),
  );
}

/// Holds [TextEditingController] and [FocusNode] only; list updates via [BlocBuilder].
class _ChecklistUsersPickerDialog extends StatefulWidget {
  const _ChecklistUsersPickerDialog({required this.onDone});

  final ValueChanged<String> onDone;

  @override
  State<_ChecklistUsersPickerDialog> createState() =>
      _ChecklistUsersPickerDialogState();
}

class _ChecklistUsersPickerDialogState
    extends State<_ChecklistUsersPickerDialog> {
  late final TextEditingController _controller;
  late final FocusNode _fieldFocusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _fieldFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _fieldFocusNode.dispose();
    super.dispose();
  }

  void _refocusField() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _fieldFocusNode.requestFocus();
    });
  }

  void _onSearchChanged(BuildContext context, String value) {
    context.read<MemberSearchBloc>().add(MemberSearchQueryChanged(value));
  }

  void _onMemberSelected(BuildContext context, ListMembersItem member) {
    final name = _memberDisplayName(member);
    if (name.isEmpty) return;
    context
        .read<ChecklistUsersPickerCubit>()
        .addMember(name: name, id: member.id);
    _controller.clear();
    context.read<MemberSearchBloc>().add(const MemberSearchQueryChanged(''));
    _refocusField();
  }

  void _onDonePressed(BuildContext context) {
    final joined = context.read<ChecklistUsersPickerCubit>().joinedForField();
    widget.onDone(joined);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);
    final textStyles = AppTheme.textStyles(context);
    final borderColor = colors.secondary.withValues(alpha: 0.5);

    return Dialog(
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: borderColor, width: 1),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440, maxHeight: 560),
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
              // Selected members (chips).
              SizedBox(
                height: 120,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.inputBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor, width: 1),
                  ),
                  child: BlocBuilder<ChecklistUsersPickerCubit,
                      ChecklistUsersPickerState>(
                    buildWhen: (prev, curr) => prev.users != curr.users,
                    builder: (context, state) {
                      if (state.users.isEmpty) {
                        return Center(
                          child: Icon(
                            Icons.group_outlined,
                            size: 44,
                            color: colors.textSecondary.withValues(alpha: 0.35),
                          ),
                        );
                      }
                      return SingleChildScrollView(
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.start,
                          children: List.generate(state.users.length, (i) {
                            return InputChip(
                              label: Text(
                                state.users[i].name,
                                style: textStyles.bodyMedium.copyWith(
                                  color: colors.textPrimary,
                                ),
                              ),
                              deleteIcon: Icon(
                                Icons.close_rounded,
                                size: 18,
                                color: colors.textSecondary,
                              ),
                              onDeleted: () => context
                                  .read<ChecklistUsersPickerCubit>()
                                  .removeAt(i),
                              backgroundColor: colors.backgroundMedium,
                              side: BorderSide(
                                color: colors.borderSecondary
                                    .withValues(alpha: 0.5),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 0,
                              ),
                            );
                          }),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Search field.
              TextField(
                controller: _controller,
                focusNode: _fieldFocusNode,
                style: textStyles.formInput.copyWith(color: colors.textPrimary),
                cursorColor: colors.inputBorderFocused,
                autofocus: true,
                onChanged: (value) => _onSearchChanged(context, value),
                decoration: InputDecoration(
                  hintText: StringConstant.searchMembersHint,
                  hintStyle: textStyles.formHint,
                  prefixIcon: Icon(Icons.search, color: colors.textSecondary),
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
              const SizedBox(height: 8),
              // Search results.
              Expanded(
                child: _MemberSearchResults(
                  onSelected: (member) => _onMemberSelected(context, member),
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _onDonePressed(context),
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
                            colors.secondary.withValues(alpha: 0.85),
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

/// Result area under the search field: loading spinner, error, empty state,
/// prompt (no query yet), or the tappable member list.
class _MemberSearchResults extends StatelessWidget {
  const _MemberSearchResults({required this.onSelected});

  final ValueChanged<ListMembersItem> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);
    final textStyles = AppTheme.textStyles(context);

    return BlocBuilder<MemberSearchBloc, MemberSearchState>(
      builder: (context, state) {
        final hasQuery = state.query.trim().isNotEmpty;

        if (state.isLoading) {
          return Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(colors.secondary),
              ),
            ),
          );
        }

        if (state.errorMessage != null) {
          return Center(
            child: Text(
              state.errorMessage!,
              textAlign: TextAlign.center,
              style: textStyles.bodySmall.copyWith(color: colors.error),
            ),
          );
        }

        if (!hasQuery) {
          return Center(
            child: Text(
              StringConstant.searchMembersPrompt,
              style: textStyles.bodySmall.copyWith(
                color: colors.textSecondary.withValues(alpha: 0.7),
              ),
            ),
          );
        }

        if (state.members.isEmpty) {
          return Center(
            child: Text(
              StringConstant.noMembersFound,
              style: textStyles.bodySmall.copyWith(color: colors.textSecondary),
            ),
          );
        }

        return ListView.separated(
          padding: EdgeInsets.zero,
          itemCount: state.members.length,
          separatorBuilder: (_, __) => Divider(
            height: 1,
            color: colors.borderSecondary.withValues(alpha: 0.3),
          ),
          itemBuilder: (context, index) {
            final member = state.members[index];
            final name = _memberDisplayName(member);
            final employeeId = member.employeeId?.trim();
            return ListTile(
              dense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              leading: Icon(Icons.person_outline, color: colors.textSecondary),
              title: Text(
                name,
                style: textStyles.bodyMedium.copyWith(color: colors.textPrimary),
              ),
              subtitle: (employeeId != null && employeeId.isNotEmpty)
                  ? Text(
                      employeeId,
                      style: textStyles.bodySmall
                          .copyWith(color: colors.textSecondary),
                    )
                  : null,
              onTap: () => onSelected(member),
            );
          },
        );
      },
    );
  }
}
