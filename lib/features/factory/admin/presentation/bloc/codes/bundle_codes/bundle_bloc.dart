import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nexatrace_system/core/services/api_service.dart';
import 'package:nexatrace_system/shared/models/code/bundle_model.dart';

part 'bundle_bloc_event.dart';
part 'bundle_bloc_state.dart';
part 'bundle_bloc.freezed.dart';

class BundleBloc extends Bloc<BundleEvent, BundleState> {
  final ApiService _api = ApiService();

  BundleBloc() : super(const BundleState()) {
    on<LoadBundles>(_onLoadBundles);
    on<CreateBundle>(_onCreateBundle);
    on<ShowBundle>(_onShowBundle);
    on<UpdateBundle>(_onUpdateBundle);
    on<DeleteBundle>(_onDeleteBundle);
    on<ScanBundle>(_onScanBundle);
  }

  Future<void> _onLoadBundles(
    LoadBundles event,
    Emitter<BundleState> emit,
  ) async {
    try {
      emit(state.copyWith(status: BundleStatus.loading));
      final res = await _api.get('/factory/bundles/list');
      final data = res['data'] as Map<String, dynamic>;
      final list = (data['bundles'] as List)
          .map((e) => BundleModel.fromJson(e as Map<String, dynamic>))
          .toList();
      emit(
        state.copyWith(
          status: BundleStatus.loaded,
          bundles: list,
          totalCount: data['total'] as int? ?? list.length,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: BundleStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onCreateBundle(
    CreateBundle event,
    Emitter<BundleState> emit,
  ) async {
    try {
      emit(state.copyWith(status: BundleStatus.creating));
      final res = await _api.post(
        '/factory/bundles/generate',
        body: {
          'order_reference': event.orderReference,
          if (event.cartonCodeIds != null && event.cartonCodeIds!.isNotEmpty)
            'carton_code_ids': event.cartonCodeIds,
          if (event.packetCodeIds != null && event.packetCodeIds!.isNotEmpty)
            'packet_code_ids': event.packetCodeIds,
          if (event.locationStore != null)
            'location_store': event.locationStore,
          if (event.locationShelf != null)
            'location_shelf': event.locationShelf,
          if (event.notes != null) 'notes': event.notes,
        },
      );
      final bundle = BundleModel.fromJson(res['data'] as Map<String, dynamic>);
      emit(
        state.copyWith(status: BundleStatus.created, selectedBundle: bundle),
      );
    } catch (e) {
      emit(
        state.copyWith(status: BundleStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onShowBundle(
    ShowBundle event,
    Emitter<BundleState> emit,
  ) async {
    try {
      final res = await _api.get('/factory/bundles/${event.bundleId}');
      final bundle = BundleModel.fromJson(res['data'] as Map<String, dynamic>);
      emit(state.copyWith(selectedBundle: bundle));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onUpdateBundle(
    UpdateBundle event,
    Emitter<BundleState> emit,
  ) async {
    try {
      final body = <String, dynamic>{};
      if (event.status != null) body['status'] = event.status;
      if (event.locationStore != null)
        body['location_store'] = event.locationStore;
      if (event.locationShelf != null)
        body['location_shelf'] = event.locationShelf;
      if (event.notes != null) body['notes'] = event.notes;
      await _api.put('/factory/bundles/${event.bundleId}', body: body);
      add(const LoadBundles());
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onDeleteBundle(
    DeleteBundle event,
    Emitter<BundleState> emit,
  ) async {
    try {
      emit(state.copyWith(status: BundleStatus.deleting));
      await _api.delete('/factory/bundles/${event.bundleId}');
      emit(state.copyWith(status: BundleStatus.deleted));
      add(const LoadBundles());
    } catch (e) {
      emit(
        state.copyWith(status: BundleStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onScanBundle(
    ScanBundle event,
    Emitter<BundleState> emit,
  ) async {
    try {
      emit(state.copyWith(status: BundleStatus.scanning));
      final res = await _api.get('/factory/bundles/${event.bundleId}/scan');
      final data = res['data'] as Map<String, dynamic>;
      emit(
        state.copyWith(
          status: BundleStatus.scanned,
          scanResult: data['bundleCode'] as String?,
          selectedBundle: BundleModel.fromJson({
            'id': event.bundleId,
            'bundleCode': data['bundleCode'],
            'orderReference': data['orderReference'] ?? '',
            'totalCartons': data['totalCartons'] ?? 0,
            'totalPackets': data['totalPackets'] ?? 0,
            'locationStore': data['locationStore'],
            'locationShelf': data['locationShelf'],
            'status': data['status'] ?? 'draft',
            'createdAt': DateTime.now().toIso8601String(),
          }),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: BundleStatus.error, errorMessage: e.toString()),
      );
    }
  }
}
