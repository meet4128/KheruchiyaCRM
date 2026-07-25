import 'package:flutter/material.dart';
import 'package:travel_crm/core/constants/color_constants.dart';

/// Single source of truth for the inquiry status vocabulary shown on the
/// summary/status rows (vendor list `_buildSummaryStatusRow` and the inquiry
/// detail `StatusBar`). Canonical statuses are the **vendor-list API statuses**
/// (`IN_PROGRESS / PENDING / CANCELLED / COMPLETED`).
///
/// Only the definition (label, order, colors, API mapping) is shared — each
/// screen keeps its own count logic ("based on screen flow"): the list counts
/// inquiries by [apiStatus]; the detail counts amendments per tab.
enum InquiryStatusChip { all, newIn, pending, newFollowUp, setFollowUp, loss, won }

extension InquiryStatusChipX on InquiryStatusChip {
  /// Text color drawn inside the count circle (dark navy from the vendor list).
  static const Color _content = Color(0xFF1B1535);

  String get label {
    switch (this) {
      case InquiryStatusChip.all:
        return 'All';
      case InquiryStatusChip.newIn:
        return 'New In';
      case InquiryStatusChip.pending:
        return 'Pending';
      case InquiryStatusChip.newFollowUp:
        return 'New Follow Up';
      case InquiryStatusChip.setFollowUp:
        return 'Set Follow Up';
      case InquiryStatusChip.loss:
        return 'Loss';
      case InquiryStatusChip.won:
        return 'Won';
    }
  }

  /// Canonical API status for filtering/counting inquiries. `null` for "All" and
  /// the follow-up actions (which aren't API statuses).
  String? get apiStatus {
    switch (this) {
      case InquiryStatusChip.newIn:
        return 'IN_PROGRESS';
      case InquiryStatusChip.pending:
        return 'PENDING';
      case InquiryStatusChip.loss:
        return 'CANCELLED';
      case InquiryStatusChip.won:
        return 'COMPLETED';
      case InquiryStatusChip.all:
      case InquiryStatusChip.newFollowUp:
      case InquiryStatusChip.setFollowUp:
        return null;
    }
  }

  /// Follow-up entries open a dialog on the list and act as the amendment
  /// follow-up tab on the detail — they are not selectable status filters.
  bool get isFollowUpAction =>
      this == InquiryStatusChip.newFollowUp ||
      this == InquiryStatusChip.setFollowUp;

  /// Background of the count circle.
  Color get circleColor {
    switch (this) {
      case InquiryStatusChip.newIn:
        return const Color(0xFF0088FF);
      case InquiryStatusChip.pending:
        return const Color(0xFFFF8D28);
      case InquiryStatusChip.loss:
        return ColorConstant.asteriskRedColor; // 0xFFFF383C
      case InquiryStatusChip.won:
        return ColorConstant.subTitleGreenColor; // 0xFF34C759
      case InquiryStatusChip.all:
      case InquiryStatusChip.newFollowUp:
      case InquiryStatusChip.setFollowUp:
        return Colors.white;
    }
  }

  Color get contentColor => _content;

  static InquiryStatusChip fromIndex(int index) {
    final values = InquiryStatusChip.values;
    if (index < 0 || index >= values.length) return InquiryStatusChip.all;
    return values[index];
  }

  static int indexOf(InquiryStatusChip chip) => chip.index;
}
