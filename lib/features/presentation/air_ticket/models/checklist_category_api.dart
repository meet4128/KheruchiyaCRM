import 'package:travel_crm/core/constants/string_constants.dart';

/// Maps checklist category UI labels to POST `checklist[].category` codes.
String checklistCategoryToApi(String? raw) {
  final t = (raw ?? '').trim();
  if (t.isEmpty) return '';
  if (t == StringConstant.documentation) return 'DOCUMENTS';
  if (t == StringConstant.payment) return 'PAYMENT';
  if (t == StringConstant.visa) return 'VISA';
  if (t == StringConstant.other) return 'OTHER';
  return t.toUpperCase().replaceAll(RegExp(r'\s+'), '_');
}
