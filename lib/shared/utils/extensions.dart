// Extensions for NexaTrace System
// This file contains useful extensions for String, int, DateTime, etc.

import 'package:trace_odd/core/utils/date_utils.dart';
import 'package:trace_odd/core/utils/string_utils.dart';

// String extensions
extension StringExtensions on String {
  /// Capitalize first letter of the string
  String get capitalizeFirst {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }

  /// Capitalize first letter of each word
  String get capitalizeWords {
    return StringUtils.capitalizeWords(this);
  }

  /// Convert to title case
  String get toTitleCase {
    return StringUtils.toTitleCase(this);
  }

  /// Convert to camelCase
  String get toCamelCase {
    return StringUtils.toCamelCase(this);
  }

  /// Convert to PascalCase
  String get toPascalCase {
    return StringUtils.toPascalCase(this);
  }

  /// Convert to snake_case
  String get toSnakeCase {
    return StringUtils.toSnakeCase(this);
  }

  /// Convert to kebab-case
  String get toKebabCase {
    return StringUtils.toKebabCase(this);
  }

  /// Check if string is null or empty
  bool get isNullOrEmpty => StringUtils.isNullOrEmpty(this);

  /// Check if string is not empty
  bool get isNotEmptyString => !isNullOrEmpty;

  /// Get initials from name (e.g., "John Doe" -> "JD")
  String get initials => StringUtils.getInitials(this);

  /// Extract digits only
  String get digitsOnly => StringUtils.extractDigits(this);

  /// Extract letters only
  String get lettersOnly => StringUtils.extractLetters(this);

  /// Extract alphanumeric characters only
  String get alphanumericOnly => StringUtils.extractAlphanumeric(this);

  /// Truncate text with ellipsis
  String truncate(int maxLength, {String suffix = '...'}) {
    return StringUtils.truncate(this, maxLength, suffix: suffix);
  }

  /// Remove extra whitespace
  String get normalizeSpaces => StringUtils.normalizeSpaces(this);

  /// Check if valid email
  bool get isValidEmail => StringUtils.isValidEmail(this);

  /// Check if valid phone number
  bool get isValidPhone => StringUtils.isValidPhone(this);

  /// Check if valid URL
  bool get isValidUrl => StringUtils.isValidUrl(this);

  /// Mask email address
  String get maskedEmail => StringUtils.maskEmail(this);

  /// Parse to int safely
  int? get toIntOrNull => StringUtils.toInt(this);

  /// Parse to double safely
  double? get toDoubleOrNull => StringUtils.toDouble(this);

  /// Parse to bool safely
  bool? get toBoolOrNull => StringUtils.toBool(this);

  /// Count words
  int get wordCount => StringUtils.wordCount(this);

  /// Generate slug
  String get slugify => StringUtils.slugify(this);

  /// Remove accents/diacritics
  String get withoutAccents => StringUtils.removeAccents(this);

  /// Check if palindrome
  bool get isPalindrome => StringUtils.isPalindrome(this);
}

// int extensions
extension IntExtensions on int {
  /// Format number with thousands separator
  String formatNumber({String separator = ','}) {
    return StringUtils.formatNumberWithSeparator(this, separator: separator);
  }

  /// Convert to formatted string with leading zeros
  String padLeftZeros(int width) {
    return toString().padLeft(width, '0');
  }

  /// Check if number is even
  bool get isEven => this % 2 == 0;

  /// Check if number is odd
  bool get isOdd => this % 2 != 0;

  /// Check if number is positive
  bool get isPositive => this > 0;

  /// Check if number is negative
  bool get isNegative => this < 0;

  /// Check if number is zero
  bool get isZero => this == 0;

  /// Convert to ordinal string (1st, 2nd, 3rd, etc.)
  String get ordinal {
    if (this % 100 >= 11 && this % 100 <= 13) {
      return '${this}th';
    }
    switch (this % 10) {
      case 1:
        return '${this}st';
      case 2:
        return '${this}nd';
      case 3:
        return '${this}rd';
      default:
        return '${this}th';
    }
  }

