// Date Utilities for NexaTrace System
// Provides date formatting, parsing, and manipulation utilities

import 'package:intl/intl.dart';

class DateUtils {
  // Date formats
  static const String dateFormat = 'yyyy-MM-dd';
  static const String timeFormat = 'HH:mm:ss';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm:ss';
  static const String displayDateFormat = 'MMM dd, yyyy';
  static const String displayDateTimeFormat = 'MMM dd, yyyy HH:mm';
  static const String displayTimeFormat = 'HH:mm';
  static const String apiDateFormat = 'yyyy-MM-dd';
  static const String apiDateTimeFormat = 'yyyy-MM-ddTHH:mm:ss';

  // Format date to string
  static String formatDate(DateTime date, {String format = dateFormat}) {
    return DateFormat(format).format(date);
  }

  // Parse string to date
  static DateTime? parseDate(String dateString, {String format = dateFormat}) {
    try {
      return DateFormat(format).parse(dateString);
    } catch (e) {
      return null;
    }
  }

  // Format date for display
  static String formatDateForDisplay(DateTime date) {
    return DateFormat(displayDateFormat).format(date);
  }

  // Format date time for display
  static String formatDateTimeForDisplay(DateTime date) {
    return DateFormat(displayDateTimeFormat).format(date);
  }

  // Format time for display
  static String formatTimeForDisplay(DateTime date) {
    return DateFormat(displayTimeFormat).format(date);
  }

  // Format date for API
  static String formatDateForApi(DateTime date) {
    return DateFormat(apiDateFormat).format(date);
  }

  // Format date time for API
  static String formatDateTimeForApi(DateTime date) {
    return DateFormat(apiDateTimeFormat).format(date);
  }

  // Parse API date string
  static DateTime? parseApiDate(String dateString) {
    return parseDate(dateString, format: apiDateFormat);
  }

  // Parse API date time string
  static DateTime? parseApiDateTime(String dateTimeString) {
    return parseDate(dateTimeString, format: apiDateTimeFormat);
  }

  // Get current date
  static DateTime get currentDate => DateTime.now();

  // Get current date time
  static DateTime get currentDateTime => DateTime.now();

  // Get start of day
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  // Get end of day
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  // Get start of week (Monday)
  static DateTime startOfWeek(DateTime date) {
    final weekday = date.weekday;
    return date.subtract(Duration(days: weekday - 1));
  }

  // Get end of week (Sunday)
  static DateTime endOfWeek(DateTime date) {
    final weekday = date.weekday;
    return date.add(Duration(days: 7 - weekday));
  }

  // Get start of month
  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  // Get end of month
  static DateTime endOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }

  // Get start of year
  static DateTime startOfYear(DateTime date) {
    return DateTime(date.year, 1, 1);
  }

  // Get end of year
  static DateTime endOfYear(DateTime date) {
    return DateTime(date.year, 12, 31);
  }

  // Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  // Check if date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  // Check if date is tomorrow
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day;
  }

  // Check if date is in the past
  static bool isPast(DateTime date) {
    return date.isBefore(DateTime.now());
  }

  // Check if date is in the future
  static bool isFuture(DateTime date) {
    return date.isAfter(DateTime.now());
  }

  // Get relative time string (e.g., "2 hours ago", "in 3 days")
  static String getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return '$days ${days == 1 ? 'day' : 'days'} ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }

  // Get time ago string (simplified version)
  static String timeAgo(DateTime date) {
    return getRelativeTime(date);
  }

  // Format duration
  static String formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours.remainder(24)}h';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ${duration.inSeconds.remainder(60)}s';
    } else {
      return '${duration.inSeconds}s';
    }
  }

  // Get age from birth date
  static int getAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  // Add business days (excluding weekends)
  static DateTime addBusinessDays(DateTime date, int days) {
    DateTime result = date;
    int addedDays = 0;

    while (addedDays < days) {
      result = result.add(const Duration(days: 1));
      if (result.weekday != DateTime.saturday &&
          result.weekday != DateTime.sunday) {
        addedDays++;
      }
    }

    return result;
  }

  // Check if date is weekday
  static bool isWeekday(DateTime date) {
    return date.weekday != DateTime.saturday && date.weekday != DateTime.sunday;
  }

  // Check if date is weekend
  static bool isWeekend(DateTime date) {
    return date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
  }

  // Get days between two dates
  static int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }

  // Get months between two dates
  static int monthsBetween(DateTime from, DateTime to) {
    return (to.year - from.year) * 12 + to.month - from.month;
  }

  // Get years between two dates
  static int yearsBetween(DateTime from, DateTime to) {
    return to.year - from.year;
  }

  // Check if year is leap year
  static bool isLeapYear(int year) {
    return (year % 4 == 0) && ((year % 100 != 0) || (year % 400 == 0));
  }

  // Get days in month
  static int daysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  // Get quarter from date
  static int getQuarter(DateTime date) {
    return ((date.month - 1) / 3).floor() + 1;
  }

  // Get fiscal year (assuming fiscal year starts in April)
  static int getFiscalYear(DateTime date, {int startMonth = 4}) {
    if (date.month >= startMonth) {
      return date.year;
    } else {
      return date.year - 1;
    }
  }

  // Extension methods for DateTime
  static DateTimeExtension on(DateTime date) => DateTimeExtension(date);
}

