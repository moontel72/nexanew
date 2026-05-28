import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trace_odd/core/services/api_service.dart';
import 'package:trace_odd/features/factory/store_keeper/data/datasources/local_database.dart';
import 'package:trace_odd/features/factory/store_keeper/data/repositories/store_keeper_repository.dart';
import 'package:trace_odd/features/factory/store_keeper/domain/entities/scan_record.dart';
import 'package:trace_odd/features/factory/store_keeper/domain/usecases/sync_data_usecase.dart';

// ─── Events ─────────────────────────────────────────────
abstract class StoreKeeperEvent extends Equatable {
  const StoreKeeperEvent();
  @override
  List<Object?> get props => [];
}

class StoreKeeperLogin extends StoreKeeperEvent {
  final String email;
  final String password;
  final bool rememberMe;
  const StoreKeeperLogin({
    required this.email,
    required this.password,
    this.rememberMe = false,
  });
  @override
  List<Object?> get props => [email, rememberMe];
}

class StoreKeeperLogout extends StoreKeeperEvent {}

class ScanCode extends StoreKeeperEvent {
  final String code;
  final String? codeType;
  const ScanCode({required this.code, this.codeType});
  @override
  List<Object?> get props => [code, codeType];
}

class LinkBundleToCarton extends StoreKeeperEvent {
  final String bundleId;
  final String cartonId;
  const LinkBundleToCarton({required this.bundleId, required this.cartonId});
  @override
  List<Object?> get props => [bundleId, cartonId];
}

class LinkCartonToPacket extends StoreKeeperEvent {
  final String cartonId;
  final String packetId;
  const LinkCartonToPacket({required this.cartonId, required this.packetId});
  @override
  List<Object?> get props => [cartonId, packetId];
}

class LinkUnitToPacket extends StoreKeeperEvent {
  final String packetId;
  final String unitId;
  final String productId;
  final int quantity;
  const LinkUnitToPacket({
    required this.packetId,
    required this.unitId,
    required this.productId,
    required this.quantity,
  });
  @override
  List<Object?> get props => [packetId, unitId, productId, quantity];
}

class AllocateToRack extends StoreKeeperEvent {
  final String codeId;
  final String rackCode;
  final String sectionName;
  const AllocateToRack({
    required this.codeId,
    required this.rackCode,
    required this.sectionName,
  });
  @override
  List<Object?> get props => [codeId, rackCode, sectionName];
}

class SyncNow extends StoreKeeperEvent {}

class LoadHierarchy extends StoreKeeperEvent {
  final String bundleId;
  const LoadHierarchy({required this.bundleId});
  @override
  List<Object?> get props => [bundleId];
}

class RefreshDashboardStats extends StoreKeeperEvent {}

class ConnectivityChanged extends StoreKeeperEvent {
  final bool isOnline;
  const ConnectivityChanged({required this.isOnline});
  @override
  List<Object?> get props => [isOnline];
}

class LoadPendingOrders extends StoreKeeperEvent {
  const LoadPendingOrders();
}

// ─── States ─────────────────────────────────────────────
abstract class StoreKeeperState extends Equatable {
  const StoreKeeperState();
  @override
  List<Object?> get props => [];
}

class StoreKeeperInitial extends StoreKeeperState {}

class StoreKeeperAuthenticated extends StoreKeeperState {
  final String storeKeeperName;
  final String storeKeeperEmail;
  final String? sessionId;
  final bool isOnline;
  final int todayScans;
  final int pendingSyncs;
  final int linkedItems;
  final String? lastScannedCode;
  final String? lastScannedType;
  final List<Map<String, dynamic>> pendingOrders;

  const StoreKeeperAuthenticated({
    required this.storeKeeperName,
    required this.storeKeeperEmail,
    this.sessionId,
    this.isOnline = true,
    this.todayScans = 0,
    this.pendingSyncs = 0,
    this.linkedItems = 0,
    this.lastScannedCode,
    this.lastScannedType,
    this.pendingOrders = const [],
  });