  /// Convert to duration
  Duration get milliseconds => Duration(milliseconds: this);
  Duration get seconds => Duration(seconds: this);
  Duration get minutes => Duration(minutes: this);
  Duration get hours => Duration(hours: this);
  Duration get days => Duration(days: this);

  /// Convert to file size string
  String get asFileSize => StringUtils.formatFileSize(this);

  /// Check if number is between two values (inclusive)
  bool isBetween(int min, int max) {
    return this >= min && this <= max;
  }

  /// Clamp number between min and max
  int clampBetween(int min, int max) {
    if (this < min) return min;
    if (this > max) return max;
    return this;
  }

  /// Convert to percentage string
  String toPercentage({int decimalPlaces = 1}) {
    return '${toStringAsFixed(decimalPlaces)}%';
  }

  /// Convert to currency string
  String toCurrency({String symbol = 'PKR', int decimalPlaces = 2}) {
    return StringUtils.formatCurrency(toDouble(),
        symbol: symbol, decimalPlaces: decimalPlaces);
  }
}

// double extensions
extension DoubleExtensions on double {
  /// Format with specified decimal places
  String format({int decimalPlaces = 2}) {
    return toStringAsFixed(decimalPlaces);
  }

  /// Convert to percentage string
  String toPercentage({int decimalPlaces = 1}) {
    return '${toStringAsFixed(decimalPlaces)}%';
  }

  /// Convert to currency string
  String toCurrency({String symbol = 'PKR', int decimalPlaces = 2}) {
    return StringUtils.formatCurrency(this,
        symbol: symbol, decimalPlaces: decimalPlaces);
  }

  /// Check if number is positive
  bool get isPositive => this > 0;

  /// Check if number is negative
  bool get isNegative => this < 0;

  /// Check if number is zero
  bool get isZero => this == 0;

  /// Check if number is integer
  bool get isInteger => this == roundToDouble();

  /// Round to nearest integer
  int get roundInt => round();

  /// Floor to integer
  int get floorInt => floor();

  /// Ceil to integer
  int get ceilInt => ceil();

  /// Clamp between min and max
  double clampBetween(double min, double max) {
    if (this < min) return min;
    if (this > max) return max;
    return this;
  }

  /// Check if number is between two values (inclusive)
  bool isBetween(double min, double max) {
    return this >= min && this <= max;
  }

  /// Convert to radians
  double get toRadians => this * (3.141592653589793 / 180.0);

  /// Convert from radians
  double get fromRadians => this * (180.0 / 3.141592653589793);
}

// DateTime extensions
extension DateTimeExtensions on DateTime {
  /// Format date for display
  String formatDate() => DateUtils.formatDateForDisplay(this);

  /// Format date time for display
  String formatDateTime() => DateUtils.formatDateTimeForDisplay(this);

  /// Format time for display
  String formatTime() => DateUtils.formatTimeForDisplay(this);

  /// Format for API
  String formatForApi() => DateUtils.formatDateForApi(this);

  /// Format date time for API
  String formatDateTimeForApi() => DateUtils.formatDateTimeForApi(this);

  /// Get relative time (e.g., "2 hours ago")
  String get relativeTime => DateUtils.getRelativeTime(this);

  /// Get time ago string
  String get timeAgo => DateUtils.timeAgo(this);

  /// Check if date is today
  bool get isToday => DateUtils.isToday(this);

  /// Check if date is yesterday
  bool get isYesterday => DateUtils.isYesterday(this);

  /// Check if date is tomorrow
  bool get isTomorrow => DateUtils.isTomorrow(this);

  /// Check if date is in the past
  bool get isPast => DateUtils.isPast(this);

  /// Check if date is in the future
  bool get isFuture => DateUtils.isFuture(this);

