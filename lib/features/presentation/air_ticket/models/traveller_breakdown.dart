import 'package:equatable/equatable.dart';

/// Adult / child / infant counts for flight booking.
class TravellerBreakdown extends Equatable {
  const TravellerBreakdown({
    this.adultCount = 1,
    this.childCount = 0,
    this.infantCount = 0,
  });

  static const int maxTravellers = 9;

  final int adultCount;
  final int childCount;
  final int infantCount;

  int get totalCount => adultCount + childCount + infantCount;

  bool get isValid =>
      adultCount >= 1 &&
      totalCount >= 1 &&
      totalCount <= maxTravellers &&
      infantCount <= adultCount;

  TravellerBreakdown copyWith({
    int? adultCount,
    int? childCount,
    int? infantCount,
  }) {
    return TravellerBreakdown(
      adultCount: adultCount ?? this.adultCount,
      childCount: childCount ?? this.childCount,
      infantCount: infantCount ?? this.infantCount,
    );
  }

  /// Compact label for the form field, e.g. "2 Adults, 1 Child, Economy".
  static String displayLabel({
    required int adultCount,
    required int childCount,
    required int infantCount,
    String? classType,
  }) {
    final parts = <String>[];
    if (adultCount > 0) {
      parts.add('$adultCount Adult${adultCount > 1 ? 's' : ''}');
    }
    if (childCount > 0) {
      parts.add('$childCount Child${childCount > 1 ? 'ren' : ''}');
    }
    if (infantCount > 0) {
      parts.add('$infantCount Infant${infantCount > 1 ? 's' : ''}');
    }
    final travellers = parts.isEmpty ? '1 Adult' : parts.join(', ');
    if (classType != null && classType.isNotEmpty) {
      return '$travellers, $classType';
    }
    return travellers;
  }

  String displayLabelWithClass(String? classType) => displayLabel(
        adultCount: adultCount,
        childCount: childCount,
        infantCount: infantCount,
        classType: classType,
      );

  @override
  List<Object?> get props => [adultCount, childCount, infantCount];
}
