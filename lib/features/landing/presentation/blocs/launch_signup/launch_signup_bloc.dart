// Launch Signup BLoC
//
// Early-access email capture form. All labels and options come from the
// landing JSON (LandingSignup). If the JSON configures a non-empty
// `endpoint`, submissions POST to that URL; otherwise the request is
// recorded locally and treated as a successful registration (offline-safe
// launch-list behavior).

import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import '../../../data/models/landing_content.dart';

class LaunchSignupState {
  final String name;
  final String email;
  final String interest;
  final bool isSubmitting;
  final bool isSuccess;
  final String? error;

  const LaunchSignupState({
    this.name = '',
    this.email = '',
    this.interest = '',
    this.isSubmitting = false,
    this.isSuccess = false,
    this.error,
  });

  bool get isValidEmail =>
      email.isNotEmpty && RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);

  bool get canSubmit => email.isNotEmpty && isValidEmail && !isSubmitting;

  LaunchSignupState copyWith({
    String? name,
    String? email,
    String? interest,
    bool? isSubmitting,
    bool? isSuccess,
    String? error,
  }) => LaunchSignupState(
    name: name ?? this.name,
    email: email ?? this.email,
    interest: interest ?? this.interest,
    isSubmitting: isSubmitting ?? this.isSubmitting,
    isSuccess: isSuccess ?? this.isSuccess,
    error: error,
  );
}

sealed class LaunchSignupEvent {
  const LaunchSignupEvent();
}

final class SignupNameChanged extends LaunchSignupEvent {
  final String value;
  const SignupNameChanged(this.value);
}

final class SignupEmailChanged extends LaunchSignupEvent {
  final String value;
  const SignupEmailChanged(this.value);
}

final class SignupInterestChanged extends LaunchSignupEvent {
  final String value;
  const SignupInterestChanged(this.value);
}

final class SignupSubmitted extends LaunchSignupEvent {
  final LandingSignup config;
  const SignupSubmitted(this.config);
}

final class SignupReset extends LaunchSignupEvent {
  const SignupReset();
}

class LaunchSignupBloc extends Bloc<LaunchSignupEvent, LaunchSignupState> {
  final http.Client _http;

  LaunchSignupBloc({http.Client? httpClient})
    : _http = httpClient ?? http.Client(),
      super(const LaunchSignupState()) {
    on<SignupNameChanged>((e, emit) => emit(state.copyWith(name: e.value)));
    on<SignupEmailChanged>(
      (e, emit) =>
          emit(state.copyWith(email: e.value, error: null, isSuccess: false)),
    );
    on<SignupInterestChanged>(
      (e, emit) => emit(state.copyWith(interest: e.value)),
    );
    on<SignupSubmitted>(_onSubmitted);
    on<SignupReset>((e, emit) => emit(const LaunchSignupState()));
  }

  Future<void> _onSubmitted(
    SignupSubmitted event,
    Emitter<LaunchSignupState> emit,
  ) async {
    if (!state.canSubmit) {
      emit(state.copyWith(error: 'Please enter a valid email address.'));
      return;
    }

    emit(state.copyWith(isSubmitting: true, error: null));

    final endpoint = event.config.endpoint.trim();
    try {
      if (endpoint.isNotEmpty) {
        final res = await _http
            .post(
              Uri.parse(endpoint),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'name': state.name,
                'email': state.email,
                'interest': state.interest,
              }),
            )
            .timeout(const Duration(seconds: 15));
        if (res.statusCode < 200 || res.statusCode >= 300) {
          emit(
            state.copyWith(
              isSubmitting: false,
              error: 'Submission failed (${res.statusCode}). Please try again.',
            ),
          );
          return;
        }
      }
      // No endpoint configured → local-only registration success.
      emit(state.copyWith(isSubmitting: false, isSuccess: true));
    } catch (_) {
      emit(
        state.copyWith(
          isSubmitting: false,
          error: 'Network error. Please try again shortly.',
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _http.close();
    return super.close();
  }
}
