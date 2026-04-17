part of 'global_bloc.dart';

// Global State for NexaTrace System
// This file defines the state for the GlobalBloc

class GlobalState extends Equatable {
  final ThemeMode themeMode;
  final String languageCode;
  final String userRole;
  final bool isConnected;
  final String? notificationMessage;
  final NotificationType? notificationType;

  const GlobalState({
    this.themeMode = ThemeMode.light,
    this.languageCode = 'en',
    this.userRole = 'guest',
    this.isConnected = true,
    this.notificationMessage,
    this.notificationType,
  });

  GlobalState copyWith({
    ThemeMode? themeMode,
    String? languageCode,
    String? userRole,
    bool? isConnected,
    String? notificationMessage,
    NotificationType? notificationType,
  }) {
    return GlobalState(
      themeMode: themeMode ?? this.themeMode,
      languageCode: languageCode ?? this.languageCode,
      userRole: userRole ?? this.userRole,
      isConnected: isConnected ?? this.isConnected,
      notificationMessage: notificationMessage ?? this.notificationMessage,
      notificationType: notificationType ?? this.notificationType,
    );
  }

  @override
  List<Object?> get props => [
        themeMode,
        languageCode,
        userRole,
        isConnected,
        notificationMessage,
        notificationType,
      ];

  // Helper getters
  bool get isDarkMode => themeMode == ThemeMode.dark;
  bool get isLightMode => themeMode == ThemeMode.light;
  bool get isAdmin => userRole == 'admin';
  bool get isSuperAdmin => userRole == 'super_admin';
  bool get isFactoryUser => userRole == 'factory_user';
  bool get isDeliveryUser => userRole == 'delivery_user';
  bool get hasNotification => notificationMessage != null;
}
