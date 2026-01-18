import 'package:intl/intl.dart';

class DateFormatHelper {
  // Common date formats used throughout the app
  static const String displayDate = 'd MMM yyyy';
  static const String displayDateTime = 'dd MMM yyyy, HH:mm';
  static const String apiDate = 'yyyy-MM-dd';
  static const String apiDateTime = 'yyyy-MM-dd HH:mm:ss';
  
  // Format date for display (e.g., "15 Jan 2024")
  static String formatDisplayDate(DateTime date) {
    return DateFormat(displayDate).format(date);
  }
  
  // Format date and time for display (e.g., "15 Jan 2024, 14:30")
  static String formatDisplayDateTime(DateTime dateTime) {
    return DateFormat(displayDateTime).format(dateTime);
  }
  
  // Format date for API (e.g., "2024-01-15")
  static String formatApiDate(DateTime date) {
    return DateFormat(apiDate).format(date);
  }
  
  // Format date and time for API (e.g., "2024-01-15 14:30:00")
  static String formatApiDateTime(DateTime dateTime) {
    return DateFormat(apiDateTime).format(dateTime);
  }
  
  // Parse display date string to DateTime
  static DateTime parseDisplayDate(String dateString) {
    return DateFormat(displayDate).parse(dateString);
  }
  
  // Parse display date time string to DateTime
  static DateTime parseDisplayDateTime(String dateTimeString) {
    return DateFormat(displayDateTime).parse(dateTimeString);
  }
  
  // Parse API date string to DateTime
  static DateTime parseApiDate(String dateString) {
    return DateFormat(apiDate).parse(dateString);
  }
  
  // Convert display date to API date format
  static String displayDateToApiDate(String displayDateString) {
    final date = parseDisplayDate(displayDateString);
    return formatApiDate(date);
  }
  
  // Convert API date to display date format
  static String apiDateToDisplayDate(String apiDateString) {
    final date = parseApiDate(apiDateString);
    return formatDisplayDate(date);
  }
  
  // Get current date in display format
  static String getCurrentDisplayDate() {
    return formatDisplayDate(DateTime.now());
  }
  
  // Get current date in API format
  static String getCurrentApiDate() {
    return formatApiDate(DateTime.now());
  }
}

extension DateTimeExtensions on DateTime {
  int getCurrentTimestamp() {
    DateTime now = toUtc(); // Use UTC for consistency
    return now.millisecondsSinceEpoch;
  }

  int getPreviousDayTimestamp({int previousDays = 1}) {
    DateTime now = toUtc(); // Use UTC for consistency
    DateTime previousDay = now.subtract(Duration(days: previousDays));
    return previousDay.millisecondsSinceEpoch;
  }
}

extension NormalTimeFromEpoc on int {
  String setTimeString({bool isToShowSeconds = false, bool isToShowOnlyDate = false}) {
    // Timestamp in milliseconds
    int timestamp = this;

    // Convert to DateTime (UTC)
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);

    // Format manually to "yyyy-MM-dd HH:mm"
    String formattedDate = '';
    if (isToShowSeconds) {
      formattedDate =
          '${dateTime.year}-'
          '${dateTime.month.toString().padLeft(2, '0')}-'
          '${dateTime.day.toString().padLeft(2, '0')}  '
          '${dateTime.hour.toString().padLeft(2, '0')}:'
          '${dateTime.minute.toString().padLeft(2, '0')}:'
          '${dateTime.second.toString().padLeft(2, '0')}';
    } else if (isToShowOnlyDate) {
      formattedDate =
          '${dateTime.year}-'
          '${dateTime.month.toString().padLeft(2, '0')}-'
          '${dateTime.day.toString().padLeft(2, '0')}';
    } else {
      formattedDate =
          '${dateTime.year}-'
          '${dateTime.month.toString().padLeft(2, '0')}-'
          '${dateTime.day.toString().padLeft(2, '0')}  '
          '${dateTime.hour.toString().padLeft(2, '0')}:'
          '${dateTime.minute.toString().padLeft(2, '0')}';
    }

    return formattedDate;
  }

}

extension StringListExtension on List<String> {
  /// Converts a List of string to a single String with a specified delimiter.
  String toSingleString({String delimiter = ','}) {
    return join(delimiter);
  }
}

extension StringToListExtension on String {
  /// Converts a String back to a List of string using a specified delimiter.
  List<String> toStringList({String delimiter = ','}) {
    return split(delimiter).map((e) => e.trim()).toList();
  }
}


