import 'package:intl/intl.dart';
import 'package:travel_crm/data/models/amendment/amendment_detail_dto.dart';
import 'package:travel_crm/data/models/inquiry/inquiry_checklist_item.dart';
import 'package:travel_crm/features/presentation/inquiry_management/mappers/amendment_mapper.dart';
import 'package:travel_crm/features/presentation/inquiry_management/models/amendment_card_body_ui.dart';
import 'package:travel_crm/features/presentation/inquiry_management/models/amendment_card_ui.dart';

String _displayOrDash(String? value) {
  final t = value?.trim();
  if (t == null || t.isEmpty) return '—';
  return t;
}

String _formatDateTime(String? raw) {
  if (raw == null || raw.trim().isEmpty) return 'N/A';
  try {
    return DateFormat('dd/MM/yyyy @ h:mma').format(DateTime.parse(raw).toLocal());
  } catch (_) {
    return raw;
  }
}

String _checklistLabel(InquiryChecklistItem item) {
  final category = item.category?.trim();
  if (category != null && category.isNotEmpty) {
    return checklistCategoryLabel(category);
  }
  final user = item.user?.trim();
  if (user != null && user.isNotEmpty) return user;
  return 'Item';
}

String checklistCategoryLabel(String category) {
  switch (category.toLowerCase()) {
    case 'in_loop':
    case 'inloop':
      return 'In Loop';
    case 'baggage':
      return 'Baggage';
    case 'visa':
      return 'Visa';
    case 'meal':
      return 'Meal';
    default:
      return category.replaceAll('_', ' ');
  }
}

bool _checklistIsChecked(InquiryChecklistItem item) {
  final p = item.priority?.trim().toLowerCase();
  return p == 'true' || p == 'checked' || p == 'yes' || p == '1';
}

AmendmentCardBodyUi amendmentBodyFromDetail(
  AmendmentDetailDto dto, {
  required AmendmentCardUi summary,
  List<InquiryChecklistItem> fallbackChecklist = const [],
}) {
  final checklistSource =
      dto.checklist.isNotEmpty ? dto.checklist : fallbackChecklist;

  final checklistItems = checklistSource
      .map(
        (c) => AmendmentChecklistUiItem(
          label: _checklistLabel(c),
          isChecked: _checklistIsChecked(c),
        ),
      )
      .toList(growable: false);

  final attachmentCount = dto.attachments?.length ?? 0;

  return AmendmentCardBodyUi(
    raisedBy: _displayOrDash(dto.raisedBy ?? dto.createdBy),
    bookedBy: _displayOrDash(dto.bookedBy),
    assignedStaff: _displayOrDash(dto.assignedStaff ?? dto.assignedTo),
    amendmentInvoice: dto.amendmentInvoice?.trim().isNotEmpty == true
        ? dto.amendmentInvoice!.trim()
        : formatAmountCharged(dto.amountCharged ?? summary.amountCharged),
    remarks: _displayOrDash(dto.remarks),
    nextTravelDate: _displayOrDash(dto.nextTravelDate),
    processedTime: _formatDateTime(dto.processedAt ?? summary.processedAt?.toIso8601String()),
    generationTime: _formatDateTime(dto.createdAt ?? summary.createdAt?.toIso8601String()),
    attachmentsDisplay: attachmentCount > 0 ? '$attachmentCount file(s)' : 'N/A',
    invoiceDownloadUrl: dto.invoiceUrl?.trim().isNotEmpty == true ? dto.invoiceUrl : null,
    checklistItems: checklistItems,
  );
}

/// Fallback body from list summary only (before detail GET returns).
AmendmentCardBodyUi amendmentBodyFromSummary(
  AmendmentCardUi summary, {
  List<InquiryChecklistItem> fallbackChecklist = const [],
}) {
  return AmendmentCardBodyUi(
    raisedBy: '—',
    bookedBy: '—',
    assignedStaff: '—',
    amendmentInvoice: summary.amountChargedDisplay,
    remarks: 'N/A',
    nextTravelDate: 'N/A',
    processedTime: summary.processedAt != null
        ? _formatDateTime(summary.processedAt!.toIso8601String())
        : 'N/A',
    generationTime: summary.createdAt != null
        ? _formatDateTime(summary.createdAt!.toIso8601String())
        : 'N/A',
    attachmentsDisplay: 'N/A',
    checklistItems: fallbackChecklist
        .map(
          (c) => AmendmentChecklistUiItem(
            label: _checklistLabel(c),
            isChecked: _checklistIsChecked(c),
          ),
        )
        .toList(growable: false),
  );
}
