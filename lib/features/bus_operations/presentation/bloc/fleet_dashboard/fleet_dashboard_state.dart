// Fleet Dashboard State — immutable states for bus-fleet panel dashboard
import 'package:equatable/equatable.dart';

enum FleetDashboardStatus { initial, loading, loaded, error }

class FleetDashboardState extends Equatable {
  final FleetDashboardStatus status;
  final String ownerName, companyId, currentPage;
  final int driverCount, conductorCount, layoutCount;
  final List<Map<String, dynamic>> drivers, conductors, layouts;
  final bool driversLoading, conductorsLoading, layoutsLoading;
  final String? errorMessage;
  final bool isStaffSubmitting, isLayoutMutating;
  final String? staffActionError, layoutActionError;

  // ── Carrier link ──
  final List<Map<String, dynamic>> incomingRequests, linkedCarriers;
  final bool linkLoading;
  final String? linkActionError;

  // ── Chat inbox ──
  final List<Map<String, dynamic>> inboxConversations, activeChatMessages;
  final bool inboxLoading, chatSending;
  final String? expandedConversationId;
  final String? chatError;

  const FleetDashboardState({
    this.status = FleetDashboardStatus.initial,
    this.ownerName = 'Fleet',
    this.companyId = '',
    this.currentPage = 'dashboard',
    this.driverCount = 0,
    this.conductorCount = 0,
    this.layoutCount = 0,
    this.drivers = const [],
    this.conductors = const [],
    this.layouts = const [],
    this.driversLoading = true,
    this.conductorsLoading = true,
    this.layoutsLoading = true,
    this.errorMessage,
    this.isStaffSubmitting = false,
    this.staffActionError,
    this.isLayoutMutating = false,
    this.layoutActionError,
    this.incomingRequests = const [],
    this.linkedCarriers = const [],
    this.linkLoading = false,
    this.linkActionError,
    this.inboxConversations = const [],
    this.activeChatMessages = const [],
    this.inboxLoading = false,
    this.chatSending = false,
    this.expandedConversationId,
    this.chatError,
  });

  FleetDashboardState copyWith({
    FleetDashboardStatus? status,
    String? ownerName,
    String? companyId,
    String? currentPage,
    int? driverCount,
    int? conductorCount,
    int? layoutCount,
    List<Map<String, dynamic>>? drivers,
    List<Map<String, dynamic>>? conductors,
    List<Map<String, dynamic>>? layouts,
    bool? driversLoading,
    bool? conductorsLoading,
    bool? layoutsLoading,
    String? errorMessage,
    bool? isStaffSubmitting,
    String? staffActionError,
    bool? isLayoutMutating,
    String? layoutActionError,
    List<Map<String, dynamic>>? incomingRequests,
    List<Map<String, dynamic>>? linkedCarriers,
    bool? linkLoading,
    String? linkActionError,
    List<Map<String, dynamic>>? inboxConversations,
    List<Map<String, dynamic>>? activeChatMessages,
    bool? inboxLoading,
    bool? chatSending,
    String? expandedConversationId,
    String? chatError,
  }) {
    return FleetDashboardState(
      status: status ?? this.status,
      ownerName: ownerName ?? this.ownerName,
      companyId: companyId ?? this.companyId,
      currentPage: currentPage ?? this.currentPage,
      driverCount: driverCount ?? this.driverCount,
      conductorCount: conductorCount ?? this.conductorCount,
      layoutCount: layoutCount ?? this.layoutCount,
      drivers: drivers ?? this.drivers,
      conductors: conductors ?? this.conductors,
      layouts: layouts ?? this.layouts,
      driversLoading: driversLoading ?? this.driversLoading,
      conductorsLoading: conductorsLoading ?? this.conductorsLoading,
      layoutsLoading: layoutsLoading ?? this.layoutsLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      isStaffSubmitting: isStaffSubmitting ?? this.isStaffSubmitting,
      staffActionError: staffActionError,
      isLayoutMutating: isLayoutMutating ?? this.isLayoutMutating,
      layoutActionError: layoutActionError,
      incomingRequests: incomingRequests ?? this.incomingRequests,
      linkedCarriers: linkedCarriers ?? this.linkedCarriers,
      linkLoading: linkLoading ?? this.linkLoading,
      linkActionError: linkActionError,
      inboxConversations: inboxConversations ?? this.inboxConversations,
      activeChatMessages: activeChatMessages ?? this.activeChatMessages,
      inboxLoading: inboxLoading ?? this.inboxLoading,
      chatSending: chatSending ?? this.chatSending,
      expandedConversationId:
          expandedConversationId ?? this.expandedConversationId,
      chatError: chatError,
    );
  }

  @override
  List<Object?> get props => [
    status,
    ownerName,
    companyId,
    currentPage,
    driverCount,
    conductorCount,
    layoutCount,
    drivers,
    conductors,
    layouts,
    driversLoading,
    conductorsLoading,
    layoutsLoading,
    errorMessage,
    isStaffSubmitting,
    staffActionError,
    isLayoutMutating,
    layoutActionError,
    incomingRequests,
    linkedCarriers,
    linkLoading,
    linkActionError,
    inboxConversations,
    activeChatMessages,
    inboxLoading,
    chatSending,
    expandedConversationId,
    chatError,
  ];
}
