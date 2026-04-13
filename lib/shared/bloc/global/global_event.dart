part of 'global_bloc.dart';

// Global Events for NexaTrace System
// This file defines events for the GlobalBloc

abstract class GlobalEvent extends Equatable {
  const GlobalEvent();

  @override
  List<Object> get props => [];
}

class ChangeThemeEvent extends GlobalEvent {
  final ThemeMode themeMode;

  const ChangeThemeEvent(this.themeMode);

  @override
  List<Object> get props => [themeMode];
}

class ChangeLanguageEvent extends GlobalEvent {
  final String languageCode;

  const ChangeLanguageEvent(this.languageCode);

  @override
  List<Object> get props => [languageCode];
}

class SetUserRoleEvent extends GlobalEvent {
  final String userRole;

  const SetUserRoleEvent(this.userRole);

  @override
  List<Object> get props => [userRole];
}

class UpdateConnectionStatusEvent extends GlobalEvent {
  final bool isConnected;

  const UpdateConnectionStatusEvent(this.isConnected);

  @override
  List<Object> get props => [isConnected];
}

class ShowNotificationEvent extends GlobalEvent {
  final String message;
  final NotificationType type;

  const ShowNotificationEvent(this.message, this.type);

  @override
  List<Object> get props => [message, type];
}

class ClearNotificationEvent extends GlobalEvent {
  const ClearNotificationEvent();
}

enum NotificationType {
  success,
  error,
  warning,
  info,
}
