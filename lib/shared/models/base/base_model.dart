//lib\shared\models\base\base_model.dart
// Base Model for NexaTrace System
// This file contains the base model class that all other models extend

import 'dart:convert';

abstract class BaseModel {
  /// Unique identifier for the model
  String? id;

  /// Date when the model was created
  DateTime? createdAt;

  /// Date when the model was last updated
  DateTime? updatedAt;

  /// Whether the model is active
  bool? isActive;

  /// Whether the model is deleted (soft delete)
  bool? isDeleted;

  BaseModel({
    this.id,
    this.createdAt,
    this.updatedAt,
    this.isActive = true,
    this.isDeleted = false,
  });

  /// Convert model to JSON map
  Map<String, dynamic> toJson();

  /// Create model from JSON map
  factory BaseModel.fromJson(Map<String, dynamic> json) {
    throw UnimplementedError('fromJson must be implemented in subclasses');
  }

  /// Convert model to JSON string
  String toJsonString() => jsonEncode(toJson());

  /// Create model from JSON string
  factory BaseModel.fromJsonString(String jsonString) {
    final json = jsonDecode(jsonString);
    return BaseModel.fromJson(json);
  }

  /// Copy model with new values
  BaseModel copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    bool? isDeleted,
  });

  /// Check if two models are equal
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BaseModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  /// Convert to string representation
  @override
  String toString() {
    return 'BaseModel{id: $id, createdAt: $createdAt, updatedAt: $updatedAt, isActive: $isActive, isDeleted: $isDeleted}';
  }

  /// Validate model data
  List<String> validate() {
    final errors = <String>[];

    if (id != null && id!.isEmpty) {
      errors.add('ID cannot be empty');
    }

    if (createdAt != null && createdAt!.isAfter(DateTime.now())) {
      errors.add('Created date cannot be in the future');
    }

    if (updatedAt != null && updatedAt!.isAfter(DateTime.now())) {
      errors.add('Updated date cannot be in the future');
    }

    if (createdAt != null &&
        updatedAt != null &&
        updatedAt!.isBefore(createdAt!)) {
      errors.add('Updated date cannot be before created date');
    }

    return errors;
  }

  /// Check if model is valid
  bool isValid() => validate().isEmpty;

  /// Get model type name
  String get modelType => runtimeType.toString();

  /// Get display name for the model
  String get displayName => id ?? 'Unknown';

  /// Check if model is new (has no ID)
  bool get isNew => id == null || id!.isEmpty;

  /// Check if model has been modified
  bool get isModified {
    if (createdAt == null || updatedAt == null) return false;
    return updatedAt!.difference(createdAt!).inSeconds > 0;
  }

  /// Get age of model in days
  int? get ageInDays {
    if (createdAt == null) return null;
    final now = DateTime.now();
    return now.difference(createdAt!).inDays;
  }

  /// Get last modified time in days
  int? get lastModifiedInDays {
    if (updatedAt == null) return null;
    final now = DateTime.now();
    return now.difference(updatedAt!).inDays;
  }

  /// Prepare model for API request
  Map<String, dynamic> toApiJson() {
    final json = toJson();
    // Remove internal fields that shouldn't be sent to API
    json.remove('createdAt');
    json.remove('updatedAt');
    json.remove('isDeleted');
    return json;
  }

  /// Create model from API response
  factory BaseModel.fromApiJson(Map<String, dynamic> json) {
    return BaseModel.fromJson(json);
  }

  /// Merge another model into this one
  void merge(BaseModel other) {
    if (other.id != null) id = other.id;
    if (other.createdAt != null) createdAt = other.createdAt;
    if (other.updatedAt != null) updatedAt = other.updatedAt;
    if (other.isActive != null) isActive = other.isActive;
    if (other.isDeleted != null) isDeleted = other.isDeleted;
  }

  /// Reset model to default values
  void reset() {
    id = null;
    createdAt = null;
    updatedAt = null;
    isActive = true;
    isDeleted = false;
  }

  /// Create a deep copy of the model
  BaseModel deepCopy();

  /// Compare with another model ignoring timestamps
  bool equalsIgnoringTimestamps(BaseModel other) {
    return id == other.id &&
        isActive == other.isActive &&
        isDeleted == other.isDeleted;
  }

  /// Get model metadata
  Map<String, dynamic> get metadata {
    return {
      'modelType': modelType,
      'id': id,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isActive': isActive,
      'isDeleted': isDeleted,
      'isNew': isNew,
      'isModified': isModified,
      'ageInDays': ageInDays,
      'lastModifiedInDays': lastModifiedInDays,
    };
  }

  /// Format date for display
  String? formatDate(DateTime? date, {String format = 'yyyy-MM-dd HH:mm'}) {
    if (date == null) return null;
    // Simple date formatting - in real app, use intl package
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  /// Get created date as formatted string
  String? get formattedCreatedAt => formatDate(createdAt);

  /// Get updated date as formatted string
  String? get formattedUpdatedAt => formatDate(updatedAt);

  /// Check if model was created today
  bool get isCreatedToday {
    if (createdAt == null) return false;
    final now = DateTime.now();
    return createdAt!.year == now.year &&
        createdAt!.month == now.month &&
        createdAt!.day == now.day;
  }

  /// Check if model was updated today
  bool get isUpdatedToday {
    if (updatedAt == null) return false;
    final now = DateTime.now();
    return updatedAt!.year == now.year &&
        updatedAt!.month == now.month &&
        updatedAt!.day == now.day;
  }

  /// Get status badge color
  String get statusColor {
    if (isDeleted == true) return 'red';
    if (isActive == false) return 'orange';
    return 'green';
  }

  /// Get status text
  String get statusText {
    if (isDeleted == true) return 'Deleted';
    if (isActive == false) return 'Inactive';
    return 'Active';
  }
}

