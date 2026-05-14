import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:nexatrace_system/core/services/api_service.dart';
import 'package:nexatrace_system/shared/theme/colors.dart';
import 'package:nexatrace_system/shared/theme/text_styles.dart';

/// Displays QR images for available Carton / Packet / Unit codes
/// so the Store Keeper can scan them from another device (or screen)
/// to test the linking flow end-to-end.
class QrTestPanelScreen extends StatefulWidget {
  const QrTestPanelScreen({super.key});

  @override
  State<QrTestPanelScreen> createState() => _QrTestPanelScreenState();
}

class _QrTestPanelScreenState extends State<QrTestPanelScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _api = ApiService();

  bool _loading = true;
  String? _error;
  List<_TestCode> _cartons = [];
  List<_TestCode> _packets = [];
  List<_TestCode> _units = [];

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchCodes();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchCodes() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final response = await _api.get(
        '/factory/store-keeper-bundles/test-codes',
        requiresAuth: true,
      );
      final data = (response is Map<String, dynamic>)
          ? (response['data'] as Map<String, dynamic>?)
          : null;

      setState(() {
        _cartons = _parseList(data?['cartons']);
        _packets = _parseList(data?['packets']);
        _units = _parseList(data?['units']);
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  List<_TestCode> _parseList(dynamic list) {
    if (list is! List) return [];
    return list
        .map(
          (j) => _TestCode(
            id: j['id']?.toString() ?? '',
            code: j['code']?.toString() ?? '',
            label: j['label']?.toString() ?? '',
            type: j['type']?.toString() ?? '',
          ),
        )
        .toList();
  }

  void _copyId(String id, String label) {
    Clipboard.setData(ClipboardData(text: id));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label ID copied!'),
        duration: const Duration(seconds: 1),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('QR Test Panel'),
        backgroundColor: Colors.amber.shade700,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/factory/store-keeper/dashboard'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh codes',
            onPressed: _fetchCodes,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(text: 'Cartons (${_cartons.length})'),
            Tab(text: 'Packets (${_packets.length})'),
            Tab(text: 'Units (${_units.length})'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _buildError()
          : TabBarView(
              controller: _tabController,
              children: [
                _buildCodeGrid(_cartons, 'carton', Colors.blue),
                _buildCodeGrid(_packets, 'packet', Colors.orange),
                _buildCodeGrid(_units, 'unit', Colors.green),
              ],
            ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48.w, color: AppColors.error),
            Gap(12.h),
            Text('Failed to load codes', style: TextStyles.heading6),
            Gap(8.h),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            Gap(16.h),
            FilledButton.icon(
              onPressed: _fetchCodes,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCodeGrid(List<_TestCode> codes, String type, Color accent) {
    if (codes.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inventory_2, size: 48.w, color: AppColors.textSecondary),
            Gap(8.h),
            Text(
              'No $type codes found.\nGenerate codes from the Admin Panel first.',
              textAlign: TextAlign.center,
              style: TextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchCodes,
      child: GridView.builder(
        padding: EdgeInsets.all(12.w),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.h,
          childAspectRatio: 0.85,
        ),
        itemCount: codes.length,
        itemBuilder: (context, index) {
          final code = codes[index];
          return _buildQrCard(code, accent);
        },
      ),
    );
  }

  Widget _buildQrCard(_TestCode code, Color accent) {
    // The QR encodes the UUID — this is what the linking endpoints expect
    // as {carton_code_id}, {packet_code_id}, or {unit_code_id}.
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: () => _copyId(code.id, code.label),
        child: Padding(
          padding: EdgeInsets.all(10.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // QR Image
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: QrImageView(
                    data: code.id, // the UUID
                    version: QrVersions.auto,
                    size: 120,
                    gapless: false,
                    eyeStyle: QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: accent,
                    ),
                    dataModuleStyle: QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: accent,
                    ),
                  ),
                ),
              ),
              Gap(6.h),
              // Label
              Text(
                code.label,
                style: TextStyles.captionBold.copyWith(fontSize: 10.sp),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              Gap(2.h),
              // Type badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  code.type.toUpperCase(),
                  style: TextStyle(
                    fontSize: 8.sp,
                    fontWeight: FontWeight.bold,
                    color: accent,
                  ),
                ),
              ),
              Gap(2.h),
              Text(
                'Tap to copy ID',
                style: TextStyle(
                  fontSize: 8.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TestCode {
  final String id;
  final String code;
  final String label;
  final String type;

  const _TestCode({
    required this.id,
    required this.code,
    required this.label,
    required this.type,
  });
}
