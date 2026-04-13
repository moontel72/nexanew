// lib/core/utils/string_utils.dart
// String Utilities for NexaTrace System
// Comprehensive string manipulation, validation, and formatting utilities

import 'dart:convert';
import 'dart:math';

class StringUtils {
  // ==================== NULL/EMPTY CHECKS ====================

  /// Check if string is null or empty (after trimming)
  static bool isNullOrEmpty(String? value) {
    return value == null || value.trim().isEmpty;
  }

  /// Check if string is not empty
  static bool isNotEmpty(String? value) {
    return !isNullOrEmpty(value);
  }

  /// Returns empty string if null, otherwise returns the string
  static String nullToEmpty(String? value) {
    return value ?? '';
  }

  /// Returns default value if string is null or empty
  static String defaultIfEmpty(String? value, String defaultValue) {
    return isNullOrEmpty(value) ? defaultValue : value!;
  }

  // ==================== VALIDATION ====================

  /// Validate email address
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// Validate phone number (basic international format)
  static bool isValidPhone(String phone) {
    final phoneRegex = RegExp(r'^[\d\s\-\+\(\)]{10,15}$');
    final digits = extractDigits(phone);
    return phoneRegex.hasMatch(phone) && digits.length >= 10;
  }

  /// Validate URL
  static bool isValidUrl(String url) {
    try {
      Uri.parse(url);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Check if string contains only digits
  static bool isDigitsOnly(String input) {
    return RegExp(r'^\d+$').hasMatch(input);
  }

  /// Check if string contains only letters
  static bool isLettersOnly(String input) {
    return RegExp(r'^[a-zA-Z]+$').hasMatch(input);
  }

  /// Check if string contains only alphanumeric characters
  static bool isAlphanumeric(String input) {
    return RegExp(r'^[a-zA-Z0-9]+$').hasMatch(input);
  }

  /// Check if string is a valid JSON
  static bool isValidJson(String input) {
    try {
      json.decode(input);
      return true;
    } catch (_) {
      return false;
    }
  }

  // ==================== FORMATTING ====================

  /// Capitalize first letter of each word
  static String capitalizeWords(String input) {
    if (isNullOrEmpty(input)) return '';
    return input.split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  /// Convert to Title Case with exceptions for small words
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
      'with',
      'in',
      'of'
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

  /// Convert to camelCase
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

  /// Convert to PascalCase
  static String toPascalCase(String input) {
    if (isNullOrEmpty(input)) return '';
    final words = input.trim().split(RegExp(r'[\s_-]+'));
    return words.map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join('');
  }

  /// Convert to snake_case
  static String toSnakeCase(String input) {
    if (isNullOrEmpty(input)) return '';
    return input
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'[\s-]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
  }

  /// Convert to kebab-case
  static String toKebabCase(String input) {
    if (isNullOrEmpty(input)) return '';
    return input
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'[\s_]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
  }

  /// Convert snake_case to Title Case
  static String snakeToTitleCase(String input) {
    return input.split('_').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  /// Convert camelCase to Title Case
  static String camelToTitleCase(String input) {
    final result = input.replaceAllMapped(
      RegExp(r'([A-Z])'),
      (match) => ' ${match.group(0)}',
    );
    return capitalizeWords(result.trim());
  }

  // ==================== CODE GENERATION & FORMATTING ====================

  /// Get code prefix based on code type
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

  /// Format code with prefix and number (e.g., "A-00001", "YY-00123")
  static String formatCode(String prefix, int number, {int padding = 5}) {
    final paddedNumber = number.toString().padLeft(padding, '0');
    return '$prefix-$paddedNumber';
  }

  /// Parse code to extract prefix and number
  static Map<String, dynamic> parseCode(String code) {
    final parts = code.split('-');
    if (parts.length != 2) {
      return {'prefix': '', 'number': 0};
    }

    return {
      'prefix': parts[0],
      'number': int.tryParse(parts[1]) ?? 0,
      'code': code
    };
  }

  /// Generate NexaTrace serial number
  static String generateSerialNumber({
    required String factoryCode,
    required String productCode,
    required int sequence,
    DateTime? date,
  }) {
    final now = date ?? DateTime.now();
    final year = now.year.toString().substring(2);
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    final sequenceStr = sequence.toString().padLeft(6, '0');

    return '$factoryCode$productCode$year$month$day$sequenceStr';
  }

  /// Parse serial number into components
  static Map<String, dynamic> parseSerialNumber(String serial) {
    if (serial.length < 16) {
      return {'error': 'Invalid serial number length'};
    }

    try {
      return {
        'factoryCode': serial.substring(0, 3),
        'productCode': serial.substring(3, 6),
        'year': '20${serial.substring(6, 8)}',
        'month': serial.substring(8, 10),
        'day': serial.substring(10, 12),
        'sequence': int.parse(serial.substring(12)),
        'serial': serial
      };
    } catch (_) {
      return {'error': 'Failed to parse serial number'};
    }
  }

  /// Generate QR code data for product
  static String generateQRCodeData({
    required String code,
    required String productName,
    required String factoryId,
    required DateTime productionDate,
  }) {
    final data = {
      'code': code,
      'product': productName,
      'factory': factoryId,
      'production_date': productionDate.toIso8601String(),
      'timestamp': DateTime.now().toIso8601String(),
    };

    return json.encode(data);
  }

  // ==================== TEXT MANIPULATION ====================

  /// Truncate text with ellipsis
  static String truncate(String text, int maxLength, {String suffix = '...'}) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}$suffix';
  }

  /// Remove extra whitespace (multiple spaces, tabs, newlines)
  static String normalizeSpaces(String input) {
    return input.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Extract digits only from string
  static String extractDigits(String input) {
    return input.replaceAll(RegExp(r'[^\d]'), '');
  }

  /// Extract letters only from string
  static String extractLetters(String input) {
    return input.replaceAll(RegExp(r'[^a-zA-Z]'), '');
  }

  /// Extract alphanumeric characters only
  static String extractAlphanumeric(String input) {
    return input.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
  }

  /// Get initials from name (e.g., "John Doe" -> "JD")
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

  /// Count words in string
  static int wordCount(String input) {
    if (isNullOrEmpty(input)) return 0;
    return input.trim().split(RegExp(r'\s+')).length;
  }

  /// Generate slug from string (URL-friendly)
  static String slugify(String input) {
    return input
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'[\s_-]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
  }

  /// Remove diacritics/accents from string
  static String removeAccents(String input) {
    const diacritics = 'ÀÁÂÃÄÅàáâãäåÒÓÔÕÖØòóôõöøÈÉÊËèéêëÇçÌÍÎÏìíîïÙÚÛÜùúûüÿÑñ';
    const replacements =
        'AAAAAAaaaaaaOOOOOOooooooEEEEeeeeCcIIIIiiiiUUUUuuuuyNn';

    String result = input;
    for (var i = 0; i < diacritics.length; i++) {
      result = result.replaceAll(diacritics[i], replacements[i]);
    }
    return result;
  }

  /// Mask sensitive information (e.g., credit cards, emails)
  static String mask(String input,
      {int visibleStart = 4, int visibleEnd = 4, String maskChar = '*'}) {
    if (input.length <= visibleStart + visibleEnd) return input;

    final start = input.substring(0, visibleStart);
    final end = input.substring(input.length - visibleEnd);
    final masked = maskChar * (input.length - visibleStart - visibleEnd);

    return '$start$masked$end';
  }

  /// Mask email address (e.g., "johndoe@example.com" -> "jo****@example.com")
  static String maskEmail(String email) {
    if (!isValidEmail(email)) return email;

    final parts = email.split('@');
    if (parts.length != 2) return email;

    final username = parts[0];
    final domain = parts[1];

    if (username.length <= 2) {
      return '${'*' * username.length}@$domain';
    }

    final visibleStart = 2;
    final maskedUsername =
        '${username.substring(0, visibleStart)}${'*' * (username.length - visibleStart)}';
    return '$maskedUsername@$domain';
  }

  // ==================== PARSING & CONVERSION ====================

  /// Parse string to double safely
  static double? toDouble(String? value) {
    if (isNullOrEmpty(value)) return null;
    return double.tryParse(value!.trim());
  }

  /// Parse string to int safely
  static int? toInt(String? value) {
    if (isNullOrEmpty(value)) return null;
    return int.tryParse(value!.trim());
  }

  /// Parse string to bool safely
  static bool? toBool(String? value) {
    if (isNullOrEmpty(value)) return null;
    final trimmed = value!.trim().toLowerCase();

    if (trimmed == 'true' ||
        trimmed == '1' ||
        trimmed == 'yes' ||
        trimmed == 'y') {
      return true;
    }
    if (trimmed == 'false' ||
        trimmed == '0' ||
        trimmed == 'no' ||
        trimmed == 'n') {
      return false;
    }

    return null;
  }

  /// Convert string to list of strings (comma-separated)
  static List<String> toList(String input, {String delimiter = ','}) {
    if (isNullOrEmpty(input)) return [];
    return input
        .split(delimiter)
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  /// Convert list of strings to comma-separated string
  static String fromList(List<String> list, {String delimiter = ', '}) {
    return list.where((item) => item.isNotEmpty).join(delimiter);
  }

  // ==================== GENERATION ====================

  /// Generate random string
  static String randomString(int length,
      {bool includeNumbers = true, bool includeSpecialChars = false}) {
    String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';

    if (includeNumbers) {
      chars += '0123456789';
    }

    if (includeSpecialChars) {
      chars += '!@#\$%^&*()_-+=[]{}|;:,.<>?';
    }

    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }

  /// Generate random numeric string
  static String randomNumericString(int length) {
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => '0'.codeUnitAt(0) + random.nextInt(10),
      ),
    );
  }

  /// Generate placeholder text (e.g., for loading states)
  static String placeholder(int length, {String char = 'X'}) {
    return char * length;
  }

  // ==================== FORMATTING UTILITIES ====================

  /// Format phone number (basic formatting)
  static String formatPhone(String phone) {
    if (isNullOrEmpty(phone)) return '';

    // Remove all non-digit characters
    String digits = extractDigits(phone);

    // Format based on length
    if (digits.length == 10) {
      return '(${digits.substring(0, 3)}) ${digits.substring(3, 6)}-${digits.substring(6)}';
    } else if (digits.length == 11 && digits.startsWith('1')) {
      return '+1 (${digits.substring(1, 4)}) ${digits.substring(4, 7)}-${digits.substring(7)}';
    }

    return phone;
  }

  /// Format currency
  static String formatCurrency(double amount,
      {String symbol = 'PKR', int decimalPlaces = 2}) {
    final formattedAmount = amount.toStringAsFixed(decimalPlaces);
    return '$symbol $formattedAmount';
  }

  /// Format file size (bytes to KB, MB, GB)
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Format duration in human-readable format
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

  /// Extract domain from URL
  static String extractDomain(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host;
    } catch (_) {
      return '';
    }
  }

  /// Split string into chunks
  static List<String> splitIntoChunks(String input, int chunkSize) {
    final chunks = <String>[];
    for (var i = 0; i < input.length; i += chunkSize) {
      final end = (i + chunkSize < input.length) ? i + chunkSize : input.length;
      chunks.add(input.substring(i, end));
    }
    return chunks;
  }

  /// Check equality ignoring case and whitespace
  static bool equalsIgnoreCaseAndSpace(String a, String b) {
    return a.trim().toLowerCase() == b.trim().toLowerCase();
  }

  /// Check if string starts with any of the given prefixes
  static bool startsWithAny(String input, List<String> prefixes) {
    for (final prefix in prefixes) {
      if (input.startsWith(prefix)) {
        return true;
      }
    }
    return false;
  }

  /// Check if string ends with any of the given suffixes
  static bool endsWithAny(String input, List<String> suffixes) {
    for (final suffix in suffixes) {
      if (input.endsWith(suffix)) {
        return true;
      }
    }
    return false;
  }

  /// Remove all occurrences of specified characters
  static String removeCharacters(String input, List<String> characters) {
    String result = input;
    for (final char in characters) {
      result = result.replaceAll(char, '');
    }
    return result;
  }

  /// Count occurrences of substring in string
  static int countOccurrences(String input, String substring) {
    if (substring.isEmpty) return 0;
    int count = 0;
    int index = 0;
    while ((index = input.indexOf(substring, index)) != -1) {
      count++;
      index += substring.length;
    }
    return count;
  }

  /// Wrap text to specified line length
  static List<String> wrapText(String text, int lineLength) {
    final lines = <String>[];
    final words = text.split(' ');
    String currentLine = '';

    for (final word in words) {
      if (currentLine.isEmpty) {
        currentLine = word;
      } else if ((currentLine.length + word.length + 1) <= lineLength) {
        currentLine += ' $word';
      } else {
        lines.add(currentLine);
        currentLine = word;
      }
    }

    if (currentLine.isNotEmpty) {
      lines.add(currentLine);
    }

    return lines;
  }

  /// Generate hash from string (simple implementation)
  static int simpleHash(String input) {
    int hash = 0;
    for (var i = 0; i < input.length; i++) {
      hash = (hash << 5) - hash + input.codeUnitAt(i);
      hash = hash & hash; // Convert to 32-bit integer
    }
    return hash.abs();
  }

  /// Check if string contains any of the given substrings
  static bool containsAny(String input, List<String> substrings) {
    for (final substring in substrings) {
      if (input.contains(substring)) {
        return true;
      }
    }
    return false;
  }

  /// Check if string contains all of the given substrings
  static bool containsAll(String input, List<String> substrings) {
    for (final substring in substrings) {
      if (!input.contains(substring)) {
        return false;
      }
    }
    return true;
  }

  /// Replace multiple patterns in string
  static String replaceMultiple(
      String input, Map<String, String> replacements) {
    String result = input;
    replacements.forEach((pattern, replacement) {
      result = result.replaceAll(pattern, replacement);
    });
    return result;
  }

  /// Extract substring between two delimiters
  static String? substringBetween(
      String input, String startDelimiter, String endDelimiter) {
    final startIndex = input.indexOf(startDelimiter);
    if (startIndex == -1) return null;

    final endIndex =
        input.indexOf(endDelimiter, startIndex + startDelimiter.length);
    if (endIndex == -1) return null;

    return input.substring(startIndex + startDelimiter.length, endIndex);
  }

  /// Check if string matches any pattern in list of regex patterns
  static bool matchesAnyPattern(String input, List<String> patterns) {
    for (final pattern in patterns) {
      if (RegExp(pattern).hasMatch(input)) {
        return true;
      }
    }
    return false;
  }

  /// Format bytes as hex string
  static String bytesToHex(List<int> bytes) {
    return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
  }

  /// Parse hex string to bytes
  static List<int> hexToBytes(String hex) {
    final result = <int>[];
    for (var i = 0; i < hex.length; i += 2) {
      final byteStr = hex.substring(i, i + 2);
      result.add(int.parse(byteStr, radix: 16));
    }
    return result;
  }

  /// Generate unique identifier
  static String generateUniqueId({int length = 16}) {
    final random = Random();
    final timestamp = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
    final randomPart = String.fromCharCodes(
      Iterable.generate(
        length - timestamp.length,
        (_) => 'abcdefghijklmnopqrstuvwxyz0123456789'
            .codeUnitAt(random.nextInt(36)),
      ),
    );
    return timestamp + randomPart;
  }

  /// Format list as bullet points
  static String formatAsBulletPoints(List<String> items,
      {String bullet = '•'}) {
    return items.map((item) => '$bullet $item').join('\n');
  }

  /// Check if string is palindrome
  static bool isPalindrome(String input) {
    final cleaned = input.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    return cleaned == cleaned.split('').reversed.join('');
  }

  /// Calculate Levenshtein distance between two strings
  static int levenshteinDistance(String a, String b) {
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;

    final matrix =
        List.generate(a.length + 1, (i) => List.filled(b.length + 1, 0));

    for (var i = 0; i <= a.length; i++) {
      matrix[i][0] = i;
    }
    for (var j = 0; j <= b.length; j++) {
      matrix[0][j] = j;
    }

    for (var i = 1; i <= a.length; i++) {
      for (var j = 1; j <= b.length; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1, // deletion
          matrix[i][j - 1] + 1, // insertion
          matrix[i - 1][j - 1] + cost // substitution
        ].reduce((value, element) => value < element ? value : element);
      }
    }

    return matrix[a.length][b.length];
  }

