// File: lib/rust_module/ffi_config.dart
// FFI Configuration for NexaTrace Rust Module
// Provides platform-specific dynamic library loading for Rust FFI integration

import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';

/// Rust FFI Configuration
/// Handles platform-specific dynamic library loading for Rust module integration
class RustFFI {
  /// Get the platform-specific dynamic library
  static DynamicLibrary get nativeLib {
    if (Platform.isWindows) {
      return DynamicLibrary.open('rust_module.dll');
    } else if (Platform.isLinux) {
      return DynamicLibrary.open('librust_module.so');
    } else if (Platform.isMacOS) {
      return DynamicLibrary.open('librust_module.dylib');
    } else if (Platform.isAndroid) {
      return DynamicLibrary.open('librust_module.so');
    } else if (Platform.isIOS) {
      return DynamicLibrary.open('rust_module.framework/rust_module');
    } else {
      throw UnsupportedError(
          'Unsupported platform: ${Platform.operatingSystem}');
    }
  }

  /// Initialize Rust module
  static void init() {
    // Load the library to ensure it's available
    nativeLib;
    print('Rust FFI initialized for platform: ${Platform.operatingSystem}');
  }

  /// Check if Rust module is available
  static bool get isAvailable {
    try {
      nativeLib;
      return true;
    } catch (e) {
      return false;
    }
  }
}

/// Rust Module API Interface
/// Provides typed access to Rust functions via FFI
class RustModule {
  static final DynamicLibrary _lib = RustFFI.nativeLib;

  // Code Generation Functions
  static final Pointer<Utf8> Function(Pointer<Utf8>) generateCodes =
      _lib.lookupFunction<Pointer<Utf8> Function(Pointer<Utf8>),
          Pointer<Utf8> Function(Pointer<Utf8>)>('generate_codes');

  static final Pointer<Utf8> Function(Pointer<Utf8>) generateBundleCodes =
      _lib.lookupFunction<Pointer<Utf8> Function(Pointer<Utf8>),
          Pointer<Utf8> Function(Pointer<Utf8>)>('generate_bundle_codes');

  static final Pointer<Utf8> Function(Pointer<Utf8>) generateCartonCodes =
      _lib.lookupFunction<Pointer<Utf8> Function(Pointer<Utf8>),
          Pointer<Utf8> Function(Pointer<Utf8>)>('generate_carton_codes');

  static final Pointer<Utf8> Function(Pointer<Utf8>) generatePacketCodes =
      _lib.lookupFunction<Pointer<Utf8> Function(Pointer<Utf8>),
          Pointer<Utf8> Function(Pointer<Utf8>)>('generate_packet_codes');

  static final Pointer<Utf8> Function(Pointer<Utf8>) generateUnitCodes =
      _lib.lookupFunction<Pointer<Utf8> Function(Pointer<Utf8>),
          Pointer<Utf8> Function(Pointer<Utf8>)>('generate_unit_codes');

  // Validation Functions
  static final Pointer<Utf8> Function(Pointer<Utf8>) validateCode =
      _lib.lookupFunction<Pointer<Utf8> Function(Pointer<Utf8>),
          Pointer<Utf8> Function(Pointer<Utf8>)>('validate_code');

  static final Pointer<Utf8> Function(Pointer<Utf8>) validateCodeBatch =
      _lib.lookupFunction<Pointer<Utf8> Function(Pointer<Utf8>),
          Pointer<Utf8> Function(Pointer<Utf8>)>('validate_code_batch');

  // Utility Functions
  static final Pointer<Utf8> Function(Pointer<Utf8>) generateChecksum =
      _lib.lookupFunction<Pointer<Utf8> Function(Pointer<Utf8>),
          Pointer<Utf8> Function(Pointer<Utf8>)>('generate_checksum');

  static final Pointer<Utf8> Function(Pointer<Utf8>) encryptCode =
      _lib.lookupFunction<Pointer<Utf8> Function(Pointer<Utf8>),
          Pointer<Utf8> Function(Pointer<Utf8>)>('encrypt_code');

  static final Pointer<Utf8> Function(Pointer<Utf8>) decryptCode =
      _lib.lookupFunction<Pointer<Utf8> Function(Pointer<Utf8>),
          Pointer<Utf8> Function(Pointer<Utf8>)>('decrypt_code');

  // Initialization function
  static final void Function() initRustModule =
      _lib.lookupFunction<Void Function(), void Function()>('init_rust_module');
}

/// Rust Module Service
/// High-level service for interacting with Rust module
class RustModuleService {
  /// Initialize the Rust module
  static Future<void> initialize() async {
    try {
      RustFFI.init();
      RustModule.initRustModule();
      print('Rust module initialized successfully');
    } catch (e) {
      print('Failed to initialize Rust module: $e');
      throw Exception('Rust module initialization failed: $e');
    }
  }

  /// Generate codes using Rust module
  static String generateCodes(String requestJson) {
    try {
      if (!RustFFI.isAvailable) {
        throw Exception('Rust module not available');
      }

      final requestPtr = requestJson.toNativeUtf8();
      final resultPtr = RustModule.generateCodes(requestPtr);
      final result = resultPtr.toDartString();

      calloc.free(requestPtr);
      return result;
    } catch (e) {
      print('Error generating codes: $e');
      rethrow;
    }
  }

  /// Generate bundle codes
  static String generateBundleCodes(String requestJson) {
    try {
      if (!RustFFI.isAvailable) {
        throw Exception('Rust module not available');
      }

      final requestPtr = requestJson.toNativeUtf8();
      final resultPtr = RustModule.generateBundleCodes(requestPtr);
      final result = resultPtr.toDartString();

      calloc.free(requestPtr);
      return result;
    } catch (e) {
      print('Error generating bundle codes: $e');
      rethrow;
    }
  }

  /// Generate carton codes
  static String generateCartonCodes(String requestJson) {
    try {
      if (!RustFFI.isAvailable) {
        throw Exception('Rust module not available');
      }

      final requestPtr = requestJson.toNativeUtf8();
      final resultPtr = RustModule.generateCartonCodes(requestPtr);
      final result = resultPtr.toDartString();

      calloc.free(requestPtr);
      return result;
    } catch (e) {
      print('Error generating carton codes: $e');
      rethrow;
    }
  }

  /// Generate packet codes
  static String generatePacketCodes(String requestJson) {
    try {
      if (!RustFFI.isAvailable) {
        throw Exception('Rust module not available');
      }

      final requestPtr = requestJson.toNativeUtf8();
      final resultPtr = RustModule.generatePacketCodes(requestPtr);
      final result = resultPtr.toDartString();

      calloc.free(requestPtr);
      return result;
    } catch (e) {
      print('Error generating packet codes: $e');
      rethrow;
    }
  }

  /// Validate a single code
  static String validateCode(String code) {
    try {
      if (!RustFFI.isAvailable) {
        throw Exception('Rust module not available');
      }

      final codePtr = code.toNativeUtf8();
      final resultPtr = RustModule.validateCode(codePtr);
      final result = resultPtr.toDartString();

      calloc.free(codePtr);
      return result;
    } catch (e) {
      print('Error validating code: $e');
      rethrow;
    }
  }
}
