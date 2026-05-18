import 'package:nexatrace_system/core/config/api_config.dart';
import 'package:nexatrace_system/core/errors/app_exceptions.dart';
import 'package:nexatrace_system/core/services/api_client.dart';

/// Remote datasource for driver-related API calls to the Laravel backend.
///
/// All methods communicate with the NexaTrace API using [ApiClient] and
/// return raw JSON data. Entity mapping is handled at the repository layer.
class DriverRemoteDatasource {
  final ApiClient _apiClient;

  DriverRemoteDatasource({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  // ──────────────────────────────────────────────
  // Base endpoint prefix
  // ──────────────────────────────────────────────
  String get _basePath => '${ApiConfig.apiBaseUrl}/driver';

  // ──────────────────────────────────────────────
  // Profile
  // ──────────────────────────────────────────────

  Future<Map<String, dynamic>> getDriverProfile() async {
    try {
      final response = await _apiClient.get('$_basePath/profile');
      return response as Map<String, dynamic>;
    } catch (e) {
      throw _mapError(e);
    }
  }

  // ──────────────────────────────────────────────
  // Trips
  // ──────────────────────────────────────────────

  Future<List<dynamic>> getTrips({String? status}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }
      final response = await _apiClient.get(
        '$_basePath/trips',
        queryParams: queryParams,
      );
      return (response['data'] as List<dynamic>?) ?? [];
    } catch (e) {
      throw _mapError(e);
    }
  }

  Future<Map<String, dynamic>> getTripById(String tripId) async {
    try {
      final response = await _apiClient.get('$_basePath/trips/$tripId');
      return response as Map<String, dynamic>;
    } catch (e) {
      throw _mapError(e);
    }
  }

  Future<Map<String, dynamic>> updateTripStatus({
    required String tripId,
    required String status,
    required double lat,
    required double lng,
  }) async {
    try {
      final response = await _apiClient.patch(
        '$_basePath/trips/$tripId/status',
        body: {'status': status, 'lat': lat, 'lng': lng},
      );
      return response as Map<String, dynamic>;
    } catch (e) {
      throw _mapError(e);
    }
  }

  Future<Map<String, dynamic>> checkDeliveryScanEligibility({
    required String tripId,
    required double lat,
    required double lng,
  }) async {
    try {
      final response = await _apiClient.post(
        '$_basePath/trips/$tripId/check-eligibility',
        body: {'lat': lat, 'lng': lng},
      );
      return response as Map<String, dynamic>;
    } catch (e) {
      throw _mapError(e);
    }
  }

  Future<Map<String, dynamic>> scanPickup({
    required String tripId,
    required String code,
    required double lat,
    required double lng,
  }) async {
    try {
      final response = await _apiClient.post(
        '$_basePath/trips/$tripId/scan-pickup',
        body: {'code': code, 'lat': lat, 'lng': lng},
      );
      return response as Map<String, dynamic>;
    } catch (e) {
      throw _mapError(e);
    }
  }

  Future<Map<String, dynamic>> scanDelivery({
    required String tripId,
    required String code,
    required double lat,
    required double lng,
  }) async {
    try {
      final response = await _apiClient.post(
        '$_basePath/trips/$tripId/scan-delivery',
        body: {'code': code, 'lat': lat, 'lng': lng},
      );
      return response as Map<String, dynamic>;
    } catch (e) {
      throw _mapError(e);
    }
  }

  // ──────────────────────────────────────────────
  // Proof of Delivery
  // ──────────────────────────────────────────────

