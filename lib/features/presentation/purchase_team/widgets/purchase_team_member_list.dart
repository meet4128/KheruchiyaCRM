import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_crm/core/constants/color_constants.dart';
import 'package:travel_crm/core/constants/dimension_constant.dart';
import 'package:travel_crm/core/constants/font_constant.dart';
import 'package:travel_crm/core/constants/string_constants.dart';
import 'package:travel_crm/features/presentation/purchase_team/bloc/purchase_team_directory/purchase_team_directory_bloc.dart';
import 'package:travel_crm/features/presentation/purchase_team/bloc/purchase_team_directory/purchase_team_directory_event.dart';
import 'package:travel_crm/features/presentation/purchase_team/bloc/purchase_team_directory/purchase_team_directory_state.dart';
import 'package:travel_crm/features/presentation/purchase_team/widgets/purchase_team_member_tile.dart';

class PurchaseTeamMemberList extends StatelessWidget {
  const PurchaseTeamMemberList({
    super.key,
    required this.onMemberTap,
  });

  final void Function(String memberId) onMemberTap;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PurchaseTeamDirectoryBloc, PurchaseTeamDirectoryState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(DimensionConstant.d16),
              child: TextField(
                onChanged: (value) => context
                    .read<PurchaseTeamDirectoryBloc>()
                    .add(PurchaseTeamDirectorySearchChanged(value)),
                style: FontConstant.interNormal(color: ColorConstant.whiteColor),
                decoration: InputDecoration(
                  hintText: StringConstant.messagesSearchMembers,
                  hintStyle: FontConstant.interNormal(
                    color: ColorConstant.whiteColor.withValues(alpha: 0.5),
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: ColorConstant.whiteColor.withValues(alpha: 0.6),
                  ),
                  filled: true,
                  fillColor: ColorConstant.cardBgColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(DimensionConstant.d4),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: DimensionConstant.d12,
                    vertical: DimensionConstant.d10,
                  ),
                ),
              ),
            ),
            Expanded(child: _buildBody(context, state)),
          ],
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, PurchaseTeamDirectoryState state) {
    if (state.status == PurchaseTeamDirectoryStatus.loading && state.members.isEmpty) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }

    if (state.status == PurchaseTeamDirectoryStatus.failure && state.members.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(DimensionConstant.d16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                state.errorMessage ?? StringConstant.messagesDirectoryLoadFailed,
                textAlign: TextAlign.center,
                style: FontConstant.interNormal(
                  color: ColorConstant.whiteColor.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: DimensionConstant.d12),
              TextButton(
                onPressed: () => context
                    .read<PurchaseTeamDirectoryBloc>()
                    .add(const PurchaseTeamDirectoryRefreshRequested()),
                child: const Text(StringConstant.qnaChatRetry),
              ),
            ],
          ),
        ),
      );
    }

    if (state.members.isEmpty) {
      return Center(
        child: Text(
          StringConstant.messagesNoMembers,
          style: FontConstant.interNormal(
            color: ColorConstant.whiteColor.withValues(alpha: 0.6),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<PurchaseTeamDirectoryBloc>().add(
              const PurchaseTeamDirectoryRefreshRequested(),
            );
        await Future<void>.delayed(const Duration(milliseconds: 400));
      },
      child: ListView.separated(
        itemCount: state.members.length,
        separatorBuilder: (_, __) => Divider(
          height: 1,
          color: ColorConstant.whiteColor.withValues(alpha: 0.08),
        ),
        itemBuilder: (context, index) {
          final member = state.members[index];
          final selected = state.selectedMemberId == member.purchaseTeamMemberId;
          return PurchaseTeamMemberTile(
            member: member,
            isSelected: selected,
            onTap: () => onMemberTap(member.purchaseTeamMemberId),
          );
        },
      ),
    );
  }
}
