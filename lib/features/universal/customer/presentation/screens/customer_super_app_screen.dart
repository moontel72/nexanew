// Customer Super-App Dashboard Screen — NexaTrace Module 8 + 25.
//
// Single-screen "super-app" assembling the four customer-facing journeys:
//   1. Product Authenticity Scan (Module 8 — QR/SHA256 Rust-FFI verify)
//   2. Transit Search & Live Bus Tracking (Module 25 — bus_fleet_gps stream)
//   3. Bus Seat Booking (Module 25 — seat grid + booking)
//   4. Fleet Auction Bid (Module 26 — truck-load bidding)
//
// Branded via BrandingConfig.forPanel(UserPanel.customer).  All state flows
// through CustomerSuperAppBloc, with the WebSocketHub.busFleetGps stream
// auto-bound inside the bloc constructor.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:trace_odd/core/navigation/panel_routes.dart';
import 'package:trace_odd/core/services/hardware_scan_service.dart';
import 'package:trace_odd/core/theme/branding_config.dart';
import 'package:trace_odd/features/universal/customer/presentation/bloc/customer_super_app_bloc.dart';
import 'package:trace_odd/features/universal/customer/presentation/bloc/customer_super_app_event.dart';
import 'package:trace_odd/features/universal/customer/presentation/bloc/customer_super_app_state.dart';
import 'package:trace_odd/features/universal/customer/presentation/widgets/authenticity_verification_card.dart';
import 'package:trace_odd/features/universal/customer/presentation/widgets/live_bus_transit_tracker_card.dart';
import 'package:trace_odd/features/universal/customer/presentation/widgets/seat_selection_grid_widget.dart';
import 'package:trace_odd/shared/theme/colors.dart';
import 'package:trace_odd/shared/widgets/buttons/primary_button.dart';

class CustomerSuperAppScreen extends StatelessWidget {
  const CustomerSuperAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CustomerSuperAppBloc(scanService: HardwareScanService()),
      child: const _CustomerSuperAppView(),
    );
  }
}

class _CustomerSuperAppView extends StatefulWidget {
  const _CustomerSuperAppView();

  @override
  State<_CustomerSuperAppView> createState() => _CustomerSuperAppViewState();
}

class _CustomerSuperAppViewState extends State<_CustomerSuperAppView> {
  final _originCtrl = TextEditingController();
  final _destinationCtrl = TextEditingController();
  final _bidCtrl = TextEditingController();
  String? _selectedRouteId;