  Future<Map<String, dynamic>> submitProofOfDelivery({
    required String tripId,
    required String verificationType,
    String? pin,
    String? recipientPhotoPath,
    String? documentPhotoPath,
    String? signaturePath,
    String? recipientName,
    List<String>? debriefPhotoPaths,
    String? damageNotes,
  }) async {
    try {
      final body = <String, dynamic>{'verification_type': verificationType};

      if (pin != null) body['pin'] = pin;
      if (recipientName != null) body['recipient_name'] = recipientName;
      if (damageNotes != null) body['damage_notes'] = damageNotes;
      if (debriefPhotoPaths != null)
        body['debrief_photo_paths'] = debriefPhotoPaths;

      // Upload files individually if paths are provided
      if (recipientPhotoPath != null) {
        await _apiClient.uploadFile(
          '$_basePath/trips/$tripId/proof-of-delivery',
          recipientPhotoPath,
          'recipient_photo',
          fields: body.map((k, v) => MapEntry(k, v.toString())),
        );
      }

      if (documentPhotoPath != null) {
        await _apiClient.uploadFile(
          '$_basePath/trips/$tripId/proof-of-delivery',
          documentPhotoPath,
          'document_photo',
          fields: body.map((k, v) => MapEntry(k, v.toString())),
        );
      }

      if (signaturePath != null) {
        await _apiClient.uploadFile(
          '$_basePath/trips/$tripId/proof-of-delivery',
          signaturePath,
          'signature',
          fields: body.map((k, v) => MapEntry(k, v.toString())),
        );
      }

      // Final submission (or fallback if no files to upload)
      final response = await _apiClient.post(
        '$_basePath/trips/$tripId/proof-of-delivery',
        body: body,
      );
      return response as Map<String, dynamic>;
    } catch (e) {
      throw _mapError(e);
    }
  }

  // ──────────────────────────────────────────────
  // Expenses
  // ──────────────────────────────────────────────

  Future<Map<String, dynamic>> submitExpense({
    required String tripId,
    required String type,
    required double amount,
    required String receiptPath,
    String? notes,
  }) async {
    try {
      final fields = <String, String>{
        'trip_id': tripId,
        'type': type,
        'amount': amount.toString(),
      };
      if (notes != null) fields['notes'] = notes;

      final response = await _apiClient.uploadFile(
        '$_basePath/expenses',
        receiptPath,
        'receipt',
        fields: fields,
      );
      return response as Map<String, dynamic>;
    } catch (e) {
      throw _mapError(e);
    }
  }

  Future<List<dynamic>> getTripExpenses(String tripId) async {
    try {
      final response = await _apiClient.get(
        '$_basePath/trips/$tripId/expenses',
      );
      return (response['data'] as List<dynamic>?) ?? [];
    } catch (e) {
      throw _mapError(e);
    }
  }

  // ──────────────────────────────────────────────
  // Earnings
  // ──────────────────────────────────────────────

