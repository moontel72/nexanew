import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:nexatrace_system/core/services/api_service.dart';
import 'package:nexatrace_system/features/factory/store_keeper/data/datasources/local_database.dart';
import 'package:nexatrace_system/shared/theme/colors.dart';
import 'package:nexatrace_system/shared/theme/text_styles.dart';
import 'package:nexatrace_system/shared/widgets/buttons/primary_button.dart';

class BundleLinkingScreen extends StatefulWidget {
  final String bundleId;
  final String? initialOrderRef;
  final String? initialBundleCode;

  const BundleLinkingScreen({
    super.key,
    required this.bundleId,
    this.initialOrderRef,
    this.initialBundleCode,
  });

  @override
  State<BundleLinkingScreen> createState() => _BundleLinkingScreenState();
}

class _BundleLinkingScreenState extends State<BundleLinkingScreen> {
  final ApiService _apiService = ApiService();

  bool _isLoading = true;
  Map<String, dynamic>? _bundleInfo;
  // Fallback values shown while the API loads
  late String _orderRefFallback;
  late String _bundleCodeFallback;
  bool _qrGenerated = false;
  String? _qrData;
  bool _isGeneratingQr = false;
  int _linkedCartons = 0;
  int _linkedPackets = 0;
  int _linkedUnits = 0;
  int _totalCartons = 0;
  int _totalPackets = 0;
  int _totalUnits = 0;

  /// IDs of linked cartons/packets (populated from API)
  List<String> _linkedCartonIds = [];
  List<String> _linkedPacketIds = [];

  /// Currently selected packet for unit linking
  String? _selectedPacketId;

  @override
  void initState() {
    super.initState();
    _orderRefFallback = widget.initialOrderRef ?? '---';
    _bundleCodeFallback = widget.initialBundleCode ?? 'Loading...';
    _fetchBundleInfo();
  }

