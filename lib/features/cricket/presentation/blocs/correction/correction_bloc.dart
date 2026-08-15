import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/cricket_models.dart';
import '../../../data/repositories/cricket_repository.dart';

// ─── States ──────────────────────────────────────────────

sealed class CorrectionState {
  const CorrectionState();
}

final class CorrectionInitial extends CorrectionState {}

final class CorrectionLoading extends CorrectionState {}

final class CorrectionError extends CorrectionState {
  final String message;
  const CorrectionError(this.message);
}

/// Delivery history + the edit form for the correction sheet. The form
/// fields live here so the sheet is a pure function of this state.
final class CorrectionLoaded extends CorrectionState {
  final String matchId;
  final List<DeliveryModel> deliveries;
  final bool loading;
  final String? notice;

  // Edit form (null editingBallId = no sheet open).
  final String? editingBallId;
  final DeliveryModel? editingDelivery;
  final int editRuns;
  final String? editExtrasType;
  final bool editIsWicket;
  final String editWicketType;
  final String? editDismissedId;
  final String? editNextBatterId;
  final String? editBatterId;
  final String? editBowlerId;
  final bool saving;

  const CorrectionLoaded({
    required this.matchId,
    this.deliveries = const [],
    this.loading = false,
    this.notice,
    this.editingBallId,
    this.editingDelivery,
    this.editRuns = 0,
    this.editExtrasType,
    this.editIsWicket = false,
    this.editWicketType = 'bowled',
    this.editDismissedId,
    this.editNextBatterId,
    this.editBatterId,
    this.editBowlerId,
    this.saving = false,
  });

  CorrectionLoaded copyWith({
    List<DeliveryModel>? deliveries,
    bool? loading,
    String? notice,
    String? editingBallId,
    DeliveryModel? editingDelivery,
    int? editRuns,
    String? editExtrasType,
    bool? editIsWicket,
    String? editWicketType,
    String? editDismissedId,
    String? editNextBatterId,
    String? editBatterId,
    String? editBowlerId,
    bool? saving,
  }) => CorrectionLoaded(
    matchId: matchId,
    deliveries: deliveries ?? this.deliveries,
    loading: loading ?? this.loading,
    notice: notice ?? this.notice,
    editingBallId: editingBallId ?? this.editingBallId,
    editingDelivery: editingDelivery ?? this.editingDelivery,
    editRuns: editRuns ?? this.editRuns,
    editExtrasType: editExtrasType ?? this.editExtrasType,
    editIsWicket: editIsWicket ?? this.editIsWicket,
    editWicketType: editWicketType ?? this.editWicketType,
    editDismissedId: editDismissedId ?? this.editDismissedId,
    editNextBatterId: editNextBatterId ?? this.editNextBatterId,
    editBatterId: editBatterId ?? this.editBatterId,
    editBowlerId: editBowlerId ?? this.editBowlerId,
    saving: saving ?? this.saving,
  );

  DeliveryModel? get editing {
    if (editingBallId == null) return null;
    for (final d in deliveries) {
      if (d.ballId == editingBallId) return d;
    }
    return null;
  }
}

// ─── Events ──────────────────────────────────────────────

sealed class CorrectionEvent {
  const CorrectionEvent();
}

final class LoadCorrections extends CorrectionEvent {
  final String matchId;
  const LoadCorrections(this.matchId);
}

final class RefreshDeliveries extends CorrectionEvent {}

final class OpenEditBall extends CorrectionEvent {
  final String ballId;
  const OpenEditBall(this.ballId);
}

final class CloseEditBall extends CorrectionEvent {}

final class SetEditRuns extends CorrectionEvent {
  final int runs;
  const SetEditRuns(this.runs);
}

final class SetEditExtrasType extends CorrectionEvent {
  final String? extrasType;
  const SetEditExtrasType(this.extrasType);
}

final class SetEditIsWicket extends CorrectionEvent {
  final bool isWicket;
  const SetEditIsWicket(this.isWicket);
}

final class SetEditWicketType extends CorrectionEvent {
  final String wicketType;
  const SetEditWicketType(this.wicketType);
}

final class SetEditDismissed extends CorrectionEvent {
  final String? playerId;
  const SetEditDismissed(this.playerId);
}

