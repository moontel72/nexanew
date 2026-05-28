import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:trace_odd/core/services/api_service.dart';
import 'package:trace_odd/shared/theme/colors.dart';
import 'package:trace_odd/shared/theme/text_styles.dart';

/// Store Keeper Linking History
///
/// Shows orders finalized by the current user, grouped by
/// Today / Yesterday / Earlier.
class StoreKeeperHistoryScreen extends StatefulWidget {
  const StoreKeeperHistoryScreen({super.key});

  @override
  State<StoreKeeperHistoryScreen> createState() =>
      _StoreKeeperHistoryScreenState();
}

class _StoreKeeperHistoryScreenState extends State<StoreKeeperHistoryScreen> {
  final ApiService _api = ApiService();
  String _selectedPeriod = 'today';
  bool _isLoading = false;
  List<Map<String, dynamic>> _orders = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final response = await _api.get(
        '/factory/store-keeper-bundles/history',
        queryParams: {'period': _selectedPeriod},
      );
      final data = (response is Map<String, dynamic>)
          ? (response['data'] is Map<String, dynamic>
                ? response['data'] as Map<String, dynamic>
                : response)
          : <String, dynamic>{};
      final orders =
          (data['orders'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [];
      if (mounted) {
        setState(() {
          _orders = orders;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Linking History'),
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () => context.go('/factory/store-keeper/dashboard'),
        ),
      ),
      body: Column(
        children: [
          _buildPeriodTabs(),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildPeriodTabs() {
    const periods = [
      ('today', 'Today'),
      ('yesterday', 'Yesterday'),
      ('earlier', 'Earlier'),
    ];
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: periods.map((p) {
          final (value, label) = p;
          final selected = _selectedPeriod == value;
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: ChoiceChip(
              label: Text(label),
              selected: selected,
              onSelected: (_) {
                setState(() => _selectedPeriod = value);
                _fetchHistory();
              },
              selectedColor: AppColors.accent.withOpacity(0.2),
              labelStyle: TextStyle(
                color: selected ? AppColors.accent : AppColors.textSecondary,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 13.sp,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            Gap(12.h),
            Text(_error!, style: TextStyles.bodySmall),
            Gap(12.h),
            ElevatedButton.icon(
              onPressed: _fetchHistory,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    if (_orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history, size: 64.w, color: AppColors.gray300),
            Gap(16.h),
            Text('No orders found', style: TextStyles.heading6),
            Gap(4.h),
            Text(
              'Orders you finalize will appear here.',
              style: TextStyles.caption.copyWith(color: AppColors.textTertiary),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _fetchHistory,
      child: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: _orders.length,
        itemBuilder: (_, i) {
          final o = _orders[i];
          final ref = o['orderReference']?.toString() ?? '---';
          final code = o['bundleCode']?.toString() ?? '';
          final cartons = o['totalCartons']?.toString() ?? '0';
          final packets = o['totalPackets']?.toString() ?? '0';
          final units = o['totalUnits']?.toString() ?? '0';
          final finalized = o['finalizedAt']?.toString() ?? '';
          final time = finalized.length > 16
              ? finalized.substring(11, 16)
              : finalized;

          return Card(
            margin: EdgeInsets.only(bottom: 10.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Padding(
              padding: EdgeInsets.all(14.w),
              child: Row(
                children: [
                  Container(
                    width: 44.w,
                    height: 44.w,
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: const Icon(
                      Icons.check_circle_outline,
                      color: AppColors.success,
                      size: 22,
                    ),
                  ),
                  Gap(12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ref,
                          style: TextStyles.bodySmall.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Gap(4.h),
                        Text(
                          code,
                          style: TextStyles.caption.copyWith(
                            fontFamily: 'monospace',
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Gap(4.h),
                        Text(
                          '$cartons Cartons · $packets Packets · $units Units',
                          style: TextStyles.caption.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    time,
                    style: TextStyles.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