  StoreKeeperAuthenticated copyWith({
    String? storeKeeperName,
    String? storeKeeperEmail,
    String? sessionId,
    bool? isOnline,
    int? todayScans,
    int? pendingSyncs,
    int? linkedItems,
    String? lastScannedCode,
    String? lastScannedType,
    List<Map<String, dynamic>>? pendingOrders,
  }) {
    return StoreKeeperAuthenticated(
      storeKeeperName: storeKeeperName ?? this.storeKeeperName,
      storeKeeperEmail: storeKeeperEmail ?? this.storeKeeperEmail,
      sessionId: sessionId ?? this.sessionId,
      isOnline: isOnline ?? this.isOnline,
      todayScans: todayScans ?? this.todayScans,
      pendingSyncs: pendingSyncs ?? this.pendingSyncs,
      linkedItems: linkedItems ?? this.linkedItems,
      lastScannedCode: lastScannedCode ?? this.lastScannedCode,
      lastScannedType: lastScannedType ?? this.lastScannedType,
      pendingOrders: pendingOrders ?? this.pendingOrders,
    );
  }

  @override
  List<Object?> get props => [
    storeKeeperName,
    storeKeeperEmail,
    sessionId,
    isOnline,
    todayScans,
    pendingSyncs,
    linkedItems,
    lastScannedCode,
    lastScannedType,
    pendingOrders,
  ];
}

class StoreKeeperLoggingIn extends StoreKeeperState {}

class StoreKeeperUnauthenticated extends StoreKeeperState {
  final String? message;
  const StoreKeeperUnauthenticated({this.message});
  @override
  List<Object?> get props => [message];
}

class LinkingState extends StoreKeeperState {
  final String? currentBundleId;
  final String? currentCartonId;
  final String? currentPacketId;
  final String linkingStep;
  final bool isProcessing;

  const LinkingState({
    this.currentBundleId,
    this.currentCartonId,
    this.currentPacketId,
    this.linkingStep = 'bundle',
    this.isProcessing = false,
  });

  LinkingState copyWith({
    String? currentBundleId,
    String? currentCartonId,
    String? currentPacketId,
    String? linkingStep,
    bool? isProcessing,
  }) {
    return LinkingState(
      currentBundleId: currentBundleId ?? this.currentBundleId,
      currentCartonId: currentCartonId ?? this.currentCartonId,
      currentPacketId: currentPacketId ?? this.currentPacketId,
      linkingStep: linkingStep ?? this.linkingStep,
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }

  @override
  List<Object?> get props => [
    currentBundleId,
    currentCartonId,
    currentPacketId,
    linkingStep,
    isProcessing,
  ];
}

class InventoryState extends StoreKeeperState {
  final HierarchyNode? hierarchy;
  final bool isLoading;
  const InventoryState({this.hierarchy, this.isLoading = false});
  InventoryState copyWith({HierarchyNode? hierarchy, bool? isLoading}) =>
      InventoryState(
        hierarchy: hierarchy ?? this.hierarchy,
        isLoading: isLoading ?? this.isLoading,
      );
  @override
  List<Object?> get props => [hierarchy, isLoading];
}

class SyncingState extends StoreKeeperState {
  final bool isSyncing;
  final SyncResult? lastResult;
  const SyncingState({this.isSyncing = false, this.lastResult});
  SyncingState copyWith({bool? isSyncing, SyncResult? lastResult}) =>
      SyncingState(
        isSyncing: isSyncing ?? this.isSyncing,
        lastResult: lastResult ?? this.lastResult,
      );
  @override
  List<Object?> get props => [isSyncing, lastResult];
}

class ErrorState extends StoreKeeperState {
  final String message;
  final bool isNetworkError;
  const ErrorState({required this.message, this.isNetworkError = false});
  @override
  List<Object?> get props => [message, isNetworkError];
}

// ─── BLoC ───────────────────────────────────────────────
class StoreKeeperBloc extends Bloc<StoreKeeperEvent, StoreKeeperState> {
  final StoreKeeperRepository _repository;
  final ApiService _apiService;
  StreamSubscription? _connectivitySubscription;
  String? _currentSessionId;

