// Admin User Entity for NexaTrace System
// This file defines the AdminUser entity used throughout the application

import 'package:equatable/equatable.dart';

class AdminUser extends Equatable {
  final String id;
  final String email;
  final String name;
  final String? phone;
  final String role;
  final String status;
  final DateTime? emailVerifiedAt;
  final DateTime? lastLoginAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? permissions;
  final Map<String, dynamic>? settings;
  final bool isSuperAdmin;
  final bool isActive;
  final String? avatarUrl;
  final String? timezone;
  final String? language;

  const AdminUser({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    required this.role,
    required this.status,
    this.emailVerifiedAt,
    this.lastLoginAt,
    required this.createdAt,
    required this.updatedAt,
    this.permissions,
    this.settings,
    required this.isSuperAdmin,
    required this.isActive,
    this.avatarUrl,
    this.timezone,
    this.language,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString(),
      role: json['role']?.toString() ?? 'admin',
      status: json['status']?.toString() ?? 'active',
      emailVerifiedAt: json['email_verified_at'] != null
          ? DateTime.parse(json['email_verified_at'].toString())
          : null,
      lastLoginAt: json['last_login_at'] != null
          ? DateTime.parse(json['last_login_at'].toString())
          : null,
      createdAt: DateTime.parse(json['created_at'].toString()),
      updatedAt: DateTime.parse(json['updated_at'].toString()),
      permissions: json['permissions'] != null
          ? Map<String, dynamic>.from(json['permissions'])
          : null,
      settings: json['settings'] != null
          ? Map<String, dynamic>.from(json['settings'])
          : null,
      isSuperAdmin: json['is_super_admin'] ?? false,
      isActive: json['is_active'] ?? true,
      avatarUrl: json['avatar_url']?.toString(),
      timezone: json['timezone']?.toString(),
      language: json['language']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'role': role,
      'status': status,
      'email_verified_at': emailVerifiedAt?.toIso8601String(),
      'last_login_at': lastLoginAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'permissions': permissions,
      'settings': settings,
      'is_super_admin': isSuperAdmin,
      'is_active': isActive,
      'avatar_url': avatarUrl,
      'timezone': timezone,
      'language': language,
    };
  }

  AdminUser copyWith({
    String? id,
    String? email,
    String? name,
    String? phone,
    String? role,
    String? status,
    DateTime? emailVerifiedAt,
    DateTime? lastLoginAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? permissions,
    Map<String, dynamic>? settings,
    bool? isSuperAdmin,
    bool? isActive,
    String? avatarUrl,
    String? timezone,
    String? language,
  }) {
    return AdminUser(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      status: status ?? this.status,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      permissions: permissions ?? this.permissions,
      settings: settings ?? this.settings,
      isSuperAdmin: isSuperAdmin ?? this.isSuperAdmin,
      isActive: isActive ?? this.isActive,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      timezone: timezone ?? this.timezone,
      language: language ?? this.language,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        name,
        phone,
        role,
        status,
        emailVerifiedAt,
        lastLoginAt,
        createdAt,
        updatedAt,
        permissions,
        settings,
        isSuperAdmin,
        isActive,
        avatarUrl,
        timezone,
        language,
      ];

  // Helper methods
  bool get isEmailVerified => emailVerifiedAt != null;
  bool get hasLoggedInBefore => lastLoginAt != null;
  bool get hasPhone => phone != null && phone!.isNotEmpty;
  bool get hasAvatar => avatarUrl != null && avatarUrl!.isNotEmpty;

  // Permission check methods
  bool hasPermission(String permission) {
    if (permissions == null) return false;
    return permissions![permission] == true;
  }

  bool hasAnyPermission(List<String> permissions) {
    if (this.permissions == null) return false;
    for (final permission in permissions) {
      if (this.permissions![permission] == true) {
        return true;
      }
    }
    return false;
  }

  bool hasAllPermissions(List<String> permissions) {
    if (this.permissions == null) return false;
    for (final permission in permissions) {
      if (this.permissions![permission] != true) {
        return false;
      }
    }
    return true;
  }

  // Role check methods
  bool get canManageUsers => isSuperAdmin || hasPermission('manage_users');
  bool get canManageCompanies =>
      isSuperAdmin || hasPermission('manage_companies');
  bool get canManagePlans => isSuperAdmin || hasPermission('manage_plans');
  bool get canManageSubscriptions =>
      isSuperAdmin || hasPermission('manage_subscriptions');
  bool get canViewReports => isSuperAdmin || hasPermission('view_reports');
  bool get canManageSettings =>
      isSuperAdmin || hasPermission('manage_settings');

  // Status check methods
  bool get isPending => status == 'pending';
  bool get isSuspended => status == 'suspended';
  bool get isDeleted => status == 'deleted';

  // Get display name
  String get displayName {
    if (name.isNotEmpty) return name;
    return email.split('@').first;
  }

  // Get initials for avatar
  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (name.isNotEmpty) {
      return name.substring(0, 1).toUpperCase();
    } else {
      return email.substring(0, 1).toUpperCase();
    }
  }
}
