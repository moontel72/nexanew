import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/cricket_models.dart';
import '../../../data/repositories/cricket_repository.dart';

// ─── States ──────────────────────────────────────────────────

sealed class SponsorState {
  const SponsorState();
}

final class SponsorInitial extends SponsorState {
  const SponsorInitial();
}

final class SponsorLoading extends SponsorState {
  const SponsorLoading();
}

/// [library] = the manager's sponsor library.
/// [sponsors] = sponsors currently assigned to the selected match.
final class SponsorLoaded extends SponsorState {
  final List<SponsorModel> library;
  final List<SponsorModel> sponsors;

  const SponsorLoaded({this.library = const [], this.sponsors = const []});
}

final class SponsorError extends SponsorState {
  final String message;
  const SponsorError(this.message);
}

/// Transient mutation feedback. Listeners use [action] to react
/// (e.g. a form only closes on `saveSponsor` success).
final class SponsorNotice extends SponsorState {
  final String action;
  final bool success;
  final String message;

  const SponsorNotice({
    required this.action,
    required this.success,
    required this.message,
  });
}

// ─── Events ──────────────────────────────────────────────────

sealed class SponsorEvent {
  const SponsorEvent();
}

final class LoadSponsors extends SponsorEvent {
  final String matchId;
  const LoadSponsors(this.matchId);
}

final class RefreshSponsors extends SponsorEvent {
  const RefreshSponsors();
}

/// Create (`id == null`) or update a library sponsor.
final class SaveSponsorRequested extends SponsorEvent {
  final String? id;
  final String name;
  final String tier;
  final String? logoUrl;
  final String? bannerImageUrl;
  final String? websiteUrl;
  final int? displayOrder;

  const SaveSponsorRequested({
    this.id,
    required this.name,
    required this.tier,
    this.logoUrl,
    this.bannerImageUrl,
    this.websiteUrl,
    this.displayOrder,
  });
}

final class DeleteSponsorRequested extends SponsorEvent {
  final String sponsorId;
  const DeleteSponsorRequested(this.sponsorId);
}

final class AssignSponsorRequested extends SponsorEvent {
  final String matchId;
  final String sponsorId;
  final String placement;
  final int? displayOrder;

  const AssignSponsorRequested({
    required this.matchId,
    required this.sponsorId,
    required this.placement,
    this.displayOrder,
  });
}

final class RemoveSponsor extends SponsorEvent {
  final String matchId;
  final String sponsorId;
  const RemoveSponsor(this.matchId, this.sponsorId);
}

// ─── BLoC ────────────────────────────────────────────────────

class SponsorBloc extends Bloc<SponsorEvent, SponsorState> {
  final CricketRepository _repo;

  /// Match context for assignment listing; null when the page is
  /// opened without a selected match.
  String? _matchId;

  /// Last successfully loaded data — lets a failed refresh keep the
  /// current lists on screen instead of flashing an error state.
  SponsorLoaded? _lastLoaded;

  SponsorBloc({required CricketRepository repo})
    : _repo = repo,
      super(const SponsorInitial()) {
    on<LoadSponsors>(_onLoad);
    on<RefreshSponsors>(_onRefresh);
    on<SaveSponsorRequested>(_onSave);
    on<DeleteSponsorRequested>(_onDelete);
    on<AssignSponsorRequested>(_onAssign);
    on<RemoveSponsor>(_onRemove);
  }

  Future<void> _onLoad(LoadSponsors e, Emitter<SponsorState> emit) async {
    _matchId = e.matchId.isEmpty ? null : e.matchId;
    emit(const SponsorLoading());
    try {
      final loaded = await _fetchAll();
      _lastLoaded = loaded;
      emit(loaded);
    } catch (err) {
      emit(SponsorError(_message(err)));
    }
  }

  Future<void> _onRefresh(RefreshSponsors e, Emitter<SponsorState> emit) async {
    // After a mutation the transient notice is on screen — show a
    // spinner while the lists reload. Pull-to-refresh keeps the
    // current lists visible instead.
    if (state is SponsorNotice) {
      emit(const SponsorLoading());
    }
    try {
      final loaded = await _fetchAll();
      _lastLoaded = loaded;
      emit(loaded);
    } catch (err) {
      emit(
        SponsorNotice(
          action: 'refresh',
          success: false,
          message: _message(err),
        ),
      );
      emit(_lastLoaded ?? const SponsorError('Failed to refresh sponsors.'));
    }
  }

  Future<SponsorLoaded> _fetchAll() async {
    final library = await _repo.getSponsors();
    final matchSponsors = _matchId == null
        ? <SponsorModel>[]
        : await _repo.getMatchSponsors(_matchId!);
    return SponsorLoaded(library: library, sponsors: matchSponsors);
  }

  Future<void> _onSave(
    SaveSponsorRequested e,
    Emitter<SponsorState> emit,
  ) async {
    try {
      if (e.id == null) {
        await _repo.createSponsor(
          name: e.name,
          tier: e.tier,
          logoUrl: e.logoUrl,
          bannerImageUrl: e.bannerImageUrl,
          websiteUrl: e.websiteUrl,
          displayOrder: e.displayOrder,
        );
      } else {
        await _repo.updateSponsor(
          id: e.id!,
          name: e.name,
          tier: e.tier,
          logoUrl: e.logoUrl,
          bannerImageUrl: e.bannerImageUrl,
          websiteUrl: e.websiteUrl,
          displayOrder: e.displayOrder,
        );
      }
      emit(
        const SponsorNotice(
          action: 'saveSponsor',
          success: true,
          message: 'Sponsor saved.',
        ),
      );
    } catch (err) {
      emit(
        SponsorNotice(
          action: 'saveSponsor',
          success: false,
          message: _message(err),
        ),
      );
    }
    add(const RefreshSponsors());
  }

  Future<void> _onDelete(
    DeleteSponsorRequested e,
    Emitter<SponsorState> emit,
  ) async {
    try {
      await _repo.destroySponsor(e.sponsorId);
      emit(
        const SponsorNotice(
          action: 'deleteSponsor',
          success: true,
          message: 'Sponsor deleted.',
        ),
      );
    } catch (err) {
      emit(
        SponsorNotice(
          action: 'deleteSponsor',
          success: false,
          message: _message(err),
        ),
      );
    }
    add(const RefreshSponsors());
  }

  Future<void> _onAssign(
    AssignSponsorRequested e,
    Emitter<SponsorState> emit,
  ) async {
    try {
      await _repo.assignSponsorToMatch(
        matchId: e.matchId,
        sponsorId: e.sponsorId,
        placement: e.placement,
        displayOrder: e.displayOrder,
      );
      _matchId = e.matchId;
      emit(
        const SponsorNotice(
          action: 'assignSponsor',
          success: true,
          message: 'Sponsor assigned to match.',
        ),
      );
    } catch (err) {
      emit(
        SponsorNotice(
          action: 'assignSponsor',
          success: false,
          message: _message(err),
        ),
      );
    }
    add(const RefreshSponsors());
  }

  Future<void> _onRemove(RemoveSponsor e, Emitter<SponsorState> emit) async {
    try {
      await _repo.deleteSponsor(e.matchId, e.sponsorId);
      emit(
        const SponsorNotice(
          action: 'removeSponsor',
          success: true,
          message: 'Sponsor removed from match.',
        ),
      );
    } catch (err) {
      emit(
        SponsorNotice(
          action: 'removeSponsor',
          success: false,
          message: _message(err),
        ),
      );
    }
    add(const RefreshSponsors());
  }

  String _message(Object err) => err.toString().replaceFirst('Exception: ', '');
}