  /// Check if date is weekday
  bool get isWeekday => DateUtils.isWeekday(this);

  /// Check if date is weekend
  bool get isWeekend => DateUtils.isWeekend(this);

  /// Get start of day
  DateTime get startOfDay => DateUtils.startOfDay(this);

  /// Get end of day
  DateTime get endOfDay => DateUtils.endOfDay(this);

  /// Get start of week
  DateTime get startOfWeek => DateUtils.startOfWeek(this);

  /// Get end of week
  DateTime get endOfWeek => DateUtils.endOfWeek(this);

  /// Get start of month
  DateTime get startOfMonth => DateUtils.startOfMonth(this);

  /// Get end of month
  DateTime get endOfMonth => DateUtils.endOfMonth(this);

  /// Get start of year
  DateTime get startOfYear => DateUtils.startOfYear(this);

  /// Get end of year
  DateTime get endOfYear => DateUtils.endOfYear(this);

  /// Get age from birth date
  int get age => DateUtils.getAge(this);

  /// Get quarter
  int get quarter => DateUtils.getQuarter(this);

  /// Get fiscal year
  int get fiscalYear => DateUtils.getFiscalYear(this);

  /// Add business days (excluding weekends)
  DateTime addBusinessDays(int days) => DateUtils.addBusinessDays(this, days);

  /// Days between this date and another
  int daysBetween(DateTime other) => DateUtils.daysBetween(this, other);

  /// Months between this date and another
  int monthsBetween(DateTime other) => DateUtils.monthsBetween(this, other);

  /// Years between this date and another
  int yearsBetween(DateTime other) => DateUtils.yearsBetween(this, other);

  /// Check if year is leap year
  bool get isLeapYear => DateUtils.isLeapYear(year);

  /// Get days in month
  int get daysInMonth => DateUtils.daysInMonth(year, month);

  /// Format with custom format
  String format({String format = DateUtils.dateFormat}) {
    return DateUtils.formatDate(this, format: format);
  }
}

// List extensions
extension ListExtensions<T> on List<T> {
  /// Get element at index or null if out of bounds
  T? elementAtOrNull(int index) {
    if (index < 0 || index >= length) return null;
    return this[index];
  }

  /// Get first element or null if empty
  T? get firstOrNull => isEmpty ? null : first;

  /// Get last element or null if empty
  T? get lastOrNull => isEmpty ? null : last;

  /// Check if list is not empty
  bool get isNotEmptyList => isNotEmpty;

  /// Check if list is empty
  bool get isEmptyList => isEmpty;

  /// Get random element
  T? get random {
    if (isEmpty) return null;
    final random = DateTime.now().microsecondsSinceEpoch % length;
    return this[random];
  }

  /// Split list into chunks
  List<List<T>> chunk(int size) {
    final chunks = <List<T>>[];
    for (var i = 0; i < length; i += size) {
      final end = (i + size < length) ? i + size : length;
      chunks.add(sublist(i, end));
    }
    return chunks;
  }

  /// Remove duplicates based on key selector
  List<T> distinctBy<R>(R Function(T) keySelector) {
    final keys = <R>{};
    final result = <T>[];
    for (final element in this) {
      final key = keySelector(element);
      if (!keys.contains(key)) {
        keys.add(key);
        result.add(element);
      }
    }
    return result;
  }

  /// Group by key selector
  Map<R, List<T>> groupBy<R>(R Function(T) keySelector) {
    final groups = <R, List<T>>{};
    for (final element in this) {
      final key = keySelector(element);
      groups.putIfAbsent(key, () => []).add(element);
    }
    return groups;
  }

  /// Map with index
  List<R> mapIndexed<R>(R Function(int index, T element) mapper) {
    final result = <R>[];
    for (var i = 0; i < length; i++) {
      result.add(mapper(i, this[i]));
    }
    return result;
  }

  /// For each with index
  void forEachIndexed(void Function(int index, T element) action) {
    for (var i = 0; i < length; i++) {
      action(i, this[i]);
    }
  }

