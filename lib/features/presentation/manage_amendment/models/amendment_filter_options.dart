// Dropdown options + result-tab definitions for the Manage Amendment screen.
//
// Enum strings match the live OpenAPI spec (`GET /api/v1/amendments/search`):
//   amendmentType ∈ re_issue | cancelation | booking
//   status        ∈ followup | pending | loss | completed
// See docs/openapi.json (Amendments tag).

/// "Type" dropdown → `amendmentType` query param.
enum AmendmentTypeOption {
  reIssue('re_issue', 'Re-issue'),
  cancelation('cancelation', 'Cancellation'),
  booking('booking', 'Booking');

  const AmendmentTypeOption(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static AmendmentTypeOption? fromApi(String? value) {
    if (value == null) return null;
    for (final option in AmendmentTypeOption.values) {
      if (option.apiValue == value) return option;
    }
    return null;
  }
}

/// "Status" dropdown → `status` query param.
enum AmendmentStatusOption {
  followup('followup', 'Follow Up'),
  pending('pending', 'Pending'),
  loss('loss', 'Loss'),
  completed('completed', 'Completed');

  const AmendmentStatusOption(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static AmendmentStatusOption? fromApi(String? value) {
    if (value == null) return null;
    for (final option in AmendmentStatusOption.values) {
      if (option.apiValue == value) return option;
    }
    return null;
  }
}

/// Client-side result tabs above the results table. These filter already-fetched
/// rows by the real `status` enum (the API returns no per-tab counts).
enum AmendmentResultTab {
  all('All', null),
  followup('Follow Up', 'followup'),
  pending('Pending', 'pending'),
  completed('Completed', 'completed');

  const AmendmentResultTab(this.label, this.statusValue);

  final String label;

  /// The `status` this tab matches, or null for [all].
  final String? statusValue;

  bool matches({String? amendmentType, String? status}) =>
      statusValue == null || status == statusValue;
}
