import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nexatrace_system/core/services/api_service.dart';
import 'package:nexatrace_system/features/factory/admin/presentation/bloc/codes/bundle_codes/bundle_bloc.dart';
import 'package:nexatrace_system/features/factory/admin/presentation/bloc/codes/bundle_codes/insights/bundle_insights_bloc.dart';
import 'package:nexatrace_system/features/factory/admin/presentation/screens/codes/bundle_codes/bundle_insights_screen.dart';
import 'package:nexatrace_system/shared/models/code/bundle_model.dart';
import 'package:nexatrace_system/shared/theme/colors.dart';
import 'package:nexatrace_system/shared/widgets/loading/loading_indicator.dart';

/// Order Detail Screen
///
/// Displays full details for a single order (bundle) with two admin actions:
/// - "Manual Link (Admin)" → navigates to the existing BundleInsightsScreen
/// - "Refer to Store Keeper" → sets linking_status to pending_store_linking
///
/// Shows current status, linked item counts, and order metadata.
class OrderDetailScreen extends StatefulWidget {
  final String bundleId;

  const OrderDetailScreen({super.key, required this.bundleId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  BundleModel? _bundle;
  bool _isLoading = false;
  bool _isReferring = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBundle();
  }

  Future<void> _loadBundle() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final res = await ApiService().get('/codes/bundles/${widget.bundleId}');
      final data = res['data'] as Map<String, dynamic>;
      if (mounted) {
        setState(() {
          _bundle = BundleModel.fromJson(data);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'draft':
        return AppColors.warning;
      case 'pending_store_linking':
        return AppColors.accent;
      case 'store_linked':
        return AppColors.info;
      case 'delivered':
        return AppColors.success;
      default:
        return AppColors.textSecondary;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'draft':
        return 'Draft';
      case 'pending_store_linking':
        return 'Pending Linking';
      case 'store_linked':
        return 'Store Linked';
      case 'delivered':
        return 'Delivered';
      default:
        return status;
    }
  }

  Future<void> _referToStoreKeeper() async {
    setState(() => _isReferring = true);
    try {
      await ApiService().put(
        '/factory/store-keeper-bundles/${widget.bundleId}/linking-status',
        body: {'linking_status': 'pending_store_linking'},
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${_bundle?.orderReference ?? 'Order'} sent to Store Keeper',
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      // Refresh the bundle and the global bundle list
      context.read<BundleBloc>().add(const LoadBundles());
      _loadBundle();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isReferring = false);
    }
  }

  void _openBundleInsights() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => BundleInsightsBloc(),
          child: BundleInsightsScreen(bundleId: widget.bundleId),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(_bundle?.orderReference ?? 'Order Detail'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: _buildBody(),
      bottomNavigationBar: _bundle != null ? _buildBottomActions() : null,
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: LoadingIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(
              _error!,
              style: const TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _loadBundle,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_bundle == null) {
      return const Center(child: Text('Order not found'));
    }

    final b = _bundle!;
    final statusColor = _statusColor(b.status);

    return RefreshIndicator(
      onRefresh: _loadBundle,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Status Banner ──
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 12.h),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: statusColor.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Icon(_statusIcon(b.status), color: statusColor, size: 36.sp),
                  SizedBox(height: 6.h),
                  Text(
                    _statusLabel(b.status),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 16.sp,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),

            // ── Order Info Card ──
            _sectionTitle('Order Information'),
            _infoCard([
              _infoRow('Order Reference', b.orderReference),
              _infoRow('Bundle Code', b.bundleCode),
              _infoRow('Status', _statusLabel(b.status)),
              if (b.notes != null && b.notes!.isNotEmpty)
                _infoRow('Notes', b.notes!),
              _infoRow('Created', '${b.createdAt.toLocal()}'.split('.')[0]),
              if (b.packedAt != null)
                _infoRow('Packed', '${b.packedAt!.toLocal()}'.split('.')[0]),
            ]),
            SizedBox(height: 16.h),

            // ── Linked Items Summary ──
            _sectionTitle('Linked Items'),
            Row(
              children: [
                _statCard(
                  'Cartons',
                  b.totalCartons,
                  Icons.all_inbox_outlined,
                  AppColors.info,
                ),
                SizedBox(width: 12.w),
                _statCard(
                  'Packets',
                  b.totalPackets,
                  Icons.inventory_2_outlined,
                  AppColors.accent,
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // ── Linked Items Detail ──
            if (b.items.isNotEmpty) ...[
              _sectionTitle('Contents'),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.all(8.w),
                  itemCount: b.items.length,
                  separatorBuilder: (_, __) =>
                      Divider(height: 1, color: AppColors.border),
                  itemBuilder: (_, i) {
                    final item = b.items[i];
                    final isCarton = item.type == 'carton';
                    return ListTile(
                      dense: true,
                      leading: Icon(
                        isCarton
                            ? Icons.all_inbox_outlined
                            : Icons.inventory_2_outlined,
                        color: isCarton ? AppColors.info : AppColors.accent,
                        size: 20.sp,
                      ),
                      title: Text(
                        isCarton
                            ? 'Carton: ${item.cartonCodeId ?? '-'}'
                            : 'Packet: ${item.packetCodeId ?? '-'}',
                        style: TextStyle(fontSize: 13.sp),
                      ),
                      subtitle: Text(
                        item.type,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ] else ...[
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Center(
                    child: Text(
                      'No cartons or packets linked yet.\nUse "Manual Link" to link items.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 13.sp,
                      ),
                    ),
                  ),
                ),
              ),
            ],
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  /// Bottom action bar with Manual Link and Refer to Store Keeper buttons.
  Widget _buildBottomActions() {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _openBundleInsights,
                icon: Icon(Icons.link, size: 18.sp),
                label: const Text('Manual Link\n(Admin)'),
                style: OutlinedButton.styleFrom(
                  minimumSize: Size(0, 52.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  side: BorderSide(color: AppColors.primary),
                  foregroundColor: AppColors.primary,
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isReferring ? null : _referToStoreKeeper,
                icon: _isReferring
                    ? SizedBox(
                        width: 18.w,
                        height: 18.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.white,
                        ),
                      )
                    : Icon(Icons.person_add_alt, size: 18.sp),
                label: const Text('Refer to\nStore Keeper'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(0, 52.h),
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
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

  // ─── Helper Widgets ─────────────────────────────────────────────

  Widget _sectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _infoCard(List<Widget> rows) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(14.w),
        child: Column(children: rows),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 13.sp, color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String label, int value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        color: color.withOpacity(0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(14.w),
          child: Column(
            children: [
              Icon(icon, color: color, size: 26.sp),
              SizedBox(height: 4.h),
              Text(
                value.toString(),
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'draft':
        return Icons.description_outlined;
      case 'pending_store_linking':
        return Icons.hourglass_empty_outlined;
      case 'store_linked':
        return Icons.link_outlined;
      case 'delivered':
        return Icons.check_circle_outline;
      default:
        return Icons.help_outline;
    }
  }
}
