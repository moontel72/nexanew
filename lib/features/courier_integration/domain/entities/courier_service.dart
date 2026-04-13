import 'package:equatable/equatable.dart';

/// Courier Service entity representing a courier service provider
class CourierService extends Equatable {
  final String id;
  final String name;
  final String code;
  final String? logoUrl;
  final bool isActive;

  const CourierService({
    required this.id,
    required this.name,
    required this.code,
    this.logoUrl,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [id, name, code, logoUrl, isActive];

  /// Creates a copy of this CourierService with the given fields replaced
  CourierService copyWith({
    String? id,
    String? name,
    String? code,
    String? logoUrl,
    bool? isActive,
  }) {
    return CourierService(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      logoUrl: logoUrl ?? this.logoUrl,
      isActive: isActive ?? this.isActive,
    );
  }

  /// Creates a CourierService from JSON data
  factory CourierService.fromJson(Map<String, dynamic> json) {
    return CourierService(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String,
      logoUrl: json['logoUrl'] as String?,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  /// Converts this CourierService to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'logoUrl': logoUrl,
      'isActive': isActive,
    };
  }

  /// Returns a string representation of this CourierService
  @override
  String toString() {
    return 'CourierService(id: $id, name: $name, code: $code, isActive: $isActive)';
  }
}
