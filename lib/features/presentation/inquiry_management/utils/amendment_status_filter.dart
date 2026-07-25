import 'package:travel_crm/core/widgets/inquiry_management_items.dart';
import 'package:travel_crm/features/presentation/inquiry_management/models/amendment_card_ui.dart';
import 'package:travel_crm/features/presentation/inquiry_management/models/inquiry_status_chip.dart';

/// The inquiry-detail status tabs reuse the shared [InquiryStatusChip]
/// vocabulary (single source of truth). Only the amendment matching/counting
/// below is detail-specific ("based on screen flow") — it collapses the three
/// follow-up-flavoured tabs onto the amendment `followup` status.
bool amendmentMatchesTab(AmendmentCardUi amendment, InquiryStatusChip tab) {
  if (tab == InquiryStatusChip.all) return true;

  final normalized = amendment.status.trim().toLowerCase();
  switch (tab) {
    case InquiryStatusChip.all:
      return true;
    case InquiryStatusChip.newIn:
    case InquiryStatusChip.setFollowUp:
    case InquiryStatusChip.newFollowUp:
      return normalized == 'followup';
    case InquiryStatusChip.pending:
      return normalized == 'pending';
    case InquiryStatusChip.loss:
      return normalized == 'loss';
    case InquiryStatusChip.won:
      return normalized == 'completed';
  }
}

List<AmendmentCardUi> filterAmendmentsByTab(
  List<AmendmentCardUi> amendments,
  InquiryStatusChip tab,
) {
  return amendments.where((a) => amendmentMatchesTab(a, tab)).toList(growable: false);
}

int countAmendmentsForTab(List<AmendmentCardUi> amendments, InquiryStatusChip tab) {
  return filterAmendmentsByTab(amendments, tab).length;
}

List<StatusItem> buildAmendmentStatusBarItems(List<AmendmentCardUi> amendments) {
  return InquiryStatusChip.values
      .map(
        (tab) => StatusItem(
          label: tab.label,
          count: countAmendmentsForTab(amendments, tab),
          circleColor: tab.circleColor,
          contentColor: tab.contentColor,
        ),
      )
      .toList(growable: false);
}
