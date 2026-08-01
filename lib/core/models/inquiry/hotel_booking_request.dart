import 'package:json_annotation/json_annotation.dart';

part 'hotel_booking_request.g.dart';

@JsonSerializable(explicitToJson: true)
class HotelBookingRequest {
  const HotelBookingRequest({
    required this.city,
    required this.checkInDate,
    this.checkInDateEnd,
    required this.checkOutDate,
    this.checkOutDateEnd,
    required this.rooms,
    required this.adults,
    required this.propertyType,
    required this.hotelCategory,
    required this.roomViews,
    required this.amenities,
    required this.mealPlan,
    required this.transfers,
    required this.budgetMin,
    required this.budgetMax,
    required this.remark,
  });

  factory HotelBookingRequest.fromJson(Map<String, dynamic> json) =>
      _$HotelBookingRequestFromJson(json);

  Map<String, dynamic> toJson() => _$HotelBookingRequestToJson(this);

  final String city;
  final String checkInDate;

  /// End of the check-in flexible window (ISO 8601). Omitted when the guest
  /// picked a single check-in day. Mirrors flight segment `departureDateEnd`.
  @JsonKey(includeIfNull: false)
  final String? checkInDateEnd;
  final String checkOutDate;

  /// End of the check-out flexible window (ISO 8601). Omitted when the guest
  /// picked a single check-out day.
  @JsonKey(includeIfNull: false)
  final String? checkOutDateEnd;
  final int rooms;
  final int adults;
  final List<String> propertyType;
  final List<String> hotelCategory;
  final List<String> roomViews;
  final List<String> amenities;
  final List<String> mealPlan;
  final List<String> transfers;
  final String budgetMin;
  final String budgetMax;
  final String remark;
}
