part of 'bundle_bloc.dart';

@freezed
abstract class BundleEvent with _$BundleEvent {
  const factory BundleEvent.load() = LoadBundles;
  const factory BundleEvent.create({
    required String orderReference,
    List<String>? cartonCodeIds,
    List<String>? packetCodeIds,
    String? locationStore,
    String? locationShelf,
    String? notes,
  }) = CreateBundle;
  const factory BundleEvent.show(String bundleId) = ShowBundle;
  const factory BundleEvent.update({
    required String bundleId,
    String? status,
    String? locationStore,
    String? locationShelf,
    String? notes,
  }) = UpdateBundle;
  const factory BundleEvent.delete(String bundleId) = DeleteBundle;
  const factory BundleEvent.scan(String bundleId) = ScanBundle;
}