  StoreKeeperBloc({
    required StoreKeeperRepository repository,
    ApiService? apiService,
  }) : _repository = repository,
       _apiService = apiService ?? ApiService(),
       super(StoreKeeperInitial()) {
    on<StoreKeeperLogin>(_onLogin);
    on<StoreKeeperLogout>(_onLogout);
    on<ScanCode>(_onScanCode);
    on<LinkBundleToCarton>(_onLinkBundleToCarton);
    on<LinkCartonToPacket>(_onLinkCartonToPacket);
    on<LinkUnitToPacket>(_onLinkUnitToPacket);
    on<AllocateToRack>(_onAllocateToRack);
    on<SyncNow>(_onSyncNow);
    on<LoadHierarchy>(_onLoadHierarchy);
    on<RefreshDashboardStats>(_onRefreshDashboard);
    on<ConnectivityChanged>(_onConnectivityChanged);
    on<LoadPendingOrders>(_onLoadPendingOrders);

    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      results,
    ) {
      final online = !results.contains(ConnectivityResult.none);
      add(ConnectivityChanged(isOnline: online));
      // Only trigger sync if database is already initialized (avoid race with login)
      if (online && LocalDatabase().isInitialized) {
        add(SyncNow());
      }
    });
  }

  @override
  Future<void> close() {
    _connectivitySubscription?.cancel();
    return super.close();
  }

  Future<void> _onLogin(
    StoreKeeperLogin event,
    Emitter<StoreKeeperState> emit,
  ) async {
    emit(StoreKeeperLoggingIn());
    try {
      // Authenticate against the FACTORY guard (not admin).
      // The factory auth endpoint returns: { success, data: { user: {...}, token } }
      final response = await _apiService.post(
        '/factory/auth/store-keeper-login',
        body: {'email': event.email, 'password': event.password},
      );

      // Extract token from factory auth response
      final data = (response is Map<String, dynamic>)
          ? (response['data'] as Map<String, dynamic>?)
          : null;
      final token = data?['token']?.toString();

      if (token == null || token.isEmpty) {
        emit(
          const ErrorState(
            message: 'Login failed: No authentication token received',
          ),
        );
        return;
      }

      // Persist token so _initializeHeaders picks it up for /factory/* routes.
      // _initializeHeaders looks for 'factory_auth_token' first for factory endpoints.
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('factory_auth_token', token);

      // Also store user info if available
      final user = data?['user'] as Map<String, dynamic>?;
      final storeKeeperName =
          user?['name']?.toString() ??
          user?['full_name']?.toString() ??
          event.email.split('@').first;
      final storeKeeperEmail = user?['email']?.toString() ?? event.email;

      String sessionId;
      bool dbOk = false;
      try {
        await LocalDatabase().init();
        sessionId = await LocalDatabase().createSession(
          storeKeeperId: storeKeeperEmail,
        );
        _currentSessionId = sessionId;
        dbOk = true;
      } catch (_) {
        sessionId = 'web-session';
      }

      final online = await Future.any<bool>([
        _repository.isOnline,
        Future<bool>.delayed(const Duration(seconds: 5), () => false),
      ]);

      emit(
        StoreKeeperAuthenticated(
          storeKeeperName: storeKeeperName,
          storeKeeperEmail: storeKeeperEmail,
          sessionId: sessionId,
          isOnline: online,
          todayScans: dbOk ? _repository.getTodayScanCount() : 0,
          pendingSyncs: dbOk ? _repository.getPendingSyncCount() : 0,
          linkedItems: dbOk ? _repository.getLinkedItemsCount() : 0,
        ),
      );
    } catch (e) {
      emit(ErrorState(message: 'Login failed: ' + e.toString()));
    }
  }

  Future<void> _onLogout(
    StoreKeeperLogout event,
    Emitter<StoreKeeperState> emit,
  ) async {
    if (_currentSessionId != null) {
      await LocalDatabase().closeSession(_currentSessionId!);
    }
    _currentSessionId = null;
    // Clear the factory auth token so subsequent logins start fresh.
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('factory_auth_token');
    } catch (_) {}
    emit(const StoreKeeperUnauthenticated());
  }

  Future<void> _onScanCode(
    ScanCode event,
    Emitter<StoreKeeperState> emit,
  ) async {
    // Guard: database must be initialized before scanning
    if (!LocalDatabase().isInitialized) {
      emit(
        const ErrorState(
          message: 'LocalDatabase not initialized. Call init() first.',
        ),
      );
      await Future.delayed(const Duration(seconds: 2));
      if (state is StoreKeeperAuthenticated) emit(state);
      return;
    }
    try {
      await _repository.scanCode(
        event.code,
        codeType: event.codeType,
        sessionId: _currentSessionId,
      );
      if (state is StoreKeeperAuthenticated) {
        final c = state as StoreKeeperAuthenticated;
        emit(
          c.copyWith(
            lastScannedCode: event.code,
            lastScannedType: event.codeType,
            todayScans: _repository.getTodayScanCount(),
          ),
        );
      }
    } catch (e) {
      emit(ErrorState(message: 'Scan failed: $e'));
      await Future.delayed(const Duration(seconds: 2));
      if (state is StoreKeeperAuthenticated) emit(state);
    }
  }

  Future<void> _onLinkBundleToCarton(
    LinkBundleToCarton event,
    Emitter<StoreKeeperState> emit,
  ) async {
    if (state is LinkingState)
      emit((state as LinkingState).copyWith(isProcessing: true));
    else
      emit(
        LinkingState(
          currentBundleId: event.bundleId,
          currentCartonId: event.cartonId,
          linkingStep: 'carton',
          isProcessing: true,
        ),
      );
    await _repository.linkBundleToCarton(event.bundleId, event.cartonId);
    if (state is LinkingState)
      emit(
        (state as LinkingState).copyWith(
          linkingStep: 'packet',
          isProcessing: false,
        ),
      );
  }

  Future<void> _onLinkCartonToPacket(
    LinkCartonToPacket event,
    Emitter<StoreKeeperState> emit,
  ) async {
    if (state is LinkingState)
      emit((state as LinkingState).copyWith(isProcessing: true));
    await _repository.linkCartonToPacket(event.cartonId, event.packetId);
    if (state is LinkingState)
      emit(
        (state as LinkingState).copyWith(
          currentPacketId: event.packetId,
          linkingStep: 'unit',
          isProcessing: false,
        ),
      );
  }

  Future<void> _onLinkUnitToPacket(
    LinkUnitToPacket event,
    Emitter<StoreKeeperState> emit,
  ) async {
    if (state is LinkingState)
      emit((state as LinkingState).copyWith(isProcessing: true));
    await _repository.linkUnitToPacket(
      event.packetId,
      event.unitId,
      event.productId,
      event.quantity,
    );
    if (state is LinkingState)
      emit(
        (state as LinkingState).copyWith(
          linkingStep: 'complete',
          isProcessing: false,
        ),
      );
    if (state is StoreKeeperAuthenticated)
      emit(
        (state as StoreKeeperAuthenticated).copyWith(
          linkedItems: _repository.getLinkedItemsCount(),
        ),
      );
  }

  Future<void> _onAllocateToRack(
    AllocateToRack event,
    Emitter<StoreKeeperState> emit,
  ) async {
    await _repository.allocateToRack(
      event.codeId,
      event.rackCode,
      event.sectionName,
    );
  }

  Future<void> _onSyncNow(SyncNow event, Emitter<StoreKeeperState> emit) async {
    // Guard: database must be initialized before syncing
    if (!LocalDatabase().isInitialized) {
      // Silently skip — sync will retry when connectivity next changes after init
      return;
    }
    final online = await _repository.isOnline;
    if (!online) {
      if (state is StoreKeeperAuthenticated)
        emit((state as StoreKeeperAuthenticated).copyWith(isOnline: false));
      return;
    }
    emit(SyncingState(isSyncing: true));
    try {
      final result = await _repository.syncAll();
      emit(SyncingState(isSyncing: false, lastResult: result));
      if (_currentSessionId != null) {
        final c = state is StoreKeeperAuthenticated
            ? state as StoreKeeperAuthenticated
            : null;
        emit(
          StoreKeeperAuthenticated(
            storeKeeperName: c?.storeKeeperName ?? 'Store Keeper',
            storeKeeperEmail: c?.storeKeeperEmail ?? '',
            sessionId: _currentSessionId,
            isOnline: online,
            todayScans: _repository.getTodayScanCount(),
            pendingSyncs: _repository.getPendingSyncCount(),
            linkedItems: _repository.getLinkedItemsCount(),
          ),
        );
      }
    } catch (e) {
      emit(ErrorState(message: 'Sync failed: $e', isNetworkError: true));
    }
  }

  Future<void> _onLoadHierarchy(
    LoadHierarchy event,
    Emitter<StoreKeeperState> emit,
  ) async {
    emit(InventoryState(isLoading: true));
    try {
      // Try local DB first
      var hierarchy = _repository.getHierarchy(event.bundleId);
      // If local DB has no children, fetch from server as fallback
      if (hierarchy.children.isEmpty) {
        try {
          final response = await _apiService.get(
            '/factory/store-keeper-bundles/${event.bundleId}/summary',
          );
          final data = response is Map<String, dynamic>
              ? (response['data'] is Map<String, dynamic>
                    ? response['data'] as Map<String, dynamic>
                    : response)
              : <String, dynamic>{};
          // Build hierarchy from API response
          final linkedCartonIds =
              (data['linkedCartonIds'] as List<dynamic>?)?.cast<String>() ?? [];
          final linkedPacketIds =
              (data['linkedPacketIds'] as List<dynamic>?)?.cast<String>() ?? [];
          hierarchy = HierarchyNode(
            id: event.bundleId,
            code: data['bundleCode']?.toString() ?? event.bundleId,
            codeType: 'bundle',
            label: 'Bundle: ${data['bundleCode'] ?? event.bundleId}',
            children: [
              if (linkedCartonIds.isNotEmpty)
                HierarchyNode(
                  id: 'cartons',
                  code: '${linkedCartonIds.length} cartons',
                  codeType: 'carton',
                  label: 'Cartons (${linkedCartonIds.length})',
                  children: linkedPacketIds.isNotEmpty
                      ? [
                          HierarchyNode(
                            id: 'packets',
                            code: '${linkedPacketIds.length} packets',
                            codeType: 'packet',
                            label: 'Packets (${linkedPacketIds.length})',
                          ),
                        ]
                      : [],
                ),
            ],
          );
        } catch (_) {
          // Server fetch failed — keep the (possibly empty) local result
        }
      }
      emit(InventoryState(hierarchy: hierarchy));
    } catch (e) {
      emit(ErrorState(message: 'Failed to load hierarchy: $e'));
    }
  }

  Future<void> _onRefreshDashboard(
    RefreshDashboardStats event,
    Emitter<StoreKeeperState> emit,
  ) async {
    if (state is StoreKeeperAuthenticated) {
      final c = state as StoreKeeperAuthenticated;
      emit(
        c.copyWith(
          isOnline: await _repository.isOnline,
          todayScans: _repository.getTodayScanCount(),
          pendingSyncs: _repository.getPendingSyncCount(),
          linkedItems: _repository.getLinkedItemsCount(),
        ),
      );
    }
  }

  void _onConnectivityChanged(
    ConnectivityChanged event,
    Emitter<StoreKeeperState> emit,
  ) {
    if (state is StoreKeeperAuthenticated) {
      emit(
        (state as StoreKeeperAuthenticated).copyWith(isOnline: event.isOnline),
      );
    }
  }

  Future<void> _onLoadPendingOrders(
    LoadPendingOrders event,
    Emitter<StoreKeeperState> emit,
  ) async {
    try {
      final response = await _apiService.get(
        '/factory/store-keeper-bundles/pending',
      );

      // Handle null / empty / varied response shapes gracefully.
      final List<dynamic> data;
      if (response == null) {
        data = [];
      } else if (response is List) {
        data = response;
      } else if (response is Map<String, dynamic>) {
        final d = response['data'];
        if (d is Map<String, dynamic>) {
          data = (d['orders'] as List<dynamic>?) ?? [];
        } else {
          data = (d as List<dynamic>?) ?? [];
        }
      } else {
        data = [];
      }

      final orders = data
          .map<Map<String, dynamic>>(
            (e) => e is Map<String, dynamic> ? e : <String, dynamic>{},
          )
          .toList();

      if (state is StoreKeeperAuthenticated) {
        emit(
          (state as StoreKeeperAuthenticated).copyWith(pendingOrders: orders),
        );
      }
    } catch (e) {
      // Surface errors so auth / network issues aren't hidden.
      // The OrderSelectionScreen listener shows ErrorState in a SnackBar.
      final message = 'Failed to load pending orders: ${e.toString()}';
      final isNetErr =
          e.toString().contains('SocketException') ||
          e.toString().contains('HttpException');
      emit(ErrorState(message: message, isNetworkError: isNetErr));
    }
  }
}
