import 'package:bloc/bloc.dart';
import 'package:nexatrace_system/core/bloc/websocket_bloc_mixin.dart';
import 'package:nexatrace_system/core/crypto/rust_serial_validator.dart';
import 'package:nexatrace_system/core/services/hardware_scan_service.dart';
import 'package:nexatrace_system/core/services/websocket_hub.dart';
import 'package:nexatrace_system/features/universal/customer/presentation/bloc/customer_super_app_event.dart';
import 'package:nexatrace_system/features/universal/customer/presentation/bloc/customer_super_app_state.dart';

class CustomerSuperAppBloc
    extends Bloc<CustomerSuperAppEvent, CustomerSuperAppState>
    with WebSocketBlocMixin<CustomerSuperAppEvent, CustomerSuperAppState> {
  final HardwareScanService _scanService;
  static const int _rewardPerScan = 5;

  CustomerSuperAppBloc({required HardwareScanService scanService})
    : _scanService = scanService,
      super(const CustomerSuperAppState()) {
    on<CustomerScanVerified>(_onScanVerified);
    on<BusTransitUpdateReceived>(_onBusUpdate);
    on<TransitSearchRequested>(_onTransitSearch);
    on<SeatToggled>(_onSeatToggle);
    on<FleetBidPlaced>(_onFleetBid);

    // Auto-bind bus GPS stream from WebSocketHub.
    connectStream(
      WebSocketHub.instance.busFleetGps,
      (wsEvent) => BusTransitUpdateReceived(wsEvent.payload),
    );

    // Bind hardware scan → Rust FFI verification pipeline.
    _scanService.nativeVerifier = (serial) {
      // Offline verification using batch/secret from local cache.
      // In production, these come from the QR payload metadata.
      return RustSerialValidator.verifySerialOnDevice(
        batchId: 'customer-scan-batch',
        secretKey: 'NEXATRACE_CUSTOMER_VERIFY',
        seed: DateTime.now().millisecond,
        candidateHash: serial,
      );
    };
    _scanService.onScanSuccess = (result) {
      final isSha = result.type == ScanPayloadType.cryptoSHA256;
      add(CustomerScanVerified(result: result, isAuthentic: isSha));
    };
  }

  void _onScanVerified(
    CustomerScanVerified event,
    Emitter<CustomerSuperAppState> emit,
  ) {
    final pts = event.isAuthentic
        ? state.rewardPoints + _rewardPerScan
        : state.rewardPoints;
    emit(
      state.copyWith(
        isScanning: false,
        lastScanAuthentic: event.isAuthentic,
        lastScannedSerial: event.result.rawPayload,
        totalScans: state.totalScans + 1,
        rewardPoints: pts,
      ),
    );
  }

  void _onBusUpdate(
    BusTransitUpdateReceived event,
    Emitter<CustomerSuperAppState> emit,
  ) {
    emit(state.copyWith(liveBusFrame: event.payload));
  }

  void _onTransitSearch(
    TransitSearchRequested event,
    Emitter<CustomerSuperAppState> emit,
  ) {
    // Stub: mock routes.  In production, fetch from GET /api/v1/customer/transit/search.
    final routes = <Map<String, dynamic>>[
      {
        'id': 'R1',
        'operator': 'Daewoo Express',
        'origin': event.origin,
        'destination': event.destination,
        'departure': '08:30',
        'price': 1200,
        'seats': 42,
      },
      {
        'id': 'R2',
        'operator': 'Faisal Movers',
        'origin': event.origin,
        'destination': event.destination,
        'departure': '09:15',
        'price': 950,
        'seats': 38,
      },
    ];
    emit(state.copyWith(transitRoutes: routes));
  }

  void _onSeatToggle(SeatToggled event, Emitter<CustomerSuperAppState> emit) {
    if (event.seatIndex < 0 || event.seatIndex >= state.seatMatrix.length) {
      return;
    }
    final matrix = List<int>.from(state.seatMatrix);
    final current = matrix[event.seatIndex];
    if (current == 1) return; // Booked — immutable.
    matrix[event.seatIndex] = current == 2 ? 0 : 2; // Toggle selected.
    final count = matrix.where((s) => s == 2).length;
    emit(state.copyWith(seatMatrix: matrix, selectedSeatCount: count));
  }

  void _onFleetBid(FleetBidPlaced event, Emitter<CustomerSuperAppState> emit) {
    emit(state.copyWith(isBidding: true, lastBidAmount: event.amount));
    // Post bid via API; reset bidding flag after response.
    Future.delayed(const Duration(seconds: 2), () {
      if (!isClosed) emit(state.copyWith(isBidding: false));
    });
  }

  @override
  Future<void> close() {
    _scanService.nativeVerifier = null;
    _scanService.onScanSuccess = null;
    return super.close();
  }
}
