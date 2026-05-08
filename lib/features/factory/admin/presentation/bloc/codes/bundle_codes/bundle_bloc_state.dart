part of 'bundle_bloc.dart';

enum BundleStatus {
  initial,
  loading,
  loaded,
  creating,
  created,
  deleting,
  deleted,
  scanning,
  scanned,
  error,
}

@freezed
abstract class BundleState with _$BundleState {
  const factory BundleState({
    @Default(BundleStatus.initial) BundleStatus status,
    @Default([]) List<BundleModel> bundles,
    BundleModel? selectedBundle,
    String? errorMessage,
    @Default(0) int totalCount,
    String? scanResult,
  }) = _BundleState;
}
