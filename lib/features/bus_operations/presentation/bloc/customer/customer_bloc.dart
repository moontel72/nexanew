// Customer Super App Bloc
import 'package:bloc/bloc.dart';
import 'package:trace_odd/core/services/api_service.dart';
import 'customer_event.dart';
import 'customer_state.dart';

class CustomerBloc extends Bloc<CustomerEvent, CustomerState> {
  CustomerBloc() : super(const CustomerState()) {
    on<LoadPublishedLayouts>(_onLoad);
    on<SwitchTab>(_onSwitch);
  }

  Future<void> _onLoad(
    LoadPublishedLayouts e,
    Emitter<CustomerState> emit,
  ) async {
    emit(state.copyWith(status: CustomerStatus.loading));
    try {
      final r = await ApiService().get('/bus-fleet/absolute-layouts/public');
      final d = r?['data'];
      List<Map<String, dynamic>> list = d is List
          ? d.cast<Map<String, dynamic>>()
          : [];
      emit(
        state.copyWith(status: CustomerStatus.loaded, publishedLayouts: list),
      );
    } catch (ex) {
      emit(state.copyWith(status: CustomerStatus.error, error: ex.toString()));
    }
  }

  void _onSwitch(SwitchTab e, Emitter<CustomerState> emit) =>
      emit(state.copyWith(selectedTab: e.index));
}