final class SetEditNextBatter extends CorrectionEvent {
  final String? playerId;
  const SetEditNextBatter(this.playerId);
}

final class SetEditBatter extends CorrectionEvent {
  final String? playerId;
  const SetEditBatter(this.playerId);
}

final class SetEditBowler extends CorrectionEvent {
  final String? playerId;
  const SetEditBowler(this.playerId);
}

final class SaveEditBall extends CorrectionEvent {}

final class DeleteBall extends CorrectionEvent {
  final String ballId;
  const DeleteBall(this.ballId);
}

final class ClearCorrectionNotice extends CorrectionEvent {}

final class ResetCorrections extends CorrectionEvent {}

// ─── BLoC ────────────────────────────────────────────────

class CorrectionBloc extends Bloc<CorrectionEvent, CorrectionState> {
  final CricketRepository _repo;
  StreamSubscription<LiveScoreSnapshot>? _scoreSub;
  String? _matchId;

  CorrectionBloc({required CricketRepository repo})
    : _repo = repo,
      super(CorrectionInitial()) {
    on<LoadCorrections>(_onLoad);
    on<RefreshDeliveries>(_onRefresh);
    on<OpenEditBall>(_onOpenEdit);
    on<CloseEditBall>(_onCloseEdit);
    on<SetEditRuns>(_onSetRuns);
    on<SetEditExtrasType>(_onSetExtras);
    on<SetEditIsWicket>(_onSetWicket);
    on<SetEditWicketType>(_onSetWicketType);
    on<SetEditDismissed>(_onSetDismissed);
    on<SetEditNextBatter>(_onSetNextBatter);
    on<SetEditBatter>(_onSetBatter);
    on<SetEditBowler>(_onSetBowler);
    on<SaveEditBall>(_onSave);
    on<DeleteBall>(_onDelete);
    on<ClearCorrectionNotice>(_onClearNotice);
    on<ResetCorrections>(_onReset);
  }

  Future<void> _onLoad(LoadCorrections e, Emitter<CorrectionState> emit) async {
    _matchId = e.matchId;
    emit(CorrectionLoading());

    final deliveries = await _repo.listDeliveries(e.matchId);

    emit(CorrectionLoaded(matchId: e.matchId, deliveries: deliveries));

    // Keep the history fresh after every recorded ball / correction push.
    _scoreSub?.cancel();
    _scoreSub = _repo.scoreStream.listen((snapshot) {
      if (!isClosed && snapshot.matchId == _matchId) {
        add(RefreshDeliveries());
      }
    });
  }

  Future<void> _onRefresh(
    RefreshDeliveries e,
    Emitter<CorrectionState> emit,
  ) async {
    final s = state;
    final matchId = s is CorrectionLoaded ? s.matchId : _matchId;
    if (matchId == null) return;
    final deliveries = await _repo.listDeliveries(matchId);
    if (s is CorrectionLoaded) {
      emit(s.copyWith(deliveries: deliveries));
    }
  }

  void _onOpenEdit(OpenEditBall e, Emitter<CorrectionState> emit) {
    final s = state;
    if (s is! CorrectionLoaded) return;

    DeliveryModel? delivery;
    for (final d in s.deliveries) {
      if (d.ballId == e.ballId) {
        delivery = d;
        break;
      }
    }
    if (delivery == null) return;

    emit(
      s.copyWith(
        editingBallId: e.ballId,
        editingDelivery: delivery,
        editRuns: delivery.runs,
        editExtrasType: delivery.extrasType,
        editIsWicket: delivery.isWicket,
        editWicketType: delivery.wicketType ?? 'bowled',
        editDismissedId: delivery.dismissedPlayerId,
        editNextBatterId: delivery.nextBatterId,
        editBatterId: delivery.batterId,
        editBowlerId: delivery.bowlerId,
        saving: false,
      ),
    );
  }

  void _onCloseEdit(CloseEditBall e, Emitter<CorrectionState> emit) {
    final s = state;
    if (s is! CorrectionLoaded) return;
    emit(s.copyWith(editingBallId: null, editingDelivery: null, saving: false));
  }

  void _onSetRuns(SetEditRuns e, Emitter<CorrectionState> emit) {
    final s = state;
    if (s is! CorrectionLoaded) return;
    emit(s.copyWith(editRuns: e.runs));
  }