  @override
  void dispose() {
    _originCtrl.dispose();
    _destinationCtrl.dispose();
    _bidCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brand = BrandingConfig.forPanel(UserPanel.customer);
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.gray100,
      appBar: AppBar(
        backgroundColor: brand.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Icon(brand.fallbackIcon, size: 22.sp),
            Gap(8.w),
            Text(
              brand.enterpriseTitle,
              style: tt.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            tooltip: 'Profile',
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: BlocBuilder<CustomerSuperAppBloc, CustomerSuperAppState>(
        builder: (context, state) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(14.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _sectionTitle('Product Authenticity', Icons.verified, brand, tt),
                Gap(8.h),
                AuthenticityVerificationCard(
                  isAuthentic: state.lastScanAuthentic,
                  serialNumber: state.lastScannedSerial,
                  rewardPoints: state.rewardPoints,
                  totalScans: state.totalScans,
                ),
                Gap(10.h),
                PrimaryButton(
                  text: 'Scan Product QR',
                  icon: Icons.qr_code_scanner,
                  backgroundColor: brand.primaryColor,
                  onPressed: () => _onScanPressed(context),
                ),

                Gap(20.h),
                _sectionTitle(
                  'Bus Transit Search',
                  Icons.directions_bus,
                  brand,
                  tt,
                ),
                Gap(8.h),
                _transitSearchCard(context, brand, tt),

                if (state.transitRoutes.isNotEmpty) ...[
                  Gap(12.h),
                  ...state.transitRoutes.map(
                    (r) => _routeTile(context, r, brand, tt),
                  ),
                ],

                if (state.liveBusFrame != null) ...[
                  Gap(20.h),
                  _sectionTitle(
                    'Live Bus Tracker',
                    Icons.gps_fixed,
                    brand,
                    tt,
                  ),
                  Gap(8.h),
                  LiveBusTransitTrackerCard(
                    operatorName: state.liveBusFrame!['operator'] as String?,
                    driverName: state.liveBusFrame!['driver'] as String?,
                    nextStop: state.liveBusFrame!['next_stop'] as String?,
                    etaMinutes: state.liveBusFrame!['eta_minutes'] as int?,
                    progressPercent: (state.liveBusFrame!['progress'] as num?)
                        ?.toDouble(),
                    speedKmph: (state.liveBusFrame!['speed_kmph'] as num?)
                        ?.toDouble(),
                  ),
                ],

                if (_selectedRouteId != null && state.seatMatrix.isNotEmpty) ...[
                  Gap(20.h),
                  _sectionTitle(
                    'Choose Your Seats',
                    Icons.event_seat,
                    brand,
                    tt,
                  ),
                  Gap(8.h),
                  SeatSelectionGridWidget(
                    seatMatrix: state.seatMatrix,
                    seatPrice: state.seatPrice,
                    onSeatTap: (idx) =>
                        context.read<CustomerSuperAppBloc>().add(
                          SeatToggled(idx),
                        ),
                  ),
                  Gap(10.h),
                  PrimaryButton(
                    text:
                        'Confirm ${state.selectedSeatCount} '
                        'Seat${state.selectedSeatCount == 1 ? '' : 's'} '
                        '— Rs. ${(state.selectedSeatCount * state.seatPrice).toInt()}',
                    backgroundColor: brand.primaryColor,
                    isEnabled: state.selectedSeatCount > 0,
                    onPressed: () => _onBookSeats(context, state),
                  ),
                ],

                Gap(20.h),
                _sectionTitle(
                  'Truck Fleet Bidding',
                  Icons.local_shipping,
                  brand,
                  tt,
                ),
                Gap(8.h),
                _fleetBidCard(context, state, brand, tt),

                Gap(40.h),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Section helpers ──────────────────────────────────────────

  Widget _sectionTitle(
    String label,
    IconData icon,
    BrandProfile brand,
    TextTheme tt,
  ) => Row(
    children: [
      Icon(icon, size: 18.sp, color: brand.primaryColor),
      Gap(6.w),
      Text(
        label,
        style: tt.titleSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.gray800,
        ),
      ),
    ],
  );

  Widget _transitSearchCard(
    BuildContext context,
    BrandProfile brand,
    TextTheme tt,
  ) => Container(
    padding: EdgeInsets.all(12.w),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12.r),
      border: Border.all(color: AppColors.gray200),
    ),
    child: Column(
      children: [
        TextField(
          controller: _originCtrl,
          decoration: InputDecoration(
            labelText: 'From',
            prefixIcon: const Icon(Icons.my_location),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            isDense: true,
          ),
        ),
        Gap(8.h),
        TextField(
          controller: _destinationCtrl,
          decoration: InputDecoration(
            labelText: 'To',
            prefixIcon: const Icon(Icons.location_on_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            isDense: true,
          ),
        ),
        Gap(10.h),
        PrimaryButton(
          text: 'Search Buses',
          icon: Icons.search,
          backgroundColor: brand.primaryColor,
          onPressed: () => _onTransitSearch(context),
        ),
      ],
    ),
  );

  Widget _routeTile(
    BuildContext context,
    Map<String, dynamic> route,
    BrandProfile brand,
    TextTheme tt,
  ) {
    final isSelected = _selectedRouteId == route['id'];
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: InkWell(
        onTap: () => setState(() => _selectedRouteId = route['id'] as String),
        borderRadius: BorderRadius.circular(10.r),
        child: Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: isSelected
                ? brand.primaryColor.withValues(alpha: 0.08)
                : Colors.white,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
              color: isSelected ? brand.primaryColor : AppColors.gray200,
              width: isSelected ? 1.6 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.directions_bus,
                size: 22.sp,
                color: brand.primaryColor,
              ),
              Gap(10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      route['operator'] as String,
                      style: tt.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${route['origin']} → ${route['destination']} • '
                      '${route['departure']}',
                      style: tt.bodySmall?.copyWith(color: AppColors.gray600),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Rs. ${route['price']}',
                    style: tt.titleSmall?.copyWith(
                      color: brand.primaryColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    '${route['seats']} seats',
                    style: tt.labelSmall?.copyWith(color: AppColors.gray500),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fleetBidCard(
    BuildContext context,
    CustomerSuperAppState state,
    BrandProfile brand,
    TextTheme tt,
  ) => Container(
    padding: EdgeInsets.all(12.w),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12.r),
      border: Border.all(color: AppColors.gray200),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Post your load and let truck operators bid in real time.',
          style: tt.bodySmall?.copyWith(color: AppColors.gray600),
        ),
        Gap(10.h),
        TextField(
          controller: _bidCtrl,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Your reserve price (PKR)',
            prefixIcon: const Icon(Icons.attach_money),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            isDense: true,
          ),
        ),
        Gap(10.h),
        PrimaryButton(
          text: state.isBidding ? 'Posting bid…' : 'Post Auction',
          icon: Icons.gavel,
          backgroundColor: brand.primaryColor,
          isLoading: state.isBidding,
          isEnabled: !state.isBidding,
          onPressed: () => _onPostBid(context),
        ),
        if (state.lastBidAmount != null && !state.isBidding) ...[
          Gap(8.h),
          Text(
            'Last bid posted: Rs. ${state.lastBidAmount!.toInt()}',
            style: tt.labelSmall?.copyWith(color: AppColors.success),
          ),
        ],
      ],
    ),
  );

  // ── Event handlers ───────────────────────────────────────────

  void _onScanPressed(BuildContext context) {
    // In production, this opens a camera scanner sheet which feeds raw
    // payloads to HardwareScanService.processPayload().  Here we trigger
    // a synthetic success event so the dashboard remains demo-runnable.
    final bloc = context.read<CustomerSuperAppBloc>();
    bloc.add(
      CustomerScanVerified(
        result: ScanResult(
          rawPayload: 'DEMO-${DateTime.now().millisecondsSinceEpoch}',
          type: ScanPayloadType.cryptoSHA256,
          scannedAt: DateTime.now(),
          scanUuid: 'demo-uuid',
        ),
        isAuthentic: true,
      ),
    );
  }

  void _onTransitSearch(BuildContext context) {
    final origin = _originCtrl.text.trim();
    final destination = _destinationCtrl.text.trim();
    if (origin.isEmpty || destination.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter both origin and destination')),
      );
      return;
    }
    setState(() => _selectedRouteId = null);
    context.read<CustomerSuperAppBloc>().add(
      TransitSearchRequested(origin: origin, destination: destination),
    );
  }

  void _onBookSeats(BuildContext context, CustomerSuperAppState state) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Booking ${state.selectedSeatCount} seat(s) on route '
          '${_selectedRouteId ?? "—"}',
        ),
      ),
    );
    // In production: dispatch SeatBookingSubmitted event → POST
    // /api/v1/consumer/bus/booking with client_uuid idempotency token.
  }

  void _onPostBid(BuildContext context) {
    final raw = _bidCtrl.text.trim();
    final amount = double.tryParse(raw);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid bid amount')),
      );
      return;
    }
    context.read<CustomerSuperAppBloc>().add(
      FleetBidPlaced(
        loadId: 'LOAD-${DateTime.now().millisecondsSinceEpoch}',
        amount: amount,
      ),
    );
    _bidCtrl.clear();
  }
}
