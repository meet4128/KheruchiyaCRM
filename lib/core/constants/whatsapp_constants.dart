/// Approved Meta WhatsApp template settings for Kheruchiya greeting.
class WhatsappConstants {
  WhatsappConstants._();

  static const String templateName = 'kheruchiya_greeting';
  static const String templateLanguage = 'en';

  /// Matches approved Meta template; only `{{1}}` is dynamic (customer name).
  static const String templatePreviewFormat =
      'Hello %s, thank you for contacting Kheruchiya. '
      'Our team will assist you with your inquiry. '
      'Please reply to this message to continue the conversation.';

  static String templatePreview(String customerName) {
    final name = customerName.trim().isEmpty ? 'there' : customerName.trim();
    return templatePreviewFormat.replaceFirst('%s', name);
  }
}
