import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/cricket_models.dart';
import '../../../data/repositories/cricket_repository.dart';

// ─── States ──────────────────────────────────────────────

sealed class SponsorState {
  const SponsorState();
}

final class SponsorInitial extends SponsorState {}

final class SponsorLoading extends SponsorState {}

final class SponsorLoaded extends SponsorState {
  final List<SponsorModel> sponsors;

  const SponsorLoaded({this.sponsors = const []});
}

final class SponsorError extends SponsorState {
  final String message;
  const SponsorError(this.message);
}

// ─── Events ──────────────────────────────────────────────

sealed class SponsorEvent {
  const SponsorEvent();
}

final class LoadSponsors extends SponsorEvent {
  final String matchId;
  const LoadSponsors(this.matchId);
}

final class RemoveSponsor extends SponsorEvent {
  final String matchId;
  final String sponsorId;
  const RemoveSponsor(this.matchId, this.sponsorId);
}

// ─── BLoC ────────────────────────────────────────────────

class SponsorBloc extends Bloc<SponsorEvent, SponsorState> {
  final CricketRepository _repo;

  SponsorBloc({required CricketRepository repo})
    : _repo = repo,
      super(SponsorInitial()) {
    on<LoadSponsors>(_onLoad);
    on<RemoveSponsor>(_onRemove);
  }

  Future<void> _onLoad(LoadSponsors e, Emitter<SponsorState> emit) async {
    emit(SponsorLoading());
    try {
      final sponsors = await _repo.getMatchSponsors(e.matchId);
      emit(SponsorLoaded(sponsors: sponsors));
    } catch (err) {
      emit(SponsorError(err.toString()));
    }
  }

  Future<void> _onRemove(RemoveSponsor e, Emitter<SponsorState> emit) async {
    await _repo.deleteSponsor(e.matchId, e.sponsorId);
    // Reload after deletion to reflect changes
    add(LoadSponsors(e.matchId));
  }
}
