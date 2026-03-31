import 'package:intl/intl.dart';
import 'package:travel_crm/data/models/inquiry/inquiry_checklist_item.dart';
import 'package:travel_crm/data/models/inquiry/list_inquiry_item.dart';

import 'inquiry_priority_trend.dart';

/// One row in the inquiry vendor table — built from [ListInquiryItem] (bloc state).
///
/// Keeps presentation fields out of [InquiryManagementBloc]; mapping lives here.
class VendorInquiryRow {
  const VendorInquiryRow({
    required this.inquiryNo,
    required this.generatedAt,
    required this.name,
    required this.bookingType,
    required this.priorityTrend,
    required this.priorityText,
    this.checklist = const [],
    this.slaDeadline,
    required this.assignedToNames,
    required this.assignedToText,
    required this.status,
  });

  final String inquiryNo;
  final String generatedAt;
  final String name;
  final String bookingType;
  final InquiryPriorityTrend priorityTrend;
  final String priorityText;

  /// From GET `checklist` on the inquiry (same shape as POST; no inLoop/repeat in API).
  final List<InquiryChecklistItem> checklist;

  /// `createdAt` + SLA (15m / 1h / 8h by priority). Null if no priority or invalid date.
  final DateTime? slaDeadline;

  final List<String> assignedToNames;
  final String assignedToText;
  final String status;

  factory VendorInquiryRow.fromListInquiryItem(ListInquiryItem e) {
    final id = e.id ?? '';
    final inquiryNo = id.length > 8
        ? '#${id.substring(id.length - 8)}'
        : (id.isEmpty ? '-' : '#$id');
    final checklist = e.checklist;
    DateTime? createdLocal;
    try {
      final raw = e.createdAt?.trim();
      if (raw != null && raw.isNotEmpty) {
        createdLocal = DateTime.parse(raw).toLocal();
      }
    } catch (_) {}
    final sla = _slaDurationFromChecklist(checklist);
    final deadline =
        createdLocal != null && sla != null ? createdLocal.add(sla) : null;

    final assignee = _assignedFromInquiry(e);

    return VendorInquiryRow(
      inquiryNo: inquiryNo,
      generatedAt: _formatInquiryGenerated(e.createdAt),
      name: e.fullName ?? '-',
      bookingType: e.typeOfBooking ?? '-',
      priorityTrend: _priorityTrendFromChecklist(checklist),
      priorityText: _priorityLabelFromChecklist(checklist),
      checklist: checklist,
      slaDeadline: deadline,
      assignedToNames: assignee.names,
      assignedToText: assignee.text,
      status: e.status ?? '-',
    );
  }

  /// `user` / `assignedTo` on inquiry, else unique `checklist[].user` values.
  static ({List<String> names, String text}) _assignedFromInquiry(
    ListInquiryItem e,
  ) {
    final root = _firstNonEmpty([e.user, e.assignedTo]);
    if (root != null) {
      final names = _parseAssigneeNames(root);
      if (names.isNotEmpty) {
        return (names: names, text: _formatAssigneeLine(names));
      }
    }

    final fromChecklist = <String>[];
    for (final c in e.checklist) {
      final u = c.user?.trim();
      if (u != null && u.isNotEmpty) {
        fromChecklist.addAll(_parseAssigneeNames(u));
      }
    }
    final unique = _dedupeAssignees(fromChecklist);
    if (unique.isEmpty) {
      return (names: const <String>[], text: 'Yet to assign');
    }
    return (names: unique, text: _formatAssigneeLine(unique));
  }

  static String? _firstNonEmpty(List<String?> values) {
    for (final v in values) {
      final t = v?.trim();
      if (t != null && t.isNotEmpty) return t;
    }
    return null;
  }

  static List<String> _parseAssigneeNames(String raw) {
    return raw
        .split(RegExp(r',|&'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  static List<String> _dedupeAssignees(List<String> names) {
    final seen = <String>{};
    final out = <String>[];
    for (final n in names) {
      if (seen.add(n.toLowerCase())) out.add(n);
    }
    return out;
  }

  static String _formatAssigneeLine(List<String> names) {
    if (names.isEmpty) return 'Yet to assign';
    if (names.length == 1) return names.first;
    if (names.length == 2) return '${names[0]} & ${names[1]}';
    return '${names.take(names.length - 1).join(', ')} & ${names.last}';
  }

  /// SLA window from first checklist priority: HIGH 15m, MEDIUM 1h, LOW 8h.
  static Duration? _slaDurationFromChecklist(List<InquiryChecklistItem> checklist) {
    for (final c in checklist) {
      final p = c.priority?.trim();
      if (p == null || p.isEmpty) continue;
      switch (p.toUpperCase()) {
        case 'HIGH':
          return const Duration(minutes: 15);
        case 'MEDIUM':
          return const Duration(hours: 1);
        case 'LOW':
          return const Duration(hours: 8);
        default:
          return null;
      }
    }
    return null;
  }

  static String _formatInquiryGenerated(String? createdAt) {
    if (createdAt == null || createdAt.trim().isEmpty) return '-';
    try {
      final dt = DateTime.parse(createdAt);
      return DateFormat('dd/MM/yyyy @ h:mma').format(dt.toLocal());
    } catch (_) {
      return '-';
    }
  }

  /// First non-empty checklist `priority` as label (API: HIGH/MEDIUM/LOW).
  static String _priorityLabelFromChecklist(List<InquiryChecklistItem> checklist) {
    for (final c in checklist) {
      final p = c.priority?.trim();
      if (p == null || p.isEmpty) continue;
      switch (p.toUpperCase()) {
        case 'HIGH':
          return 'High';
        case 'MEDIUM':
          return 'Medium';
        case 'LOW':
          return 'Low';
        default:
          return p;
      }
    }
    return '-';
  }

  static InquiryPriorityTrend _priorityTrendFromChecklist(
    List<InquiryChecklistItem> checklist,
  ) {
    for (final c in checklist) {
      final p = c.priority?.trim();
      if (p == null || p.isEmpty) continue;
      return inquiryPriorityTrendFromApi(p);
    }
    return InquiryPriorityTrend.swap;
  }

  /// Live countdown text for the Priority column (see design: `00:15 min Left`, `1 day Left`).
  static String formatSlaCountdownLabel(DateTime deadline, DateTime now) {
    final remaining = deadline.difference(now);
    if (remaining.isNegative) return '0 min Left';
    final secs = remaining.inSeconds;
    if (secs < 3600) {
      final m = secs ~/ 60;
      final s = secs % 60;
      return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')} min Left';
    }
    if (secs < 24 * 3600) {
      final h = secs ~/ 3600;
      final m = (secs % 3600) ~/ 60;
      return '${h}h ${m}m Left';
    }
    final days = secs ~/ (24 * 3600);
    if (days >= 7) {
      final w = days ~/ 7;
      if (days % 7 == 0 && w >= 1) {
        return w == 1 ? '1 Week Left' : '$w Weeks Left';
      }
    }
    return days == 1 ? '1 day Left' : '$days days Left';
  }
}