  /// Calculate similarity percentage between two strings
  static double similarityPercentage(String a, String b) {
    if (a.isEmpty && b.isEmpty) return 100.0;
    final distance = levenshteinDistance(a, b);
    final maxLength = a.length > b.length ? a.length : b.length;
    return ((1 - distance / maxLength) * 100).clamp(0.0, 100.0);
  }

  /// Generate progress bar string
  static String progressBar(double percentage,
      {int length = 20, String filled = '█', String empty = '░'}) {
    final filledLength = (percentage / 100 * length).round();
    final emptyLength = length - filledLength;
    return '${filled * filledLength}${empty * emptyLength} ${percentage.toStringAsFixed(1)}%';
  }

  /// Format number with thousands separator
  static String formatNumberWithSeparator(int number,
      {String separator = ','}) {
    return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]}$separator',
        );
  }

  /// Generate password strength indicator
  static String passwordStrength(String password) {
    if (password.length < 8) return 'Weak';

    bool hasUpper = RegExp(r'[A-Z]').hasMatch(password);
    bool hasLower = RegExp(r'[a-z]').hasMatch(password);
    bool hasDigit = RegExp(r'\d').hasMatch(password);
    bool hasSpecial =
        RegExp(r'[!@#\$%^&*()_+\-=\[\]{};:"\\|,.<>?]').hasMatch(password);

    int score = 0;
    if (hasUpper) score++;
    if (hasLower) score++;
    if (hasDigit) score++;
    if (hasSpecial) score++;
    if (password.length >= 12) score++;

    if (score >= 5) return 'Very Strong';
    if (score >= 4) return 'Strong';
    if (score >= 3) return 'Good';
    return 'Fair';
  }

  /// Generate NexaTrace-specific utilities

  /// Format factory code with validation
  static String formatFactoryCode(String code) {
    final cleaned = extractAlphanumeric(code).toUpperCase();
    if (cleaned.length != 3) {
      throw FormatException('Factory code must be 3 characters');
    }
    return cleaned;
  }

  /// Format product code with validation
  static String formatProductCode(String code) {
    final cleaned = extractAlphanumeric(code).toUpperCase();
    if (cleaned.length != 3) {
      throw FormatException('Product code must be 3 characters');
    }
    return cleaned;
  }

  /// Validate NexaTrace code format
  static bool isValidNexaTraceCode(String code) {
    final pattern = RegExp(r'^[A-Z]{1,4}-\d{4,8}$');
    return pattern.hasMatch(code);
  }

  /// Extract batch number from code
  static String? extractBatchNumber(String code) {
    final match = RegExp(r'BATCH-(\d+)').firstMatch(code);
    return match?.group(1);
  }

  /// Generate batch code
  static String generateBatchCode(
      String factoryId, int batchNumber, DateTime date) {
    final dateStr = date.toIso8601String().substring(0, 10).replaceAll('-', '');
    return 'BATCH-$factoryId-$dateStr-${batchNumber.toString().padLeft(6, '0')}';
  }

  /// Format address for display
  static String formatAddress(Map<String, dynamic> address) {
    final parts = <String>[];
    if (address['street'] != null) parts.add(address['street']);
    if (address['city'] != null) parts.add(address['city']);
    if (address['state'] != null) parts.add(address['state']);
    if (address['postal_code'] != null) parts.add(address['postal_code']);
    if (address['country'] != null) parts.add(address['country']);

    return parts.join(', ');
  }

  /// Generate tracking URL
  static String generateTrackingUrl(String baseUrl, String trackingCode) {
    return '$baseUrl/track/$trackingCode';
  }

  /// Format date range for display
  static String formatDateRange(DateTime start, DateTime end) {
    if (start.year == end.year &&
        start.month == end.month &&
        start.day == end.day) {
      return '${start.day}/${start.month}/${start.year}';
    }
    return '${start.day}/${start.month}/${start.year} - ${end.day}/${end.month}/${end.year}';
  }

  /// Generate report filename
  static String generateReportFilename(String reportType, DateTime date,
      {String extension = 'pdf'}) {
    final dateStr = date.toIso8601String().substring(0, 10).replaceAll('-', '');
    return '${reportType.toLowerCase()}_report_$dateStr.$extension';
  }

  /// Format error message for display
  static String formatErrorMessage(String error) {
    return capitalizeWords(error.replaceAll('_', ' ').toLowerCase());
  }

  /// Generate confirmation code
  static String generateConfirmationCode({int length = 6}) {
    return randomNumericString(length);
  }

  /// Format permissions list
  static String formatPermissions(List<String> permissions) {
    return permissions
        .map((p) => '• ${p.replaceAll('_', ' ').toLowerCase()}')
        .join('\n');
  }

  /// Check if string is valid for database field name
  static bool isValidFieldName(String name) {
    return RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(name);
  }

  /// Convert string to database-safe name
  static String toDatabaseFieldName(String name) {
    return name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');
  }
}
