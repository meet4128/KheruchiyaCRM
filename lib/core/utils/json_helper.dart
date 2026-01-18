import 'dart:convert';

String prettyPrintJson(String? jsonString) {
  if (jsonString == null || jsonString.isEmpty) return 'N/A';
  try {
    final jsonObj = jsonDecode(jsonString);
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(jsonObj);
  } catch (e) {
    return jsonString;
  }
}
