import 'package:intl/intl.dart';
import 'package:travel_crm/data/models/amendment/amendment_summary_dto.dart';
import 'package:travel_crm/features/presentation/manage_amendment/models/amendment_filter_options.dart';
import 'package:travel_crm/features/presentation/manage_amendment/models/amendment_row_ui.dart';

/// Maps a `/amendments/search` DTO to the table row model. Missing / unknown
/// values fall back to `'N/A'` so the table never renders empty cells.
AmendmentRowUi amendmentRowFromDto(AmendmentSummaryDto dto) {
  final amendmentId = _orNa(dto.amendmentId);
  return AmendmentRowUi(
    id: dto.id ?? '',
    inquiryId: dto.inquiryId ?? '',
    amendmentId: amendmentId,
    // The search response has no separate booking reference; fall back to the
    // parent inquiry id, then the amendment id (mirrors the design mock).
    bookingId: dto.inquiryId?.isNotEmpty == true ? dto.inquiryId! : amendmentId,
    amendmentType: dto.amendmentType,
    typeLabel: AmendmentTypeOption.fromApi(dto.amendmentType)?.label ??
        _humanize(dto.amendmentType),
    status: dto.status,
    statusLabel: AmendmentStatusOption.fromApi(dto.status)?.label ??
        _humanize(dto.status),
    bookedBy: _orNa(dto.createdBy),
    generatedTime: _formatDateTime(dto.createdAt),
  );
}

List<AmendmentRowUi> amendmentRowsFromDtos(List<AmendmentSummaryDto> dtos) =>
    dtos.map(amendmentRowFromDto).toList();

String _orNa(String? value) =>
    (value != null && value.trim().isNotEmpty) ? value.trim() : 'N/A';

/// Turns an unknown snake_case enum into a readable label ("re_issue" → "Re Issue").
String _humanize(String? raw) {
  if (raw == null || raw.trim().isEmpty) return 'N/A';
  return raw
      .split(RegExp(r'[_\s]+'))
      .where((w) => w.isNotEmpty)
      .map((w) => w[0].toUpperCase() + w.substring(1))
      .join(' ');
}

String _formatDateTime(String? iso) {
  if (iso == null || iso.trim().isEmpty) return 'N/A';
  final parsed = DateTime.tryParse(iso);
  if (parsed == null) return 'N/A';
  return DateFormat('dd/MM/yyyy @ h:mma').format(parsed.toLocal());
}
