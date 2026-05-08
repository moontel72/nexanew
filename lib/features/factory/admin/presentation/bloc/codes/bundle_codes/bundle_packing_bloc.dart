import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:nexatrace_system/core/services/api_service.dart';
import 'package:nexatrace_system/shared/models/code/base_code_model.dart';
import 'bundle_packing_event.dart';
import 'bundle_packing_state.dart';

class BundlePackingBloc extends Bloc<BundlePackingEvent, BundlePackingState> {
  final ApiService _api = ApiService();

  BundlePackingBloc() : super(const BundlePackingState()) {
    on<LoadFormats>(_onLoadFormats);
    on<SelectCartonFormat>(_onSelectCartonFormat);
    on<SelectCartonBatch>(_onSelectCartonBatch);
    on<ToggleCartonCode>(_onToggleCartonCode);
    on<SelectPacketFormat>(_onSelectPacketFormat);
    on<SelectPacketBatch>(_onSelectPacketBatch);
    on<TogglePacketCode>(_onTogglePacketCode);
    on<ResetSelection>(_onResetSelection);
  }

  Future<void> _onLoadFormats(
    LoadFormats event,
    Emitter<BundlePackingState> emit,
  ) async {
    emit(state.copyWith(status: BundlePackingStatus.loading));
    final formats = CartonCodeFormat.values
        .map((f) => FormatOption(value: f.value, displayName: f.displayName))
        .toList();
    emit(
      state.copyWith(
        status: BundlePackingStatus.ready,
        cartonFormats: formats,
        packetFormats: formats,
      ),
    );
  }

  Future<void> _onSelectCartonFormat(
    SelectCartonFormat event,
    Emitter<BundlePackingState> emit,
  ) async {
    emit(
      state.copyWith(
        selectedCartonFormat: event.format,
        cartonBatches: [],
        selectedCartonBatch: null,
        cartonCodes: [],
        selectedCartonCodeIds: const {},
      ),
    );
    if (event.format == null) return;
    try {
      final res = await _api.get(
        '/codes/carton/batches',
        queryParams: {'code_format': event.format, 'limit': '100'},
      );
      final data = res['data'] as Map<String, dynamic>;
      final batches = (data['batches'] as List)
          .map(
            (b) => BatchOption(
              batchId: b['batchId'] as String,
              codeFormat: b['codeFormat'] as String,
              codeCount: b['codeCount'] as int,
              isPushed: b['isPushed'] as bool,
            ),
          )
          .where((b) => b.isPushed)
          .toList();
      emit(state.copyWith(cartonBatches: batches));
    } catch (_) {}
  }

  Future<void> _onSelectCartonBatch(
    SelectCartonBatch event,
    Emitter<BundlePackingState> emit,
  ) async {
    emit(
      state.copyWith(
        selectedCartonBatch: event.batch,
        cartonCodes: [],
        selectedCartonCodeIds: const {},
      ),
    );
    if (event.batch == null) return;
    try {
      final res = await _api.get(
        '/codes/carton/list',
        queryParams: {
          'code_format': event.batch!.codeFormat,
          'batch_id': event.batch!.batchId,
          'limit': '200',
        },
      );
      final data = res['data'] as Map<String, dynamic>;
      final codes = (data['carton_codes'] as List)
          .map(
            (c) => CodeOption(
              id: c['id'] as String,
              code: c['code'] as String,
              status: c['status'] as String,
            ),
          )
          .toList();
      emit(state.copyWith(cartonCodes: codes));
    } catch (_) {}
  }

  void _onToggleCartonCode(
    ToggleCartonCode event,
    Emitter<BundlePackingState> emit,
  ) {
    final ids = {...state.selectedCartonCodeIds};
    if (ids.contains(event.codeId)) {
      ids.remove(event.codeId);
    } else {
      ids.add(event.codeId);
    }
    emit(state.copyWith(selectedCartonCodeIds: ids));
  }

  Future<void> _onSelectPacketFormat(
    SelectPacketFormat event,
    Emitter<BundlePackingState> emit,
  ) async {
    emit(
      state.copyWith(
        selectedPacketFormat: event.format,
        packetBatches: [],
        selectedPacketBatch: null,
        packetCodes: [],
        selectedPacketCodeIds: const {},
      ),
    );
    if (event.format == null) return;
    try {
      final res = await _api.get(
        '/codes/packet/batches',
        queryParams: {'code_format': event.format, 'limit': '100'},
      );
      final data = res['data'] as Map<String, dynamic>;
      final batches = (data['batches'] as List)
          .map(
            (b) => BatchOption(
              batchId: b['batchId'] as String,
              codeFormat: b['codeFormat'] as String,
              codeCount: b['codeCount'] as int,
              isPushed: b['isPushed'] as bool,
            ),
          )
          .where((b) => b.isPushed)
          .toList();
      emit(state.copyWith(packetBatches: batches));
    } catch (_) {}
  }

  Future<void> _onSelectPacketBatch(
    SelectPacketBatch event,
    Emitter<BundlePackingState> emit,
  ) async {
    emit(
      state.copyWith(
        selectedPacketBatch: event.batch,
        packetCodes: [],
        selectedPacketCodeIds: const {},
      ),
    );
    if (event.batch == null) return;
    try {
      final res = await _api.get(
        '/codes/packet/list',
        queryParams: {
          'code_format': event.batch!.codeFormat,
          'batch_id': event.batch!.batchId,
          'limit': '200',
        },
      );
      final data = res['data'] as Map<String, dynamic>;
      final codes = (data['packet_codes'] as List)
          .map(
            (c) => CodeOption(
              id: c['id'] as String,
              code: c['code'] as String,
              status: c['status'] as String,
            ),
          )
          .toList();
      emit(state.copyWith(packetCodes: codes));
    } catch (_) {}
  }

  void _onTogglePacketCode(
    TogglePacketCode event,
    Emitter<BundlePackingState> emit,
  ) {
    final ids = {...state.selectedPacketCodeIds};
    if (ids.contains(event.codeId)) {
      ids.remove(event.codeId);
    } else {
      ids.add(event.codeId);
    }
    emit(state.copyWith(selectedPacketCodeIds: ids));
  }

  void _onResetSelection(
    ResetSelection event,
    Emitter<BundlePackingState> emit,
  ) {
    emit(const BundlePackingState());
    add(const LoadFormats());
  }
}
