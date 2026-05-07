import 'package:intl/intl.dart';

/// Utility class for formatting dates in a human-readable format.
///
/// All dates are stored in ISO 8601 format in the database,
/// and this helper converts them for UI display.
class DateFormatter {
  DateFormatter._();

  // ─────────────────────────────────────────────────────────────────────────
  // Predefined Formatters
  // ─────────────────────────────────────────────────────────────────────────

  /// Formats date as "April 9, 2026"
  static final DateFormat _fullDate = DateFormat('MMMM d, y');

  /// Formats date as "Apr 9, 2026"
  static final DateFormat _shortDate = DateFormat('MMM d, y');

  /// Formats date as "04/09/2026"
  static final DateFormat _numericDate = DateFormat('MM/dd/yyyy');

  /// Formats date as "April 9"
  static final DateFormat _monthDay = DateFormat('MMMM d');

  /// Formats date as "09 Apr 2026"
  static final DateFormat _dmyDate = DateFormat('dd MMM y');

  /// Formats date as "2026-04-09"
  static final DateFormat _isoDate = DateFormat('yyyy-MM-dd');

  /// Formats date and time as "April 9, 2026 at 3:30 PM"
  static final DateFormat _fullDateTime = DateFormat('MMMM d, y \'at\' h:mm a');

  /// Formats time as "3:30 PM"
  static final DateFormat _timeOnly = DateFormat('h:mm a');

  // ─────────────────────────────────────────────────────────────────────────
  // Main Formatting Methods
  // ─────────────────────────────────────────────────────────────────────────

  /// Formats a DateTime or ISO 8601 string to "April 9, 2026"
  ///
  /// Returns an empty string if [date] is null.
  static String formatFull(DateTime? date) {
    if (date == null) return '';
    return _fullDate.format(date);
  }

  /// Formats a DateTime or ISO 8601 string to "Apr 9, 2026"
  ///
  /// Returns an empty string if [date] is null.
  static String formatShort(DateTime? date) {
    if (date == null) return '';
    return _shortDate.format(date);
  }

  /// Formats a DateTime or ISO 8601 string to "04/09/2026"
  ///
  /// Returns an empty string if [date] is null.
  static String formatNumeric(DateTime? date) {
    if (date == null) return '';
    return _numericDate.format(date);
  }

  /// Formats a DateTime or ISO 8601 string to "April 9"
  /// (useful for showing deadline month/day without year)
  ///
  /// Returns an empty string if [date] is null.
  static String formatMonthDay(DateTime? date) {
    if (date == null) return '';
    return _monthDay.format(date);
  }

  /// Formats a DateTime or ISO 8601 string to "09 Apr 2026"
  ///
  /// Returns an empty string if [date] is null.
  static String formatDMY(DateTime? date) {
    if (date == null) return '';
    return _dmyDate.format(date);
  }

  /// Formats a DateTime or ISO 8601 string to "2026-04-09"
  ///
  /// Returns an empty string if [date] is null.
  static String formatISO(DateTime? date) {
    if (date == null) return '';
    return _isoDate.format(date);
  }

  /// Formats a DateTime or ISO 8601 string to "April 9, 2026 at 3:30 PM"
  ///
  /// Returns an empty string if [date] is null.
  static String formatFullDateTime(DateTime? date) {
    if (date == null) return '';
    return _fullDateTime.format(date);
  }

  /// Formats a DateTime or ISO 8601 string to "3:30 PM"
  ///
  /// Returns an empty string if [date] is null.
  static String formatTime(DateTime? date) {
    if (date == null) return '';
    return _timeOnly.format(date);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Parsing Methods
  // ─────────────────────────────────────────────────────────────────────────

  /// Parses an ISO 8601 string to DateTime.
  /// Returns null if parsing fails.
  static DateTime? parseISO(String? isoString) {
    if (isoString == null || isoString.isEmpty) return null;
    try {
      return DateTime.parse(isoString);
    } catch (e) {
      return null;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Utility Methods
  // ─────────────────────────────────────────────────────────────────────────

  /// Returns a human-readable relative time string like "in 5 days", "3 days ago"
  /// or "today" / "yesterday".
  ///
  /// Returns an empty string if [date] is null.
  static String formatRelative(DateTime? date) {
    if (date == null) return '';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);
    final difference = targetDate.difference(today).inDays;

    if (difference == 0) return 'Today';
    if (difference == 1) return 'Tomorrow';
    if (difference == -1) return 'Yesterday';
    if (difference > 1 && difference <= 7) return 'In $difference days';
    if (difference < -1 && difference >= -7) return '${-difference} days ago';

    return formatShort(date);
  }

  /// Returns the number of days remaining until [date].
  /// Returns null if [date] is null.
  /// Returns a negative number if the date has passed.
  static int? daysRemaining(DateTime? date) {
    if (date == null) return null;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);

    return targetDate.difference(today).inDays;
  }

  /// Checks if a date is in the past.
  /// Returns false if [date] is null.
  static bool isPast(DateTime? date) {
    if (date == null) return false;
    return date.isBefore(DateTime.now());
  }

  /// Checks if a date is today.
  /// Returns false if [date] is null.
  static bool isToday(DateTime? date) {
    if (date == null) return false;

    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}