  Future<void> _fetchBundleInfo() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.get(
        '/factory/store-keeper-bundles/${widget.bundleId}/summary',
      );
      if (mounted) {
        // Extract the inner 'data' map — backend wraps responses in
        // { success: true, data: { bundleCode, orderReference, ... } }
        final Map<String, dynamic> data;
        if (response is Map<String, dynamic>) {
          data = (response['data'] is Map<String, dynamic>)
              ? response['data'] as Map<String, dynamic>
              : response;
        } else {
          data = <String, dynamic>{};
        }
        setState(() {
          _bundleInfo = data;
          // Backend returns camelCase keys; Flutter code accesses both
          // camelCase and snake_case for backward compatibility.
          _linkedCartons =
              _parseInt(data['linkedCartonsCount']) ??
              _parseInt(data['linked_cartons_count']) ??
              _parseInt(data['linked_cartons']) ??
              0;
          _linkedPackets =
              _parseInt(data['linkedPacketsCount']) ??
              _parseInt(data['linked_packets_count']) ??
              _parseInt(data['linked_packets']) ??
              0;
          _linkedUnits =
              _parseInt(data['linkedUnitsCount']) ??
              _parseInt(data['linked_units_count']) ??
              _parseInt(data['linked_units']) ??
              0;
          _totalCartons =
              _parseInt(data['totalCartons']) ??
              _parseInt(data['total_cartons']) ??
              _parseInt(data['expected_cartons']) ??
              0;
          _totalPackets =
              _parseInt(data['totalPackets']) ??
              _parseInt(data['total_packets']) ??
              _parseInt(data['expected_packets']) ??
              0;
          _totalUnits =
              _parseInt(data['totalUnits']) ??
              _parseInt(data['total_units']) ??
              _parseInt(data['expected_units']) ??
              0;
          // Parse linked IDs for packet selection & delete UI
          _linkedCartonIds = _parseStringList(data['linkedCartonIds']);
          _linkedPacketIds = _parseStringList(data['linkedPacketIds']);
          // Auto-select first packet if only one is linked
          if (_linkedPacketIds.length == 1) {
            _selectedPacketId = _linkedPacketIds.first;
          }
          // QR is generated when the server has stored bundleQrData
          _qrGenerated =
              data['qr_generated'] == true ||
              data['qr_code'] != null ||
              data['bundleQrData'] != null;
          _qrData =
              data['qr_code']?.toString() ??
              data['qr_data']?.toString() ??
              (data['bundleQrData'] is Map
                  ? (data['bundleQrData'] as Map).values.join('-')
                  : data['bundleQrData']?.toString());
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

  List<String> _parseStringList(dynamic value) {
    if (value is List) return value.map((e) => e.toString()).toList();
    return [];
  }

  Future<void> _generateQr() async {
    setState(() => _isGeneratingQr = true);
    try {
      final response = await _apiService.post(
        '/factory/store-keeper-bundles/${widget.bundleId}/generate-qr',
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

      // Also persist to local DB so counts survive app restart
      await _saveLinkToLocalDb(code, linkType);

      if (mounted) {
        setState(() {
          switch (linkType) {
            case 'carton':
              _linkedCartons++;
              if (!_linkedCartonIds.contains(code)) {
                _linkedCartonIds.add(code);
              }
              break;
            case 'packet':
              _linkedPackets++;
              if (!_linkedPacketIds.contains(code)) {
                _linkedPacketIds.add(code);
              }
              // Auto-select this packet for unit linking
              _selectedPacketId = code;
              break;
            case 'unit':
              _linkedUnits++;
              break;
          }
        });

        // Show success — no longer auto-completes the order.
        // The user must explicitly tap "Finalize & Submit" to move
        // the bundle to store_linked.
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

  /// Finalize the bundle — explicitly mark it as store_linked.
  /// Only callable when no items are missing.
  Future<void> _finalizeBundle() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Finalize Bundle'),
        content: Text(
          'Submit this bundle as complete?\n\n'
          'Cartons: $_linkedCartons / $_totalCartons\n'
          'Packets: $_linkedPackets / $_totalPackets\n'
          'Units: $_linkedUnits / $_totalUnits\n\n'
          'This will move the order to the Admin Panel.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            child: const Text(
              'Finalize & Submit',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await _apiService.put(
        '/factory/store-keeper-bundles/${widget.bundleId}/linking-status',
        body: {'linking_status': 'store_linked'},
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bundle finalized! Moving to Admin Panel.'),
            backgroundColor: AppColors.success,
          ),
        );
        // Refresh to show updated state
        _fetchBundleInfo();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to finalize: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// Persist a successful link to the local database so counts survive
  /// app restart and appear in the Inventory hierarchy view.
  Future<void> _saveLinkToLocalDb(String code, String linkType) async {
    try {
      if (!LocalDatabase().isInitialized) return;
      await LocalDatabase().createRecord(
        code: code,
        codeType: linkType,
        bundleId: widget.bundleId,
      );
    } catch (_) {
      // Local DB save is best-effort; API already succeeded.
    }
  }

  /// Unlink (remove) a previously linked carton or packet.
  Future<void> _unlinkItem(String code, String linkType) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Unlink Item'),
        content: Text(
          'Are you sure you want to unlink this $linkType?\n\nCode: $code',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Unlink'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      final unlinkPath = linkType == 'carton'
          ? '/factory/store-keeper-bundles/${widget.bundleId}/unlink-carton/$code'
          : '/factory/store-keeper-bundles/${widget.bundleId}/unlink-packet/$code';

      await _apiService.delete(unlinkPath);

      if (mounted) {
        setState(() {
          if (linkType == 'carton') {
            _linkedCartons = (_linkedCartons - 1).clamp(0, 999999);
            _linkedCartonIds.remove(code);
          } else {
            _linkedPackets = (_linkedPackets - 1).clamp(0, 999999);
            _linkedPacketIds.remove(code);
            if (_selectedPacketId == code) {
              _selectedPacketId = _linkedPacketIds.isNotEmpty
                  ? _linkedPacketIds.first
                  : null;
            }
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${linkType.toUpperCase()} unlinked'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to unlink: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  String _endpointForType(String linkType) {
    switch (linkType) {
      case 'carton':
        return '/factory/store-keeper-bundles/${widget.bundleId}/link-carton';
      case 'packet':
        return '/factory/store-keeper-bundles/${widget.bundleId}/link-packet';
      case 'unit':
        return '/factory/store-keeper-bundles/${widget.bundleId}/link-unit';
      default:
        return '/factory/store-keeper-bundles/${widget.bundleId}/link-carton';
    }
  }

  Map<String, dynamic> _bodyForType(String linkType, String code) {
    switch (linkType) {
      case 'carton':
        return {'carton_code_id': code};
      case 'packet':
        return {'packet_code_id': code};
      case 'unit':
        // Backend linkUnitToBundle requires packet_code_id.
        // Use the user-selected packet ID from the dropdown.
        return {
          'unit_code_id': code,
          if (_selectedPacketId != null) 'packet_code_id': _selectedPacketId,
        };
      default:
        return {'carton_code_id': code};
    }
  }

  /// Returns true when there are still items to link.
  /// Treats a zero total as "not configured" — the order must have at least
  /// one expected carton/packet/unit before it can be considered complete.
  bool get _hasMissingItems {
    final needCartons = _totalCartons > 0 && _linkedCartons < _totalCartons;
    final needPackets = _totalPackets > 0 && _linkedPackets < _totalPackets;
    final needUnits = _totalUnits > 0 && _linkedUnits < _totalUnits;
    // If totals are all 0 (data not loaded yet), treat as missing.
    if (_totalCartons == 0 && _totalPackets == 0 && _totalUnits == 0) {
      return true;
    }
    return needCartons || needPackets || needUnits;
  }

  @override
  Widget build(BuildContext context) {
    // After _fetchBundleInfo fix, _bundleInfo holds the inner 'data' map
    // with camelCase keys from the backend: bundleCode, orderReference, etc.
    final bundleCode =
        _bundleInfo?['bundleCode']?.toString() ??
        _bundleInfo?['bundle_code']?.toString() ??
        _bundleCodeFallback;
    final orderRef =
        _bundleInfo?['orderReference']?.toString() ??
        _bundleInfo?['order_reference']?.toString() ??
        _orderRefFallback;

    return Scaffold(
      appBar: AppBar(
        title: Text('Bundle: $bundleCode'),
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () => context.go('/factory/store-keeper/dashboard'),
        ),
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

                    // ── Finalize Button ──
                    if (!_hasMissingItems) _buildFinalizeButton(),

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
              onPressed: () {
                _generateQr();
              },
              isEnabled: !_isGeneratingQr,
              backgroundColor: AppColors.accent,
            ),
          ],
        ),
      ),
    );
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied!'),
        duration: const Duration(seconds: 1),
        backgroundColor: AppColors.success,
      ),
    );
  }

  Widget _buildQrDataSection() {
    final qrValue = _qrData ?? 'QR data not available';
    final hasQr = _qrData != null && _qrData!.isNotEmpty;
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
                const Spacer(),
                if (hasQr)
                  IconButton(
                    icon: Icon(Icons.copy, size: 20.w, color: AppColors.accent),
                    tooltip: 'Copy QR data',
                    onPressed: () => _copyToClipboard(qrValue, 'QR data'),
                  ),
              ],
            ),
            Gap(12.h),
            if (hasQr)
              Center(
                child: Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: QrImageView(
                    data: qrValue,
                    version: QrVersions.auto,
                    size: 180.w,
                    gapless: false,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: Color(0xFF1A237E),
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: Color(0xFF1A237E),
                    ),
                  ),
                ),
              ),
            if (hasQr) ...[
              Gap(12.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppColors.codeBackground,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        qrValue,
                        style: TextStyles.bodySmall.copyWith(
                          fontFamily: 'monospace',
                          color: AppColors.textPrimary,
                          fontSize: 11.sp,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Gap(8.w),
                    GestureDetector(
                      onTap: () => _copyToClipboard(qrValue, 'QR data'),
                      child: Icon(
                        Icons.copy,
                        size: 18.w,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
            // ── Packet Selector ──
            if (_linkedPacketIds.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Packet for Units',
                        style: TextStyles.captionBold.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Gap(8.h),
                      DropdownButtonFormField<String>(
                        value: _selectedPacketId,
                        isExpanded: true,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 8.h,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        hint: Text(
                          'Choose a packet...',
                          style: TextStyles.caption.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                        items: _linkedPacketIds.map((id) {
                          final label = id.length > 12
                              ? 'Packet: ${id.substring(0, 12)}...'
                              : 'Packet: $id';
                          return DropdownMenuItem(
                            value: id,
                            child: Text(
                              label,
                              style: TextStyles.caption.copyWith(
                                fontFamily: 'monospace',
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (v) => setState(() => _selectedPacketId = v),
                      ),
                    ],
                  ),
                ),
              ),
            PrimaryButton(
              text: 'Scan Unit',
              onPressed:
                  (_selectedPacketId != null && _selectedPacketId!.isNotEmpty)
                  ? () => _openScanner(label: 'Scan Unit QR', linkType: 'unit')
                  : () {},
              backgroundColor: AppColors.accentDark,
              icon: Icons.circle,
              isEnabled:
                  _selectedPacketId != null && _selectedPacketId!.isNotEmpty,
            ),
            if (_selectedPacketId == null || _selectedPacketId!.isEmpty)
              Padding(
                padding: EdgeInsets.only(top: 4.h),
                child: Text(
                  _linkedPacketIds.isEmpty
                      ? 'Link a Packet first, then select it above.'
                      : 'Please select a Packet first.',
                  style: TextStyles.caption.copyWith(color: AppColors.warning),
                ),
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
            // Show linked carton IDs with delete button
            if (_linkedCartonIds.isNotEmpty)
              ..._linkedCartonIds.map((id) => _linkedIdTile(id, 'carton')),
            _summaryTile('Packets', _linkedPackets, _totalPackets, packetDiff),
            // Show linked packet IDs with delete button
            if (_linkedPacketIds.isNotEmpty)
              ..._linkedPacketIds.map((id) => _linkedIdTile(id, 'packet')),
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

  /// A tile showing a linked item ID with a delete button.
  Widget _linkedIdTile(String id, String type) {
    final shortId = id.length > 16 ? '${id.substring(0, 16)}...' : id;
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h, left: 48.w),
      child: Row(
        children: [
          Icon(
            type == 'carton' ? Icons.inventory : Icons.archive,
            size: 14.w,
            color: AppColors.textTertiary,
          ),
          Gap(6.w),
          Expanded(
            child: Text(
              shortId,
              style: TextStyles.caption.copyWith(
                fontFamily: 'monospace',
                color: AppColors.textSecondary,
                fontSize: 10.sp,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            width: 28.w,
            height: 28.w,
            child: IconButton(
              icon: Icon(
                Icons.delete_outline,
                size: 16.w,
                color: AppColors.error,
              ),
              padding: EdgeInsets.zero,
              tooltip: 'Unlink $type',
              onPressed: () => _unlinkItem(id, type),
            ),
          ),
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

  Widget _buildFinalizeButton() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  color: AppColors.success,
                  size: 24.w,
                ),
                Gap(8.w),
                Expanded(
                  child: Text(
                    'All items linked! Ready to finalize.',
                    style: TextStyles.bodySmall.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            Gap(12.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _finalizeBundle,
                icon: const Icon(Icons.task_alt, color: Colors.white),
                label: const Text(
                  'Finalize & Submit',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
