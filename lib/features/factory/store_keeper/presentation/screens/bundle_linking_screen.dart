import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:nexatrace_system/core/services/api_service.dart';
import 'package:nexatrace_system/features/factory/store_keeper/presentation/bloc/store_keeper_bloc.dart';
import 'package:nexatrace_system/shared/theme/colors.dart';
import 'package:nexatrace_system/shared/theme/text_styles.dart';
import 'package:nexatrace_system/shared/widgets/buttons/primary_button.dart';

class BundleLinkingScreen extends StatefulWidget {
  final String bundleId;

  const BundleLinkingScreen({super.key, required this.bundleId});

  @override
  State<BundleLinkingScreen> createState() => _BundleLinkingScreenState();
}

class _BundleLinkingScreenState extends State<BundleLinkingScreen> {
  final ApiService _apiService = ApiService();

  bool _isLoading = true;
  Map<String, dynamic>? _bundleInfo;
  bool _qrGenerated = false;
  String? _qrData;
  bool _isGeneratingQr = false;
  int _linkedCartons = 0;
  int _linkedPackets = 0;
  int _linkedUnits = 0;
  int _totalCartons = 0;
  int _totalPackets = 0;
  int _totalUnits = 0;

  @override
  void initState() {
    super.initState();
    _fetchBundleInfo();
  }

