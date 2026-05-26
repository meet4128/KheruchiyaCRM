import 'package:flutter/material.dart';
import 'package:travel_crm/core/constants/color_constants.dart';
import 'package:travel_crm/core/widgets/inquiry_management_items.dart';
import 'package:travel_crm/features/presentation/inquiry_management/models/amendment_card_ui.dart';

/// Client-side amendment tabs on inquiry detail (not API inquiry list status).
enum AmendmentStatusTab {
  all,
  newIn,
  pending,
  setFollowUp,
  newFollowUp,
  loss,
  won,
}

extension AmendmentStatusTabX on AmendmentStatusTab {
  String get label {
    switch (this) {
      case AmendmentStatusTab.all:
        return 'All';
      case AmendmentStatusTab.newIn:
        return 'New In';
      case AmendmentStatusTab.pending:
        return 'Pending';
      case AmendmentStatusTab.setFollowUp:
        return 'Set Follow Up';
      case AmendmentStatusTab.newFollowUp:
        return 'New Follow Up';
      case AmendmentStatusTab.loss:
        return 'Loss';
      case AmendmentStatusTab.won:
        return 'Won';
    }
  }

  static AmendmentStatusTab fromIndex(int index) {
    final values = AmendmentStatusTab.values;
    if (index < 0 || index >= values.length) return AmendmentStatusTab.all;
    return values[index];
  }

  static int indexOf(AmendmentStatusTab tab) => tab.index;
}

bool amendmentMatchesTab(AmendmentCardUi amendment, AmendmentStatusTab tab) {
  if (tab == AmendmentStatusTab.all) return true;

  final normalized = amendment.status.trim().toLowerCase();
  switch (tab) {
    case AmendmentStatusTab.all:
      return true;
    case AmendmentStatusTab.newIn:
    case AmendmentStatusTab.setFollowUp:
    case AmendmentStatusTab.newFollowUp:
      return normalized == 'followup';
    case AmendmentStatusTab.pending:
      return normalized == 'pending';
    case AmendmentStatusTab.loss:
      return normalized == 'loss';
    case AmendmentStatusTab.won:
      return normalized == 'completed';
  }
}

List<AmendmentCardUi> filterAmendmentsByTab(
  List<AmendmentCardUi> amendments,
  AmendmentStatusTab tab,
) {
  return amendments.where((a) => amendmentMatchesTab(a, tab)).toList(growable: false);
}

int countAmendmentsForTab(List<AmendmentCardUi> amendments, AmendmentStatusTab tab) {
  return filterAmendmentsByTab(amendments, tab).length;
}

List<StatusItem> buildAmendmentStatusBarItems(List<AmendmentCardUi> amendments) {
  return [
    StatusItem(
      label: AmendmentStatusTab.all.label,
      count: countAmendmentsForTab(amendments, AmendmentStatusTab.all),
      circleColor: Colors.white,
      contentColor: ColorConstant.blackColor,
    ),
    StatusItem(
      label: AmendmentStatusTab.newIn.label,
      count: countAmendmentsForTab(amendments, AmendmentStatusTab.newIn),
      circleColor: Colors.blue,
    ),
    StatusItem(
      label: AmendmentStatusTab.pending.label,
      count: countAmendmentsForTab(amendments, AmendmentStatusTab.pending),
      circleColor: Colors.orange,
    ),
    StatusItem(
      label: AmendmentStatusTab.setFollowUp.label,
      count: countAmendmentsForTab(amendments, AmendmentStatusTab.setFollowUp),
      circleColor: Colors.white,
      contentColor: ColorConstant.blackColor,
    ),
    StatusItem(
      label: AmendmentStatusTab.newFollowUp.label,
      count: countAmendmentsForTab(amendments, AmendmentStatusTab.newFollowUp),
      circleColor: Colors.white,
      contentColor: ColorConstant.blackColor,
    ),
    StatusItem(
      label: AmendmentStatusTab.loss.label,
      count: countAmendmentsForTab(amendments, AmendmentStatusTab.loss),
      circleColor: Colors.red,
    ),
    StatusItem(
      label: AmendmentStatusTab.won.label,
      count: countAmendmentsForTab(amendments, AmendmentStatusTab.won),
      circleColor: Colors.green,
    ),
  ];
}
