import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/cricket_models.dart';
import '../../../data/repositories/cricket_repository.dart';

// ─── States ──────────────────────────────────────────────

sealed class CricketAuthState {
  const CricketAuthState();
}

final class CricketAuthInitial extends CricketAuthState {}

final class CricketAuthLoading extends CricketAuthState {}

final class CricketAuthLoggedIn extends CricketAuthState {
  final CricketManagerModel manager;
  final String token;

  const CricketAuthLoggedIn({required this.manager, required this.token});
}

final class CricketAuthError extends CricketAuthState {
  final String message;
  const CricketAuthError(this.message);
}

// ─── Events ──────────────────────────────────────────────

sealed class CricketAuthEvent {
  const CricketAuthEvent();
}

final class CricketLogin extends CricketAuthEvent {
  final String email;
  final String password;

  const CricketLogin({required this.email, required this.password});
}

final class CricketLogout extends CricketAuthEvent {}

// ─── BLoC ────────────────────────────────────────────────

class CricketAuthBloc extends Bloc<CricketAuthEvent, CricketAuthState> {
  final CricketRepository _repo;

  CricketAuthBloc({required CricketRepository repo})
    : _repo = repo,
      super(CricketAuthInitial()) {
    on<CricketLogin>(_onLogin);
    on<CricketLogout>(_onLogout);
  }

  Future<void> _onLogin(CricketLogin e, Emitter<CricketAuthState> emit) async {
    emit(CricketAuthLoading());
    try {
      final result = await _repo.login(e.email, e.password);
      if (result == null || result['token'] == null) {
        emit(const CricketAuthError('Invalid credentials.'));
        return;
      }
      final token = result['token'] as String;
      // Token already stored by CricketRepository.login() via ApiClient
      final manager = await _repo.getManager();
      if (manager == null) {
        emit(const CricketAuthError('Failed to load manager profile.'));
        return;
      }
      emit(CricketAuthLoggedIn(manager: manager, token: token));
    } catch (err) {
      emit(CricketAuthError(err.toString()));
    }
  }

  void _onLogout(CricketLogout e, Emitter<CricketAuthState> emit) {
    _repo.clearToken();
    emit(CricketAuthInitial());
  }
}
