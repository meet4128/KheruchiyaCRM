/// Visual for the vendor table **Priority** column (driven by checklist `priority` from the API).
///
/// Mapping (icons + colors):
/// - **HIGH** → red up arrow ([InquiryPriorityTrend.up])
/// - **MEDIUM** → orange horizontal swap arrow ([InquiryPriorityTrend.swap])
/// - **LOW** → green down arrow ([InquiryPriorityTrend.down])
///
/// [InquiryManagementBloc] keeps [ListInquiryItem] only; this mapping is applied in
/// [VendorInquiryRow] / UI — not in the BLoC.
enum InquiryPriorityTrend { up, down, swap }

/// Maps API checklist `priority` string to [InquiryPriorityTrend] for icons + SLA row model.
InquiryPriorityTrend inquiryPriorityTrendFromApi(String? raw) {
  switch (raw?.trim().toUpperCase()) {
    case 'HIGH':
      return InquiryPriorityTrend.up;
    case 'LOW':
      return InquiryPriorityTrend.down;
    case 'MEDIUM':
      return InquiryPriorityTrend.swap;
    default:
      return InquiryPriorityTrend.swap;
  }
}