  Future<void> _fetchBundleInfo() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.get(
        '/api/factory/store-keeper-bundles/${widget.bundleId}',
      );
      if (mounted) {
        setState(() {
          _bundleInfo = response is Map<String, dynamic>
              ? response
              : (response['data'] is Map<String, dynamic>
                    ? response['data']
                    : <String, dynamic>{});
          _linkedCartons =
              _parseInt(_bundleInfo?['linked_cartons']) ??
              _parseInt(_bundleInfo?['linked_cartons_count']) ??
              0;
          _linkedPackets =
              _parseInt(_bundleInfo?['linked_packets']) ??
              _parseInt(_bundleInfo?['linked_packets_count']) ??
              0;
          _linkedUnits =
              _parseInt(_bundleInfo?['linked_units']) ??
              _parseInt(_bundleInfo?['linked_units_count']) ??
              0;
          _totalCartons =
              _parseInt(_bundleInfo?['total_cartons']) ??
              _parseInt(_bundleInfo?['expected_cartons']) ??
              0;
          _totalPackets =
              _parseInt(_bundleInfo?['total_packets']) ??
              _parseInt(_bundleInfo?['expected_packets']) ??
              0;
          _totalUnits =
              _parseInt(_bundleInfo?['total_units']) ??
              _parseInt(_bundleInfo?['expected_units']) ??
              0;
          _qrGenerated =
              _bundleInfo?['qr_generated'] == true ||
              _bundleInfo?['qr_code'] != null;
          _qrData =
              _bundleInfo?['qr_code']?.toString() ??
              _bundleInfo?['qr_data']?.toString();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load bundle info: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  Future<void> _generateQr() async {
    setState(() => _isGeneratingQr = true);
    try {
      final response = await _apiService.post(
        '/api/factory/store-keeper-bundles/${widget.bundleId}/generate-qr',
      );
      if (mounted) {
        final data = response is Map<String, dynamic>
            ? response
            : (response['data'] is Map<String, dynamic>
                  ? response['data']
                  : <String, dynamic>{});
        setState(() {
          _qrGenerated = true;
          _qrData =
              data['qr_code']?.toString() ??
              data['qr_data']?.toString() ??
              _bundleInfo?['bundle_code']?.toString();
          _isGeneratingQr = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Bundle QR generated successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isGeneratingQr = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate QR: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _openScanner({
    required String label,
    required String linkType,
  }) async {
    final result = await context.push<String>('/factory/store-keeper/scanner');

    if (result == null || result.isEmpty || !mounted) return;

    _linkScannedCode(result, linkType);
  }

  Future<void> _linkScannedCode(String code, String linkType) async {
    try {
      final endpoint = _endpointForType(linkType);
      final body = _bodyForType(linkType, code);

      await _apiService.post(endpoint, body: body);

      if (mounted) {
        setState(() {
          switch (linkType) {
            case 'carton':
              _linkedCartons++;
              break;
            case 'packet':
              _linkedPackets++;
              break;
            case 'unit':
              _linkedUnits++;
              break;
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${linkType.toUpperCase()} linked successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to link $linkType: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  String _endpointForType(String linkType) {
    switch (linkType) {
      case 'carton':
        return '/api/factory/codes/carton/link';
      case 'packet':
        return '/api/factory/codes/packet/link';
      case 'unit':
        return '/api/factory/codes/aggregation/link-units';
      default:
        return '/api/factory/store-keepers/scan';
    }
  }

  Map<String, dynamic> _bodyForType(String linkType, String code) {
    switch (linkType) {
      case 'carton':
        return {'bundle_id': widget.bundleId, 'carton_id': code};
      case 'packet':
        return {'carton_id': code, 'packet_id': code};
      case 'unit':
        return {
          'packet_id': widget.bundleId,
          'unit_id': code,
          'product_id': '',
          'quantity': 1,
        };
      default:
        return {'code': code};
    }
  }

  bool get _hasMissingItems =>
      _linkedCartons < _totalCartons ||
      _linkedPackets < _totalPackets ||
      _linkedUnits < _totalUnits;

  @override
  Widget build(BuildContext context) {
    final bundleCode = _bundleInfo?['bundle_code']?.toString() ?? 'Loading...';
    final orderRef = _bundleInfo?['order_reference']?.toString() ?? '---';

    return Scaffold(
      appBar: AppBar(
        title: Text('Bundle: $bundleCode'),
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        leading: IconButton(icon: const Icon(Icons.home), onPressed: () => context.go('/factory/store-keeper/dashboard')),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchBundleInfo,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Section 1: Bundle Info Card ──
                    _buildBundleInfoCard(bundleCode, orderRef),
                    Gap(16.h),

                    // ── Section 2: Generate QR ──
                    _buildGenerateQrSection(),
                    Gap(16.h),

                    // ── Section 3: QR Data & Scan Buttons ──
                    if (_qrGenerated) ...[
                      _buildQrDataSection(),
                      Gap(16.h),
                      _buildScanButtonsSection(),
                      Gap(16.h),
                    ],

                    // ── Section 4: Summary Card ──
                    _buildSummaryCard(),
                    Gap(16.h),

                    // ── Missing Items Alert ──
                    if (_hasMissingItems) _buildMissingAlert(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildBundleInfoCard(String bundleCode, String orderRef) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.inventory_2, color: AppColors.accent, size: 24.w),
                Gap(8.w),
                Text('Bundle Information', style: TextStyles.heading6),
              ],
            ),
            Gap(12.h),
            _infoRow('Order Reference', orderRef),
            _infoRow('Bundle Code', bundleCode),
            _infoRow('Linked Cartons', '$_linkedCartons / $_totalCartons'),
            _infoRow('Linked Packets', '$_linkedPackets / $_totalPackets'),
            _infoRow('Linked Units', '$_linkedUnits / $_totalUnits'),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenerateQrSection() {
    if (_qrGenerated) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.qr_code, color: AppColors.accent, size: 24.w),
                Gap(8.w),
                Text('Generate Bundle QR', style: TextStyles.heading6),
              ],
            ),
            Gap(12.h),
            Text(
              'Generate a QR code for this bundle to enable scanning and linking of cartons, packets, and units.',
              style: TextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            Gap(12.h),
            PrimaryButton(
              text: _isGeneratingQr ? 'Generating...' : 'Generate Bundle QR',
              onPressed: () { _generateQr(); },
              isEnabled: !_isGeneratingQr,
              backgroundColor: AppColors.accent,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQrDataSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.qr_code_2, color: AppColors.success, size: 24.w),
                Gap(8.w),
                Text('Bundle QR Code', style: TextStyles.heading6),
              ],
            ),
            Gap(12.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.codeBackground,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                _qrData ?? 'QR data not available',
                style: TextStyles.bodySmall.copyWith(
                  fontFamily: 'monospace',
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Gap(8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, color: AppColors.success, size: 16.w),
                Gap(4.w),
                Text(
                  'QR Ready — scan items below',
                  style: TextStyles.caption.copyWith(color: AppColors.success),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanButtonsSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.qr_code_scanner,
                  color: AppColors.accent,
                  size: 24.w,
                ),
                Gap(8.w),
                Text('Scan & Link Items', style: TextStyles.heading6),
              ],
            ),
            Gap(16.h),
            PrimaryButton(
              text: 'Scan Carton',
              onPressed: () =>
                  _openScanner(label: 'Scan Carton QR', linkType: 'carton'),
              backgroundColor: AppColors.primary,
              icon: Icons.inventory,
            ),
            Gap(8.h),
            PrimaryButton(
              text: 'Scan Packet',
              onPressed: () =>
                  _openScanner(label: 'Scan Packet QR', linkType: 'packet'),
              backgroundColor: AppColors.secondary,
              icon: Icons.archive,
            ),
            Gap(8.h),
            PrimaryButton(
              text: 'Scan Unit',
              onPressed: () =>
                  _openScanner(label: 'Scan Unit QR', linkType: 'unit'),
              backgroundColor: AppColors.accentDark,
              icon: Icons.circle,
            ),
            Gap(12.h),
            OutlinedButton.icon(
              onPressed: () => context.push(
                '/factory/store-keeper/bundle/${widget.bundleId}/scan',
              ),
              icon: const Icon(Icons.play_circle_outline),
              label: const Text('Guided Scan Flow'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.accent,
                minimumSize: const Size(double.infinity, 48),
                side: const BorderSide(color: AppColors.accent),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    final cartonDiff = _totalCartons - _linkedCartons;
    final packetDiff = _totalPackets - _linkedPackets;
    final unitDiff = _totalUnits - _linkedUnits;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.summarize, color: AppColors.accent, size: 24.w),
                Gap(8.w),
                Text('Linking Summary', style: TextStyles.heading6),
              ],
            ),
            Gap(12.h),
            _summaryTile('Cartons', _linkedCartons, _totalCartons, cartonDiff),
            _summaryTile('Packets', _linkedPackets, _totalPackets, packetDiff),
            _summaryTile('Units', _linkedUnits, _totalUnits, unitDiff),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Linked',
                  style: TextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '${_linkedCartons + _linkedPackets + _linkedUnits} / ${_totalCartons + _totalPackets + _totalUnits}',
                  style: TextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _hasMissingItems
                        ? AppColors.warning
                        : AppColors.success,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryTile(String label, int linked, int total, int remaining) {
    final isComplete = remaining <= 0;
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: isComplete
                  ? AppColors.success.withOpacity(0.1)
                  : AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              isComplete ? Icons.check : Icons.pending,
              size: 18.w,
              color: isComplete ? AppColors.success : AppColors.warning,
            ),
          ),
          Gap(12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyles.captionBold),
                Text(
                  '$linked / $total linked',
                  style: TextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (remaining > 0)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                '$remaining missing',
                style: TextStyles.captionBold.copyWith(
                  color: AppColors.warning,
                ),
              ),
            )
          else
            Icon(Icons.check_circle, color: AppColors.success, size: 20.w),
        ],
      ),
    );
  }

  Widget _buildMissingAlert() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber, color: AppColors.warning, size: 20.w),
          Gap(8.w),
          Expanded(
            child: Text(
              'Some items are still missing. Please scan all required cartons, packets, and units to complete linking.',
              style: TextStyles.caption.copyWith(color: AppColors.warning),
            ),
          ),
        ],
      ),
    );
  }
}
