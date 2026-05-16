import 'package:bloc/bloc.dart';
import 'package:nexatrace_system/features/reseller/data/repositories/reseller_session_repository.dart';

sealed class ResellerAuthEvent {}

final class ResellerLoginRequested extends ResellerAuthEvent {
  final String email;
  final String password;
  ResellerLoginRequested({required this.email, required this.password});
}

final class ResellerLogoutRequested extends ResellerAuthEvent {}

final class ResellerCheckAuthRequested extends ResellerAuthEvent {}

sealed class ResellerAuthState {}

final class ResellerAuthInitial extends ResellerAuthState {}

final class ResellerAuthLoading extends ResellerAuthState {}

final class ResellerAuthenticated extends ResellerAuthState {}

final class ResellerUnauthenticated extends ResellerAuthState {
  final String? message;
  ResellerUnauthenticated({this.message});
}

final class ResellerAuthError extends ResellerAuthState {
  final String message;
  ResellerAuthError(this.message);
}

class ResellerAuthBloc extends Bloc<ResellerAuthEvent, ResellerAuthState> {
  final ResellerSessionRepository _repo;

  ResellerAuthBloc({required ResellerSessionRepository repo})
      : _repo = repo,
        super(ResellerAuthInitial()) {
    on<ResellerLoginRequested>(_onLogin);
    on<ResellerLogoutRequested>(_onLogout);
    on<ResellerCheckAuthRequested>(_onCheck);
  }

  Future<void> _onLogin(
    ResellerLoginRequested event,
    Emitter<ResellerAuthState> emit,
  ) async {
    emit(ResellerAuthLoading());
    try {
      await _repo.login(email: event.email, password: event.password);
      emit(ResellerAuthenticated());
    } catch (e) {
      emit(ResellerAuthError(e.toString()));
    }
  }

  Future<void> _onLogout(
    ResellerLogoutRequested event,
    Emitter<ResellerAuthState> emit,
  ) async {
    emit(ResellerAuthLoading());
    await _repo.logout();
    emit(ResellerUnauthenticated(message: 'Logged out'));
  }

  Future<void> _onCheck(
    ResellerCheckAuthRequested event,
    Emitter<ResellerAuthState> emit,
  ) async {
    final ok = _repo.isAuthenticated();
    emit(ok ? ResellerAuthenticated() : ResellerUnauthenticated());
  }
}

