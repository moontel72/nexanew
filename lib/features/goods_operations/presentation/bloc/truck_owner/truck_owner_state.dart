// Truck Owner Dashboard State — immutable states
import 'package:equatable/equatable.dart';

enum TruckOwnerStatus { initial, loading, loaded, error }

class TruckOwnerState extends Equatable {
  final TruckOwnerStatus status;
  final String ownerName, companyId, currentPage;
  final int driverCount, conductorCount, vehicleCount, freightLoadCount;
  final List<Map<String, dynamic>> drivers, conductors, vehicles, freightLoads;
  final bool driversLoading, conductorsLoading, vehiclesLoading, freightLoading, isMutating;
  final String? error, actionError;

  // Carrier link
  final Map<String, dynamic>? linkStatus;
  final List<Map<String, dynamic>> availableCompanies;
  final bool linkLoading, companiesLoading;

  // Chat inbox
  final List<Map<String, dynamic>> inboxConversations, activeChatMessages;
  final bool inboxLoading, chatSending;
  final String? expandedConversationId, chatError;

  const TruckOwnerState({
    this.status = TruckOwnerStatus.initial,
    this.ownerName = 'Truck Owner',
    this.companyId = '',
    this.currentPage = 'dashboard',
    this.driverCount = 0,
    this.conductorCount = 0,
    this.vehicleCount = 0,
    this.freightLoadCount = 0,
    this.drivers = const [],
    this.conductors = const [],
    this.vehicles = const [],
    this.freightLoads = const [],
    this.driversLoading = true,
    this.conductorsLoading = true,
    this.vehiclesLoading = true,
    this.freightLoading = true,
    this.isMutating = false,
    this.error,
    this.actionError,
    this.linkStatus,
    this.availableCompanies = const [],
    this.linkLoading = false,
    this.companiesLoading = false,
    this.inboxConversations = const [],
    this.activeChatMessages = const [],
    this.inboxLoading = false,
    this.chatSending = false,
    this.expandedConversationId,
    this.chatError,
  });

  TruckOwnerState copyWith({
    TruckOwnerStatus? status, String? ownerName, String? companyId, String? currentPage,
    int? driverCount, int? conductorCount, int? vehicleCount, int? freightLoadCount,
    List<Map<String, dynamic>>? drivers, List<Map<String, dynamic>>? conductors,
    List<Map<String, dynamic>>? vehicles, List<Map<String, dynamic>>? freightLoads,
    bool? driversLoading, bool? conductorsLoading, bool? vehiclesLoading,
    bool? freightLoading, bool? isMutating, String? error, String? actionError,
    Map<String, dynamic>? linkStatus, List<Map<String, dynamic>>? availableCompanies,
    bool? linkLoading, bool? companiesLoading,
    List<Map<String, dynamic>>? inboxConversations, List<Map<String, dynamic>>? activeChatMessages,
    bool? inboxLoading, bool? chatSending, String? expandedConversationId, String? chatError,
  }) => TruckOwnerState(
    status: status ?? this.status, ownerName: ownerName ?? this.ownerName,
    companyId: companyId ?? this.companyId, currentPage: currentPage ?? this.currentPage,
    driverCount: driverCount ?? this.driverCount, conductorCount: conductorCount ?? this.conductorCount,
    vehicleCount: vehicleCount ?? this.vehicleCount, freightLoadCount: freightLoadCount ?? this.freightLoadCount,
    drivers: drivers ?? this.drivers, conductors: conductors ?? this.conductors,
    vehicles: vehicles ?? this.vehicles, freightLoads: freightLoads ?? this.freightLoads,
    driversLoading: driversLoading ?? this.driversLoading, conductorsLoading: conductorsLoading ?? this.conductorsLoading,
    vehiclesLoading: vehiclesLoading ?? this.vehiclesLoading, freightLoading: freightLoading ?? this.freightLoading,
    isMutating: isMutating ?? this.isMutating, error: error, actionError: actionError,
    linkStatus: linkStatus ?? this.linkStatus, availableCompanies: availableCompanies ?? this.availableCompanies,
    linkLoading: linkLoading ?? this.linkLoading, companiesLoading: companiesLoading ?? this.companiesLoading,
    inboxConversations: inboxConversations ?? this.inboxConversations,
    activeChatMessages: activeChatMessages ?? this.activeChatMessages,
    inboxLoading: inboxLoading ?? this.inboxLoading, chatSending: chatSending ?? this.chatSending,
    expandedConversationId: expandedConversationId ?? this.expandedConversationId, chatError: chatError,
  );

  bool get isLinked => linkStatus?['linked'] == true;

  @override
  List<Object?> get props => [
    status, ownerName, companyId, currentPage,
    driverCount, conductorCount, vehicleCount, freightLoadCount,
    drivers, conductors, vehicles, freightLoads,
    driversLoading, conductorsLoading, vehiclesLoading, freightLoading, isMutating,
    error, actionError, linkStatus, availableCompanies, linkLoading, companiesLoading,
    inboxConversations, activeChatMessages, inboxLoading, chatSending,
    expandedConversationId, chatError,
  ];
}
