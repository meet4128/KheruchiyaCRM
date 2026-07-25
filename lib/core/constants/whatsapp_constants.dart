/// Approved Meta WhatsApp template settings for Kheruchiya.
class WhatsappConstants {
  WhatsappConstants._();

  /// Shared language code for all approved templates (Meta: "English").
  static const String templateLanguage = 'en';

  // ---------------------------------------------------------------------------
  // Greeting (single dynamic param: customer name).
  // ---------------------------------------------------------------------------
  static const String templateName = 'kheruchiya_greeting';

  /// Matches approved Meta template; only `{{1}}` is dynamic (customer name).
  static const String templatePreviewFormat =
      'Hello %s, thank you for contacting Kheruchiya. '
      'Our team will assist you with your inquiry. '
      'Please reply to this message to continue the conversation.';

  static String templatePreview(String customerName) {
    final name = customerName.trim().isEmpty ? 'there' : customerName.trim();
    return templatePreviewFormat.replaceFirst('%s', name);
  }

  // ---------------------------------------------------------------------------
  // Flight ticket inquiry templates (approved as Marketing category on Meta).
  //
  // Body params must be single-line values (Meta rejects params containing
  // newlines, tabs, or 4+ consecutive spaces) — the multi-line layout lives in
  // the approved template body, not in the params.
  //
  // Round trip (also used for multi-city, mapping the last leg as the return):
  //   {{1}} name            {{2}} onward from   {{3}} onward to   {{4}} onward date
  //   {{5}} return from      {{6}} return to     {{7}} return date
  //   {{8}} passengers       {{9}} notes
  //
  // One way:
  //   {{1}} name  {{2}} from  {{3}} to  {{4}} date  {{5}} passengers  {{6}} notes
  // ---------------------------------------------------------------------------
  static const String flightRoundTripTemplateName = 'flight_inquiry_roundtrip';
  static const String flightOneWayTemplateName = 'flight_inquiry_oneway';

  static bool isFlightTemplate(String? name) =>
      name == flightRoundTripTemplateName || name == flightOneWayTemplateName;

  // ---------------------------------------------------------------------------
  // Hotel booking inquiry template.
  //   {{1}} name  {{2}} destination  {{3}} check-in  {{4}} check-out
  //   {{5}} rooms  {{6}} guests  {{7}} notes
  // ---------------------------------------------------------------------------
  static const String hotelInquiryTemplateName = 'hotel_inquiry';

  /// True when [name] is any known inquiry template (greeting, flight, hotel).
  static bool isKnownTemplate(String? name) =>
      name == templateName ||
      isFlightTemplate(name) ||
      name == hotelInquiryTemplateName;

  /// Rebuilds a readable chat-log preview of a known template from its ordered
  /// body params. Returns `null` for unknown templates so callers can fall back.
  static String? previewFromParams(String? name, List<String> params) {
    switch (name) {
      case templateName:
        return templatePreview(params.isNotEmpty ? params.first : '');
      case flightRoundTripTemplateName:
        return _flightRoundTripPreview(params);
      case flightOneWayTemplateName:
        return _flightOneWayPreview(params);
      case hotelInquiryTemplateName:
        return _hotelInquiryPreview(params);
    }
    return null;
  }

  static String _param(List<String> params, int index) =>
      index < params.length ? params[index] : '';

  static String _flightRoundTripPreview(List<String> p) {
    final name = _param(p, 0).trim().isEmpty ? 'there' : _param(p, 0);
    return 'Dear $name,\n'
        '\n'
        'Thank you for contacting Kheruchiya Travel Hub Pvt. Ltd. for your Flight Ticket Inquiry.\n'
        '\n'
        'Your Travel Inquiry Details:\n'
        '\n'
        '✈️ Onward Journey\n'
        'From: ${_param(p, 1)}\n'
        'To: ${_param(p, 2)}\n'
        'Date: ${_param(p, 3)}\n'
        '\n'
        '✈️ Return Journey\n'
        'From: ${_param(p, 4)}\n'
        'To: ${_param(p, 5)}\n'
        'Date: ${_param(p, 6)}\n'
        '\n'
        '👥 Passengers: ${_param(p, 7)}\n'
        '\n'
        '📝 Special Requirements / Notes: ${_param(p, 8)}\n'
        '\n'
        'Our travel expert will connect with you shortly with the best available flight options and fares.\n'
        '\n'
        'Thank you for choosing Kheruchiya Travel Hub Pvt. Ltd.\n'
        '\n'
        'Contact: +91 2762 353535\n'
        '\n'
        'We Don\'t Just Book Tickets, We Provide Complete Travel Support.';
  }

  static String _flightOneWayPreview(List<String> p) {
    final name = _param(p, 0).trim().isEmpty ? 'there' : _param(p, 0);
    return 'Dear $name,\n'
        '\n'
        'Thank you for contacting Kheruchiya Travel Hub Pvt. Ltd. for your Flight Ticket Inquiry.\n'
        '\n'
        'Your Travel Inquiry Details:\n'
        '\n'
        '✈️ Journey Details\n'
        'From: ${_param(p, 1)}\n'
        'To: ${_param(p, 2)}\n'
        'Date: ${_param(p, 3)}\n'
        '\n'
        '👥 Passengers: ${_param(p, 4)}\n'
        '\n'
        '📝 Special Requirements / Notes: ${_param(p, 5)}\n'
        '\n'
        'Our travel expert will connect with you shortly with the best available flight options and fares.\n'
        '\n'
        'Thank you for choosing Kheruchiya Travel Hub Pvt. Ltd.\n'
        '\n'
        'Contact: +91 2762 353535\n'
        '\n'
        'We Don\'t Just Book Tickets, We Provide Complete Travel Support.';
  }

  static String _hotelInquiryPreview(List<String> p) {
    final name = _param(p, 0).trim().isEmpty ? 'there' : _param(p, 0);
    return 'Dear $name,\n'
        '\n'
        'Thank you for contacting Kheruchiya Travel Hub Pvt. Ltd. for your Hotel Booking Inquiry.\n'
        '\n'
        'Your Booking Inquiry Details:\n'
        '\n'
        '🏨 Destination: ${_param(p, 1)}\n'
        '📅 Check-in: ${_param(p, 2)}\n'
        '📅 Check-out: ${_param(p, 3)}\n'
        '🛏 Rooms: ${_param(p, 4)}\n'
        '👥 Guests: ${_param(p, 5)}\n'
        '\n'
        '📝 Special Requirements / Notes: ${_param(p, 6)}\n'
        '\n'
        'Our travel expert will connect with you shortly with the best available hotel options and rates.\n'
        '\n'
        'Thank you for choosing Kheruchiya Travel Hub Pvt. Ltd.\n'
        '\n'
        'Contact: +91 2762 353535\n'
        '\n'
        'We Don\'t Just Book Hotels, We Provide Complete Travel Support.';
  }
}