  Future<Map<String, dynamic>> getEarnings({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (startDate != null) {
        queryParams['start_date'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['end_date'] = endDate.toIso8601String();
      }
      final response = await _apiClient.get(
        '$_basePath/earnings',
        queryParams: queryParams,
      );
      return response as Map<String, dynamic>;
    } catch (e) {
      throw _mapError(e);
    }
  }

  Future<Map<String, dynamic>> getPaymentHistory({
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'per_page': perPage};
      if (startDate != null) {
        queryParams['start_date'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['end_date'] = endDate.toIso8601String();
      }
      final response = await _apiClient.get(
        '$_basePath/earnings/transactions',
        queryParams: queryParams,
      );
      return response as Map<String, dynamic>;
    } catch (e) {
      throw _mapError(e);
    }
  }

  // ──────────────────────────────────────────────
  // Vehicle Maintenance
  // ──────────────────────────────────────────────

  Future<Map<String, dynamic>> addMaintenanceLog({
    required String vehicleId,
    required String type,
    required DateTime serviceDate,
    required DateTime nextServiceDate,
    double? mileage,
    String? notes,
  }) async {
    try {
      final body = <String, dynamic>{
        'vehicle_id': vehicleId,
        'type': type,
        'service_date': serviceDate.toIso8601String(),
        'next_service_date': nextServiceDate.toIso8601String(),
      };
      if (mileage != null) body['mileage'] = mileage;
      if (notes != null) body['notes'] = notes;

      final response = await _apiClient.post(
        '$_basePath/maintenance',
        body: body,
      );
      return response as Map<String, dynamic>;
    } catch (e) {
      throw _mapError(e);
    }
  }

  Future<List<dynamic>> getMaintenanceLogs(String vehicleId) async {
    try {
      final response = await _apiClient.get(
        '$_basePath/maintenance/$vehicleId',
      );
      return (response['data'] as List<dynamic>?) ?? [];
    } catch (e) {
      throw _mapError(e);
    }
  }

  // ──────────────────────────────────────────────
  // Chat / Messages
  // ──────────────────────────────────────────────

  Future<List<dynamic>> getMessages(String chatId, {int page = 1}) async {
    try {
      final response = await _apiClient.get(
        '$_basePath/chats/$chatId/messages',
        queryParams: {'page': page},
      );
      return (response['data'] as List<dynamic>?) ?? [];
    } catch (e) {
      throw _mapError(e);
    }
  }

  Future<Map<String, dynamic>> sendMessage({
    required String chatId,
    required String message,
    String? attachmentPath,
  }) async {
    try {
      if (attachmentPath != null) {
        final fields = <String, String>{'chat_id': chatId, 'message': message};
        final response = await _apiClient.uploadFile(
          '$_basePath/chats/$chatId/messages',
          attachmentPath,
          'attachment',
          fields: fields,
        );
        return response as Map<String, dynamic>;
      }

      final response = await _apiClient.post(
        '$_basePath/chats/$chatId/messages',
        body: {'message': message},
      );
      return response as Map<String, dynamic>;
    } catch (e) {
      throw _mapError(e);
    }
  }

  // ──────────────────────────────────────────────
  // Disputes
  // ──────────────────────────────────────────────

  Future<List<dynamic>> getDisputes() async {
    try {
      final response = await _apiClient.get('$_basePath/disputes');
      return (response['data'] as List<dynamic>?) ?? [];
    } catch (e) {
      throw _mapError(e);
    }
  }

  Future<Map<String, dynamic>> submitCounterEvidence({
    required String disputeId,
    required String evidence,
  }) async {
    try {
      final response = await _apiClient.post(
        '$_basePath/disputes/$disputeId/counter-evidence',
        body: {'evidence': evidence},
      );
      return response as Map<String, dynamic>;
    } catch (e) {
      throw _mapError(e);
    }
  }

  // ──────────────────────────────────────────────
  // GPS & Location
  // ──────────────────────────────────────────────

  Future<Map<String, dynamic>> checkFakeGps() async {
    try {
      final response = await _apiClient.get('$_basePath/check-fake-gps');
      return response as Map<String, dynamic>;
    } catch (e) {
      throw _mapError(e);
    }
  }

  Future<void> updateLocation({
    required String tripId,
    required double lat,
    required double lng,
  }) async {
    try {
      await _apiClient.post(
        '$_basePath/trips/$tripId/location',
        body: {'lat': lat, 'lng': lng},
      );
    } catch (e) {
      throw _mapError(e);
    }
  }

  // ──────────────────────────────────────────────
  // KPIs
  // ──────────────────────────────────────────────

  Future<Map<String, dynamic>> getDriverKpis() async {
    try {
      final response = await _apiClient.get('$_basePath/kpis');
      return response as Map<String, dynamic>;
    } catch (e) {
      throw _mapError(e);
    }
  }

  // ──────────────────────────────────────────────
  // Offline Sync
  // ──────────────────────────────────────────────

  Future<void> syncOfflineData(
    List<Map<String, dynamic>> pendingActions,
  ) async {
    try {
      await _apiClient.post(
        '$_basePath/sync',
        body: {'actions': pendingActions},
      );
    } catch (e) {
      throw _mapError(e);
    }
  }

  // ──────────────────────────────────────────────
  // Error mapping
  // ──────────────────────────────────────────────

  /// Maps API/network errors to typed [AppException] subclasses.
  Never _mapError(dynamic error) {
    if (error is AppException) throw error;

    if (error is FormatException) {
      throw const DataParsingException('Invalid response format');
    }

    // Re-throw any exception that already identifies itself
    throw ServerException(error.toString(), 0, null);
  }
}

/// Thrown when the server response cannot be parsed into the expected model.
class DataParsingException extends AppException {
  const DataParsingException(super.message, [super.stackTrace]);
}