  void _onSetExtras(SetEditExtrasType e, Emitter<CorrectionState> emit) {
    final s = state;
    if (s is! CorrectionLoaded) return;
    emit(s.copyWith(editExtrasType: e.extrasType));
  }

  void _onSetWicket(SetEditIsWicket e, Emitter<CorrectionState> emit) {
    final s = state;
    if (s is! CorrectionLoaded) return;
    emit(
      s.copyWith(
        editIsWicket: e.isWicket,
        editDismissedId: e.isWicket ? s.editDismissedId : null,
        editNextBatterId: e.isWicket ? s.editNextBatterId : null,
      ),
    );
  }

  void _onSetWicketType(SetEditWicketType e, Emitter<CorrectionState> emit) {
    final s = state;
    if (s is! CorrectionLoaded) return;
    emit(s.copyWith(editWicketType: e.wicketType));
  }

  void _onSetDismissed(SetEditDismissed e, Emitter<CorrectionState> emit) {
    final s = state;
    if (s is! CorrectionLoaded) return;
    emit(s.copyWith(editDismissedId: e.playerId));
  }

  void _onSetNextBatter(SetEditNextBatter e, Emitter<CorrectionState> emit) {
    final s = state;
    if (s is! CorrectionLoaded) return;
    emit(s.copyWith(editNextBatterId: e.playerId));
  }

  void _onSetBatter(SetEditBatter e, Emitter<CorrectionState> emit) {
    final s = state;
    if (s is! CorrectionLoaded) return;
    emit(s.copyWith(editBatterId: e.playerId));
  }

  void _onSetBowler(SetEditBowler e, Emitter<CorrectionState> emit) {
    final s = state;
    if (s is! CorrectionLoaded) return;
    emit(s.copyWith(editBowlerId: e.playerId));
  }

  Future<void> _onSave(SaveEditBall e, Emitter<CorrectionState> emit) async {
    final s = state;
    if (s is! CorrectionLoaded || s.editingBallId == null) return;

    emit(s.copyWith(saving: true));

    final changes = <String, dynamic>{
      'runs': s.editRuns,
      if (s.editExtrasType != null) 'extras_type': s.editExtrasType,
      'is_wicket': s.editIsWicket,
      if (s.editIsWicket) ...{
        'wicket_type': s.editWicketType,
        if (s.editDismissedId != null) 'dismissed_player_id': s.editDismissedId,
        if (s.editNextBatterId != null && s.editNextBatterId!.isNotEmpty)
          'next_batter_id': s.editNextBatterId,
      },
      if (s.editBatterId != null) 'batsman_id': s.editBatterId,
      if (s.editBowlerId != null) 'bowler_id': s.editBowlerId,
    };

    final snapshot = await _repo.editDelivery(
      s.matchId,
      s.editingBallId!,
      changes,
    );

    final deliveries = await _repo.listDeliveries(s.matchId);

    emit(
      s.copyWith(
        deliveries: deliveries,
        editingBallId: null,
        editingDelivery: null,
        saving: false,
        notice: snapshot != null
            ? 'Ball updated — score recomputed.'
            : 'Failed to update ball.',
      ),
    );
  }

  Future<void> _onDelete(DeleteBall e, Emitter<CorrectionState> emit) async {
    final s = state;
    if (s is! CorrectionLoaded) return;

    emit(s.copyWith(saving: true));

    final snapshot = await _repo.deleteDelivery(s.matchId, e.ballId);
    final deliveries = await _repo.listDeliveries(s.matchId);

    emit(
      s.copyWith(
        deliveries: deliveries,
        editingBallId: null,
        editingDelivery: null,
        saving: false,
        notice: snapshot != null
            ? 'Ball deleted — score recomputed.'
            : 'Failed to delete ball.',
      ),
    );
  }

  void _onClearNotice(ClearCorrectionNotice e, Emitter<CorrectionState> emit) {
    final s = state;
    if (s is! CorrectionLoaded) return;
    emit(s.copyWith(notice: null));
  }

  void _onReset(ResetCorrections e, Emitter<CorrectionState> emit) {
    _scoreSub?.cancel();
    _scoreSub = null;
    _matchId = null;
    emit(CorrectionInitial());
  }

  @override
  Future<void> close() {
    _scoreSub?.cancel();
    return super.close();
  }
}
