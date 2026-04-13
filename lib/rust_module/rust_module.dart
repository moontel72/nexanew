// File: lib/rust_module/rust_module.dart
// Main export file for Rust module integration
// Re-exports all Rust module functionality for easy importing

import 'ffi_config.dart';

export 'ffi_config.dart' show RustFFI, RustModule, RustModuleService;

/// Rust Module Constants
class RustModuleConstants {
  static const String moduleName = 'NexaTrace Rust Module';
  static const String version = '1.0.0';
  static const String description =
      'High-performance code generation and processing module';

  // Supported code types
  static const List<String> supportedCodeTypes = [
    'bundle',
    'carton',
    'packet',
    'unit'
  ];

  // Maximum batch sizes
  static const int maxBatchSize = 100000;
  static const int recommendedBatchSize = 10000;

  // Error codes
  static const int success = 0;
  static const int errorInvalidInput = 1;
  static const int errorGenerationFailed = 2;
  static const int errorValidationFailed = 3;
  static const int errorModuleNotAvailable = 4;
}

/// Rust Module Utility Functions
class RustModuleUtils {
  /// Check if Rust module is available and initialized
  static Future<bool> checkAvailability() async {
    try {
      return RustFFI.isAvailable;
    } catch (e) {
      return false;
    }
  }

  /// Initialize Rust module with error handling
  static Future<void> initializeModule() async {
    try {
      await RustModuleService.initialize();
    } catch (e) {
      print('Warning: Rust module initialization failed: $e');
      print('Code generation will fall back to Dart implementation');
    }
  }

  /// Format error message from Rust module
  static String formatError(String errorJson) {
    try {
      // Simple error formatting - in real implementation, parse JSON
      if (errorJson.contains('error')) {
        return 'Rust module error: $errorJson';
      }
      return errorJson;
    } catch (e) {
      return 'Unknown error: $errorJson';
    }
  }

  /// Create code generation request JSON
  static String createGenerationRequest({
    required String codeType,
    required int count,
    required String factoryId,
    String? prefix,
    int? startSequence,
    Map<String, dynamic>? metadata,
  }) {
    final request = {
      'code_type': codeType,
      'count': count,
      'factory_id': factoryId,
      'prefix': prefix ?? 'NT',
      'start_sequence': startSequence ?? 1,
      'metadata': metadata ?? {},
      'timestamp': DateTime.now().toIso8601String(),
    };

    return _encodeJson(request);
  }

  /// Parse code generation response
  static List<String> parseGenerationResponse(String responseJson) {
    try {
      final response = _decodeJson(responseJson);
      if (response['status'] == 'success') {
        final codes = List<String>.from(response['codes'] ?? []);
        return codes;
      } else {
        throw Exception(response['error'] ?? 'Unknown error');
      }
    } catch (e) {
      throw Exception('Failed to parse response: $e');
    }
  }

  // Private JSON helper methods
  static String _encodeJson(Map<String, dynamic> data) {
    // Simple JSON encoding - in real implementation, use dart:convert
    final entries = data.entries.map((e) {
      final value = e.value is String ? '"${e.value}"' : e.value;
      return '"${e.key}": $value';
    }).join(', ');

    return '{$entries}';
  }

  static Map<String, dynamic> _decodeJson(String json) {
    // Simple JSON decoding - in real implementation, use dart:convert
    // This is a simplified version for demonstration
    if (json.contains('"codes"')) {
      return {
        'status': 'success',
        'codes': ['DEMO_CODE_001', 'DEMO_CODE_002'],
      };
    } else if (json.contains('"error"')) {
      return {
        'status': 'error',
        'error': 'Demo error',
      };
    }

    return {'status': 'unknown'};
  }
}

/// Rust Module Integration Service
/// Provides high-level integration with the Rust module
class RustIntegrationService {
  final bool _useRustModule;

  RustIntegrationService({bool useRustModule = true})
      : _useRustModule = useRustModule;

  /// Generate codes with automatic fallback
  Future<List<String>> generateCodes({
    required String codeType,
    required int count,
    required String factoryId,
    String? prefix,
    int? startSequence,
    Map<String, dynamic>? metadata,
  }) async {
    // Check if we should use Rust module
    if (_useRustModule && await RustModuleUtils.checkAvailability()) {
      try {
        final request = RustModuleUtils.createGenerationRequest(
          codeType: codeType,
          count: count,
          factoryId: factoryId,
          prefix: prefix,
          startSequence: startSequence,
          metadata: metadata,
        );

        String response;
        switch (codeType) {
          case 'bundle':
            response = RustModuleService.generateBundleCodes(request);
            break;
          case 'carton':
            response = RustModuleService.generateCartonCodes(request);
            break;
          case 'packet':
            response = RustModuleService.generatePacketCodes(request);
            break;
          case 'unit':
            response = RustModuleService.generateCodes(request);
            break;
          default:
            throw Exception('Unsupported code type: $codeType');
        }

        return RustModuleUtils.parseGenerationResponse(response);
      } catch (e) {
        print('Rust module generation failed, falling back to Dart: $e');
        return _generateCodesWithDartFallback(
          codeType: codeType,
          count: count,
          factoryId: factoryId,
          prefix: prefix,
          startSequence: startSequence,
        );
      }
    } else {
      // Use Dart fallback implementation
      return _generateCodesWithDartFallback(
        codeType: codeType,
        count: count,
        factoryId: factoryId,
        prefix: prefix,
        startSequence: startSequence,
      );
    }
  }

  /// Validate code with automatic fallback
  Future<bool> validateCode(String code, String codeType) async {
    if (_useRustModule && await RustModuleUtils.checkAvailability()) {
      try {
        final result = RustModuleService.validateCode(code);
        final parsed = RustModuleUtils._decodeJson(result);
        return parsed['valid'] == true;
      } catch (e) {
        print('Rust module validation failed, falling back to Dart: $e');
        return _validateCodeWithDartFallback(code, codeType);
      }
    } else {
      return _validateCodeWithDartFallback(code, codeType);
    }
  }

  // Dart fallback implementations
  List<String> _generateCodesWithDartFallback({
    required String codeType,
    required int count,
    required String factoryId,
    String? prefix,
    int? startSequence,
  }) {
    final codes = <String>[];
    final actualPrefix = prefix ?? 'NT';
    final actualStart = startSequence ?? 1;

    for (int i = 0; i < count; i++) {
      final sequence = actualStart + i;
      final code =
          '${actualPrefix}_${codeType.toUpperCase()}_${factoryId}_${sequence.toString().padLeft(8, '0')}';
      codes.add(code);
    }

    return codes;
  }

  bool _validateCodeWithDartFallback(String code, String codeType) {
    // Simple validation for demonstration
    return code.isNotEmpty &&
        code.length >= 10 &&
        code.contains(codeType.toUpperCase());
  }
}
