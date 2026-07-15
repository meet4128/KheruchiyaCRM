import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_crm/core/constants/string_constants.dart';
import 'package:travel_crm/core/theme/app_theme.dart';
import 'package:travel_crm/core/widgets/member_picker/bloc/member_search_bloc.dart';
import 'package:travel_crm/core/widgets/member_picker/bloc/member_search_event.dart';
import 'package:travel_crm/core/widgets/member_picker/bloc/member_search_state.dart';
import 'package:travel_crm/data/models/inquiry/inquiry_user_dto.dart';
import 'package:travel_crm/data/models/members/list_members_item.dart';
import 'package:travel_crm/data/repositories/members_repository.dart';
import 'package:travel_crm/di/injector.dart';

/// Display label for a searched member (fullName → firstName+lastName →
/// employeeId), reusing the checklist user derivation.
String _memberDisplayName(ListMembersItem m) =>
    InquiryUserDto.fromJson(m.toJson()).displayName;

/// Single-select "Assign inquiry" dialog. Searches `/members/name-search` and
/// invokes [onMemberSelected] with the chosen member, then closes. The caller
/// dispatches the assign event (keeps this widget UI-only).
Future<void> showAssignInquiryDialog(
  BuildContext context, {
  required ValueChanged<ListMembersItem> onMemberSelected,
}) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => BlocProvider(
      create: (_) => MemberSearchBloc(repository: sl<MembersRepository>()),
      child: _AssignInquiryDialog(onMemberSelected: onMemberSelected),
    ),
  );
}

class _AssignInquiryDialog extends StatefulWidget {
  const _AssignInquiryDialog({required this.onMemberSelected});

  final ValueChanged<ListMembersItem> onMemberSelected;

  @override
  State<_AssignInquiryDialog> createState() => _AssignInquiryDialogState();
}

class _AssignInquiryDialogState extends State<_AssignInquiryDialog> {
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

  void _onMemberSelected(BuildContext context, ListMembersItem member) {
    if (_memberDisplayName(member).isEmpty || (member.id?.trim() ?? '').isEmpty) {
      return;
    }
    widget.onMemberSelected(member);
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
        constraints: const BoxConstraints(maxWidth: 440, maxHeight: 520),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                StringConstant.assignInquiryTitle,
                style: textStyles.heading5.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _controller,
                focusNode: _fieldFocusNode,
                style: textStyles.formInput.copyWith(color: colors.textPrimary),
                cursorColor: colors.inputBorderFocused,
                autofocus: true,
                onChanged: (value) => context
                    .read<MemberSearchBloc>()
                    .add(MemberSearchQueryChanged(value)),
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
              Expanded(
                child: _AssignMemberResults(
                  onSelected: (member) => _onMemberSelected(context, member),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Result area: loading spinner, error, prompt (no query), empty, or the
/// tappable member list.
class _AssignMemberResults extends StatelessWidget {
  const _AssignMemberResults({required this.onSelected});

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
