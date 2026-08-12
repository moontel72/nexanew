// Landing Content BLoC
//
// Unidirectional state machine driving the entire landing page. The page
// renders exclusively from LandingContentLoaded.content — every string,
// feature, tier, and metadata value originates from the JSON asset.

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/landing_content_loader.dart';
import '../../../data/models/landing_content.dart';

sealed class LandingContentState {
  const LandingContentState();
}

final class LandingContentInitial extends LandingContentState {
  const LandingContentInitial();
}

final class LandingContentLoading extends LandingContentState {
  const LandingContentLoading();
}

final class LandingContentLoaded extends LandingContentState {
  final LandingContent content;
  const LandingContentLoaded(this.content);
}

final class LandingContentError extends LandingContentState {
  final String message;
  const LandingContentError(this.message);
}

sealed class LandingContentEvent {
  const LandingContentEvent();
}

final class LoadLandingContent extends LandingContentEvent {
  const LoadLandingContent();
}

final class RetryLoadLandingContent extends LandingContentEvent {
  const RetryLoadLandingContent();
}

class LandingContentBloc
    extends Bloc<LandingContentEvent, LandingContentState> {
  final LandingContentLoader _loader;

  LandingContentBloc({LandingContentLoader? loader})
    : _loader = loader ?? LandingContentLoader(),
      super(const LandingContentInitial()) {
    on<LoadLandingContent>(_onLoad);
    on<RetryLoadLandingContent>(_onLoad);
  }

  Future<void> _onLoad(
    LandingContentEvent event,
    Emitter<LandingContentState> emit,
  ) async {
    emit(const LandingContentLoading());
    try {
      final content = await _loader.load();
      emit(LandingContentLoaded(content));
    } catch (e) {
      emit(LandingContentError(e.toString()));
    }
  }
}