  /// Where with index
  List<T> whereIndexed(bool Function(int index, T element) test) {
    final result = <T>[];
    for (var i = 0; i < length; i++) {
      if (test(i, this[i])) {
        result.add(this[i]);
      }
    }
    return result;
  }

  /// Safe remove by index
  bool safeRemoveAt(int index) {
    if (index < 0 || index >= length) return false;
    removeAt(index);
    return true;
  }

  /// Safe remove element
  bool safeRemove(T element) {
    if (!contains(element)) return false;
    remove(element);
    return true;
  }

  /// Swap two elements
  void swap(int index1, int index2) {
    if (index1 < 0 || index1 >= length || index2 < 0 || index2 >= length) {
      return;
    }
    final temp = this[index1];
    this[index1] = this[index2];
    this[index2] = temp;
  }
}

// Map extensions
extension MapExtensions<K, V> on Map<K, V> {
  /// Get value or null if key doesn't exist
  V? getOrNull(K key) => containsKey(key) ? this[key] : null;

  /// Get value or default if key doesn't exist
  V getOrDefault(K key, V defaultValue) =>
      containsKey(key) ? this[key]! : defaultValue;

  /// Check if map is not empty
  bool get isNotEmptyMap => isNotEmpty;

  /// Check if map is empty
  bool get isEmptyMap => isEmpty;

  /// Map keys
  List<R> mapKeys<R>(R Function(K key, V value) mapper) {
    return entries.map((entry) => mapper(entry.key, entry.value)).toList();
  }

  /// Map values
  List<R> mapValues<R>(R Function(K key, V value) mapper) {
    return entries.map((entry) => mapper(entry.key, entry.value)).toList();
  }

  /// Filter entries
  Map<K, V> filter(bool Function(K key, V value) test) {
    final result = <K, V>{};
    forEach((key, value) {
      if (test(key, value)) {
        result[key] = value;
      }
    });
    return result;
  }

  /// Safe remove key
  bool safeRemove(K key) {
    if (!containsKey(key)) return false;
    remove(key);
    return true;
  }

  /// Merge with another map
  Map<K, V> merge(Map<K, V> other, {bool overwrite = true}) {
    final result = Map<K, V>.from(this);
    other.forEach((key, value) {
      if (overwrite || !result.containsKey(key)) {
        result[key] = value;
      }
    });
    return result;
  }
}

// Duration extensions
extension DurationExtensions on Duration {
  /// Format duration in human-readable format
  String format() => StringUtils.formatDuration(this);

  /// Get total hours as double
  double get inHoursDouble => inMicroseconds / Duration.microsecondsPerHour;

  /// Get total minutes as double
  double get inMinutesDouble => inMicroseconds / Duration.microsecondsPerMinute;

  /// Get total seconds as double
  double get inSecondsDouble => inMicroseconds / Duration.microsecondsPerSecond;

  /// Get total milliseconds as double
  double get inMillisecondsDouble =>
      inMicroseconds / Duration.microsecondsPerMillisecond;

  /// Check if duration is positive
  bool get isPositive => inMicroseconds > 0;

  /// Check if duration is negative
  bool get isNegative => inMicroseconds < 0;

  /// Check if duration is zero
  bool get isZero => inMicroseconds == 0;

  /// Add days
  Duration addDays(int days) => this + Duration(days: days);

  /// Add hours
  Duration addHours(int hours) => this + Duration(hours: hours);

  /// Add minutes
  Duration addMinutes(int minutes) => this + Duration(minutes: minutes);

  /// Add seconds
  Duration addSeconds(int seconds) => this + Duration(seconds: seconds);

  /// Add milliseconds
  Duration addMilliseconds(int milliseconds) =>
      this + Duration(milliseconds: milliseconds);

  /// Add microseconds
  Duration addMicroseconds(int microseconds) =>
      this + Duration(microseconds: microseconds);
}
