//lib\shared\bloc\global_bloc.dart
// Global BLoC for NexaTrace System
// This BLoC manages global application state

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'global_event.dart';
part 'global_state.dart';

class GlobalBloc extends Bloc<GlobalEvent, GlobalState> {
  GlobalBloc() : super(const GlobalState()) {
    on<ChangeThemeEvent>(_onChangeTheme);
    on<ChangeLanguageEvent>(_onChangeLanguage);
    on<SetUserRoleEvent>(_onSetUserRole);
    on<UpdateConnectionStatusEvent>(_onUpdateConnectionStatus);
  }

  void _onChangeTheme(ChangeThemeEvent event, Emitter<GlobalState> emit) {
    emit(state.copyWith(themeMode: event.themeMode));
  }

  void _onChangeLanguage(ChangeLanguageEvent event, Emitter<GlobalState> emit) {
    emit(state.copyWith(languageCode: event.languageCode));
  }

  void _onSetUserRole(SetUserRoleEvent event, Emitter<GlobalState> emit) {
    emit(state.copyWith(userRole: event.userRole));
  }

  void _onUpdateConnectionStatus(
    UpdateConnectionStatusEvent event,
    Emitter<GlobalState> emit,
  ) {
    emit(state.copyWith(isConnected: event.isConnected));
  }

  // Helper methods
  void changeTheme(ThemeMode themeMode) {
    add(ChangeThemeEvent(themeMode));
  }

  void changeLanguage(String languageCode) {
    add(ChangeLanguageEvent(languageCode));
  }

  void setUserRole(String userRole) {
    add(SetUserRoleEvent(userRole));
  }

  void updateConnectionStatus(bool isConnected) {
    add(UpdateConnectionStatusEvent(isConnected));
  }
}
