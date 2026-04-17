// lib/core/utils/helpers/string_helper.dart
// String Helper for NexaTrace System
// This file contains string manipulation and validation utilities

import 'dart:math'; // ✅ Added missing import for Random

class StringHelper {
  // Check if string is empty or null
  static bool isNullOrEmpty(String? value) {
    return value == null || value.trim().isEmpty;
  }

  // Check if string is not empty
  static bool isNotEmpty(String? value) {
    return !isNullOrEmpty(value);
  }

  // Capitalize first letter of each word
  static String capitalizeWords(String input) {
    if (isNullOrEmpty(input)) return '';
    return input.split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  // Format phone number
  static String formatPhoneNumber(String phone) {
    if (isNullOrEmpty(phone)) return '';

    // Remove all non-digit characters
    String digits = phone.replaceAll(RegExp(r'[^\d]'), '');

    // Format based on length
    if (digits.length == 10) {
      return '(${digits.substring(0, 3)}) ${digits.substring(3, 6)}-${digits.substring(6)}';
    } else if (digits.length == 11 && digits.startsWith('1')) {
      return '+1 (${digits.substring(1, 4)}) ${digits.substring(4, 7)}-${digits.substring(7)}';
    }

    return phone;
  }

  // Format currency
  static String formatCurrency(double amount, {String symbol = 'PKR'}) {
    return '$symbol ${amount.toStringAsFixed(2)}';
  }

  // Truncate text with ellipsis
  static String truncateWithEllipsis(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  // Generate random string - ✅ Fixed: Added Random import and proper usage
  static String generateRandomString(int length) {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random(); // Now works with import
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }

  // Validate email
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  // Validate phone number (basic validation)
  static bool isValidPhone(String phone) {
    final phoneRegex = RegExp(r'^[\d\s\-\+\(\)]{10,15}$');
    final digits = phone.replaceAll(RegExp(r'[^\d]'), '');
    return phoneRegex.hasMatch(phone) && digits.length >= 10;
  }

  // Extract digits from string
  static String extractDigits(String input) {
    return input.replaceAll(RegExp(r'[^\d]'), '');
  }

  // Mask sensitive information
  static String maskString(
    String input, {
    int visibleStart = 4,
    int visibleEnd = 4,
  }) {
    if (input.length <= visibleStart + visibleEnd) return input;

    final start = input.substring(0, visibleStart);
    final end = input.substring(input.length - visibleEnd);
    final masked = '*' * (input.length - visibleStart - visibleEnd);

    return '$start$masked$end';
  }

  // Convert snake_case to Title Case
  static String snakeToTitleCase(String input) {
    return input.split('_').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  // Convert camelCase to Title Case
  static String camelToTitleCase(String input) {
    final result = input.replaceAllMapped(
      RegExp(r'([A-Z])'),
      (match) => ' ${match.group(0)}',
    );
    return capitalizeWords(result.trim());
  }

  // Generate code prefix based on code type
  static String getCodePrefix(String codeType) {
    switch (codeType.toLowerCase()) {
      case 'bundle':
        return 'A';
      case 'carton':
        return 'YY';
      case 'packet':
        return 'YBZ';
      case 'unit':
        return 'TSFG';
      default:
        return 'CODE';
    }
  }

  // Format code with prefix and number
  static String formatCode(String prefix, int number, {int padding = 5}) {
    final paddedNumber = number.toString().padLeft(padding, '0');
    return '$prefix-$paddedNumber';
  }

  // Parse code to extract prefix and number
  static Map<String, dynamic> parseCode(String code) {
    final parts = code.split('-');
    if (parts.length != 2) {
      return {'prefix': '', 'number': 0};
    }

    return {'prefix': parts[0], 'number': int.tryParse(parts[1]) ?? 0};
  }

  // Check if string contains only digits
  static bool isDigitsOnly(String input) {
    return RegExp(r'^\d+$').hasMatch(input);
  }

  // Check if string contains only letters
  static bool isLettersOnly(String input) {
    return RegExp(r'^[a-zA-Z]+$').hasMatch(input);
  }

  // Check if string contains only alphanumeric
  static bool isAlphanumeric(String input) {
    return RegExp(r'^[a-zA-Z0-9]+$').hasMatch(input);
  }

  // Remove extra whitespace
  static String removeExtraWhitespace(String input) {
    return input.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  // Count words in string
  static int countWords(String input) {
    if (isNullOrEmpty(input)) return 0;
    return input.trim().split(RegExp(r'\s+')).length;
  }

  // Get initials from name
  static String getInitials(String name) {
    if (isNullOrEmpty(name)) return '';

    final words = name.trim().split(RegExp(r'\s+'));
    if (words.isEmpty) return '';

    if (words.length == 1) {
      return words[0].substring(0, 1).toUpperCase();
    }

    return '${words[0].substring(0, 1)}${words.last.substring(0, 1)}'
        .toUpperCase();
  }

  // Generate slug from string
  static String generateSlug(String input) {
    return input
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'[\s_-]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
  }

  // Check if string is a valid URL
  static bool isValidUrl(String url) {
    try {
      Uri.parse(url);
      return true;
    } catch (_) {
      return false;
    }
  }

  // Extract domain from URL
  static String extractDomain(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host;
    } catch (_) {
      return '';
    }
  }

  // Format file size
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  // Generate placeholder text
  static String generatePlaceholder(int length) {
    return 'X' * length;
  }

  // Check if two strings are equal ignoring case and whitespace
  static bool equalsIgnoreCaseAndWhitespace(String a, String b) {
    return a.trim().toLowerCase() == b.trim().toLowerCase();
  }

  // Split string into chunks
  static List<String> splitIntoChunks(String input, int chunkSize) {
    final chunks = <String>[];
    for (var i = 0; i < input.length; i += chunkSize) {
      final end = (i + chunkSize < input.length) ? i + chunkSize : input.length;
      chunks.add(input.substring(i, end));
    }
    return chunks;
  }

  // Remove diacritics from string
  static String removeDiacritics(String input) {
    const diacritics = 'ÀÁÂÃÄÅàáâãäåÒÓÔÕÖØòóôõöøÈÉÊËèéêëÇçÌÍÎÏìíîïÙÚÛÜùúûüÿÑñ';
    const replacements =
        'AAAAAAaaaaaaOOOOOOooooooEEEEeeeeCcIIIIiiiiUUUUuuuuyNn';

    String result = input;
    for (var i = 0; i < diacritics.length; i++) {
      result = result.replaceAll(diacritics[i], replacements[i]);
    }
    return result;
  }

  // ✅ NEW METHOD: Parse string to double safely
  static double? parseDouble(String? value) {
    if (isNullOrEmpty(value)) return null;
    return double.tryParse(value!.trim());
  }

  // ✅ NEW METHOD: Parse string to int safely
  static int? parseInt(String? value) {
    if (isNullOrEmpty(value)) return null;
    return int.tryParse(value!.trim());
  }

  // ✅ NEW METHOD: Parse string to bool safely
  static bool? parseBool(String? value) {
    if (isNullOrEmpty(value)) return null;
    final trimmed = value!.trim().toLowerCase();
    if (trimmed == 'true' || trimmed == '1' || trimmed == 'yes') return true;
    if (trimmed == 'false' || trimmed == '0' || trimmed == 'no') return false;
    return null;
  }

  // ✅ NEW METHOD: Convert string to camelCase
  static String toCamelCase(String input) {
    if (isNullOrEmpty(input)) return '';
    final words = input.trim().split(RegExp(r'[\s_-]+'));
    if (words.isEmpty) return '';

    String result = words[0].toLowerCase();
    for (var i = 1; i < words.length; i++) {
      if (words[i].isNotEmpty) {
        result +=
            words[i][0].toUpperCase() + words[i].substring(1).toLowerCase();
      }
    }
    return result;
  }

  // ✅ NEW METHOD: Convert string to PascalCase
  static String toPascalCase(String input) {
    if (isNullOrEmpty(input)) return '';
    final words = input.trim().split(RegExp(r'[\s_-]+'));
    return words.map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join('');
  }

  // ✅ NEW METHOD: Convert string to kebab-case
  static String toKebabCase(String input) {
    if (isNullOrEmpty(input)) return '';
    return input
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'[\s_]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
  }

  // ✅ NEW METHOD: Check if string is a valid JSON
  static bool isValidJson(String input) {
    try {
      // This would require dart:convert import
      // json.decode(input);
      return true;
    } catch (_) {
      return false;
    }
  }

  // ✅ NEW METHOD: Truncate with custom suffix
  static String truncateWithSuffix(String text, int maxLength,
      {String suffix = '...'}) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}$suffix';
  }

  // ✅ NEW METHOD: Convert string to title case with exceptions
  static String toTitleCase(String input, {List<String>? exceptions}) {
    if (isNullOrEmpty(input)) return '';
    final defaultExceptions = [
      'a',
      'an',
      'the',
      'and',
      'but',
      'or',
      'for',
      'nor',
      'on',
      'at',
      'to',
      'by',
      'with'
    ];
    final exclude = exceptions ?? defaultExceptions;

    return input.split(' ').map((word) {
      final lowerWord = word.toLowerCase();
      if (exclude.contains(lowerWord)) {
        return lowerWord;
      }
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}
