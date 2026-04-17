// Date Helper for NexaTrace System
// This file contains utility functions for date and time operations

import 'package:intl/intl.dart';

class DateHelper {
  // Date formatters
  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat _dateTimeFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
  static final DateFormat _displayDateFormat = DateFormat('dd MMM yyyy');
  static final DateFormat _displayDateTimeFormat = DateFormat(
    'dd MMM yyyy HH:mm',
  );
  static final DateFormat _timeFormat = DateFormat('HH:mm:ss');

  // Parse date from string
  static DateTime? parseDate(String dateString) {
    try {
      return _dateFormat.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  // Parse date time from string
  static DateTime? parseDateTime(String dateTimeString) {
    try {
      return _dateTimeFormat.parse(dateTimeString);
    } catch (e) {
      return null;
    }
  }

  // Format date to string
  static String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }

  // Format date time to string
  static String formatDateTime(DateTime dateTime) {
    return _dateTimeFormat.format(dateTime);
  }

  // Format date for display
  static String formatDateForDisplay(DateTime date) {
    return _displayDateFormat.format(date);
  }

  // Format date time for display
  static String formatDateTimeForDisplay(DateTime dateTime) {
    return _displayDateTimeFormat.format(dateTime);
  }

  // Format time for display
  static String formatTimeForDisplay(DateTime dateTime) {
    return _timeFormat.format(dateTime);
  }

  // Get current date as string
  static String getCurrentDate() {
    return formatDate(DateTime.now());
  }

  // Get current date time as string
  static String getCurrentDateTime() {
    return formatDateTime(DateTime.now());
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

  // Calculate days between two dates
  static int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }

  // Add days to date
  static DateTime addDays(DateTime date, int days) {
    return date.add(Duration(days: days));
  }

  // Subtract days from date
  static DateTime subtractDays(DateTime date, int days) {
    return date.subtract(Duration(days: days));
  }

  // Check if date is in the past
  static bool isPastDate(DateTime date) {
    return date.isBefore(DateTime.now());
  }

  // Check if date is in the future
  static bool isFutureDate(DateTime date) {
    return date.isAfter(DateTime.now());
  }

  // Get start of day
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  // Get end of day
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  // Calculate age from birth date
  static int calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  // Format duration
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  // Get month name
  static String getMonthName(int month) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  // Get short month name
  static String getShortMonthName(int month) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  // Get day name
  static String getDayName(int day) {
    final days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[day - 1];
  }

  // Get short day name
  static String getShortDayName(int day) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[day - 1];
  }

  // Validate date range
  static bool isValidDateRange(DateTime startDate, DateTime endDate) {
    return endDate.isAfter(startDate) || endDate.isAtSameMomentAs(startDate);
  }

  // Check if date is within range
  static bool isDateInRange(
    DateTime date,
    DateTime startDate,
    DateTime endDate,
  ) {
    return (date.isAfter(startDate) || date.isAtSameMomentAs(startDate)) &&
        (date.isBefore(endDate) || date.isAtSameMomentAs(endDate));
  }

  // Get quarter from date
  static int getQuarter(DateTime date) {
    return ((date.month - 1) / 3).floor() + 1;
  }

  // Get financial year
  static String getFinancialYear(DateTime date, {int startMonth = 7}) {
    final year = date.year;
    if (date.month >= startMonth) {
      return '$year-${year + 1}';
    } else {
      return '${year - 1}-$year';
    }
  }
}