/// Base model with pagination support
class PaginatedResponse<T extends BaseModel> {
  final List<T> data;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int perPage;
  final bool hasNextPage;
  final bool hasPreviousPage;

  PaginatedResponse({
    required this.data,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.perPage,
  })  : hasNextPage = currentPage < totalPages,
        hasPreviousPage = currentPage > 1;

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final data = (json['data'] as List)
        .map((item) => fromJson(item as Map<String, dynamic>))
        .toList();

    return PaginatedResponse<T>(
      data: data,
      currentPage: json['current_page'] ?? 1,
      totalPages: json['last_page'] ?? 1,
      totalItems: json['total'] ?? data.length,
      perPage: json['per_page'] ?? data.length,
    );
  }

  Map<String, dynamic> toJson(T Function(T) toJson) {
    return {
      'data': data.map((item) => toJson(item)).toList(),
      'current_page': currentPage,
      'last_page': totalPages,
      'total': totalItems,
      'per_page': perPage,
    };
  }

  @override
  String toString() {
    return 'PaginatedResponse{data: ${data.length} items, currentPage: $currentPage, totalPages: $totalPages, totalItems: $totalItems, perPage: $perPage}';
  }
}

/// Base model for list operations
class ModelList<T extends BaseModel> {
  final List<T> items;
  final int totalCount;
  final int filteredCount;

  ModelList({
    required this.items,
    required this.totalCount,
    required this.filteredCount,
  });

  factory ModelList.empty() {
    return ModelList<T>(
      items: [],
      totalCount: 0,
      filteredCount: 0,
    );
  }

  factory ModelList.fromList(List<T> items) {
    return ModelList<T>(
      items: items,
      totalCount: items.length,
      filteredCount: items.length,
    );
  }

  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;
  int get length => items.length;

  T operator [](int index) => items[index];

  void add(T item) {
    items.add(item);
  }

  void addAll(Iterable<T> itemsToAdd) {
    items.addAll(itemsToAdd);
  }
}
