import 'package:equatable/equatable.dart';

/// A single row rendered in the Manage Amendment results table.
///
/// [amendmentType] / [status] keep the raw API strings (used by the result-tab
/// filter and status colouring); the `*Label` fields are the display copy.
/// Columns with no field in the search response (departure / next-travel date,
/// role, booking channel) are surfaced as `'N/A'` — matching the design, which
/// itself shows `N/A` for those cells.
class AmendmentRowUi extends Equatable {
  const AmendmentRowUi({
    required this.id,
    required this.inquiryId,
    required this.amendmentId,
    required this.bookingId,
    required this.amendmentType,
    required this.typeLabel,
    required this.status,
    required this.statusLabel,
    required this.bookedBy,
    required this.generatedTime,
    this.departureDate = 'N/A',
    this.nextTravelDate = 'N/A',
    this.role = 'N/A',
    this.bookingChannel = 'N/A',
  });

  final String id;
  final String inquiryId;
  final String amendmentId;
  final String bookingId;

  final String? amendmentType;
  final String typeLabel;
  final String? status;
  final String statusLabel;

  final String bookedBy;
  final String generatedTime;
  final String departureDate;
  final String nextTravelDate;
  final String role;
  final String bookingChannel;

  @override
  List<Object?> get props => [
        id,
        inquiryId,
        amendmentId,
        bookingId,
        amendmentType,
        typeLabel,
        status,
        statusLabel,
        bookedBy,
        generatedTime,
        departureDate,
        nextTravelDate,
        role,
        bookingChannel,
      ];
}