// Extension methods for DateTime
class DateTimeExtension {
  final DateTime _date;

  DateTimeExtension(this._date);

  // Format methods
  String format({String format = DateUtils.dateFormat}) {
    return DateUtils.formatDate(_date, format: format);
  }

  String formatForDisplay() {
    return DateUtils.formatDateForDisplay(_date);
  }

  String formatDateTimeForDisplay() {
    return DateUtils.formatDateTimeForDisplay(_date);
  }

  String formatTimeForDisplay() {
    return DateUtils.formatTimeForDisplay(_date);
  }

  String formatForApi() {
    return DateUtils.formatDateForApi(_date);
  }

  String formatDateTimeForApi() {
    return DateUtils.formatDateTimeForApi(_date);
  }

  // Relative time
  String get relativeTime => DateUtils.getRelativeTime(_date);
  String get timeAgo => DateUtils.timeAgo(_date);

  // Date operations
  DateTime get startOfDay => DateUtils.startOfDay(_date);
  DateTime get endOfDay => DateUtils.endOfDay(_date);
  DateTime get startOfWeek => DateUtils.startOfWeek(_date);
  DateTime get endOfWeek => DateUtils.endOfWeek(_date);
  DateTime get startOfMonth => DateUtils.startOfMonth(_date);
  DateTime get endOfMonth => DateUtils.endOfMonth(_date);
  DateTime get startOfYear => DateUtils.startOfYear(_date);
  DateTime get endOfYear => DateUtils.endOfYear(_date);

  // Checks
  bool get isToday => DateUtils.isToday(_date);
  bool get isYesterday => DateUtils.isYesterday(_date);
  bool get isTomorrow => DateUtils.isTomorrow(_date);
  bool get isPast => DateUtils.isPast(_date);
  bool get isFuture => DateUtils.isFuture(_date);
  bool get isWeekday => DateUtils.isWeekday(_date);
  bool get isWeekend => DateUtils.isWeekend(_date);

  // Age
  int get age => DateUtils.getAge(_date);

  // Quarter
  int get quarter => DateUtils.getQuarter(_date);

  // Fiscal year
  int get fiscalYear => DateUtils.getFiscalYear(_date);

  // Add business days
  DateTime addBusinessDays(int days) => DateUtils.addBusinessDays(_date, days);

  // Days between
  int daysBetween(DateTime other) => DateUtils.daysBetween(_date, other);
  int monthsBetween(DateTime other) => DateUtils.monthsBetween(_date, other);
  int yearsBetween(DateTime other) => DateUtils.yearsBetween(_date, other);
}

// Extension on DateTime for easier usage
extension DateTimeExtensions on DateTime {
  DateTimeExtension get ext => DateTimeExtension(this);

  // Quick format methods
  String format({String format = DateUtils.dateFormat}) =>
      DateUtils.formatDate(this, format: format);

  String formatDate() => DateUtils.formatDateForDisplay(this);
  String formatDateTime() => DateUtils.formatDateTimeForDisplay(this);
  String formatTime() => DateUtils.formatTimeForDisplay(this);

  // Quick relative time
  String get relativeTime => DateUtils.getRelativeTime(this);
  String get timeAgo => DateUtils.timeAgo(this);

  // Quick checks
  bool get isToday => DateUtils.isToday(this);
  bool get isYesterday => DateUtils.isYesterday(this);
  bool get isTomorrow => DateUtils.isTomorrow(this);
  bool get isPast => DateUtils.isPast(this);
  bool get isFuture => DateUtils.isFuture(this);
  bool get isWeekday => DateUtils.isWeekday(this);
  bool get isWeekend => DateUtils.isWeekend(this);

  // Quick operations
  DateTime get startOfDay => DateUtils.startOfDay(this);
  DateTime get endOfDay => DateUtils.endOfDay(this);
}
