import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:trace_odd/features/factory/store_keeper/presentation/bloc/store_keeper_bloc.dart';
import 'package:trace_odd/shared/theme/colors.dart';
import 'package:trace_odd/shared/theme/text_styles.dart';

class OrderSelectionScreen extends StatefulWidget {
  const OrderSelectionScreen({super.key});

  @override
  State<OrderSelectionScreen> createState() => _OrderSelectionScreenState();
}

class _OrderSelectionScreenState extends State<OrderSelectionScreen> {
  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  void _loadOrders() {
    context.read<StoreKeeperBloc>().add(const LoadPendingOrders());
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '---';
    try {
      final dt = DateTime.parse(dateStr);
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} '
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders - Pending Linking'),
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () => context.go('/factory/store-keeper/dashboard'),
        ),
      ),
      body: BlocConsumer<StoreKeeperBloc, StoreKeeperState>(
        listener: (context, state) {
          if (state is ErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is! StoreKeeperAuthenticated) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.amber),
            );
          }
          final orders = state.pendingOrders;

          if (orders.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async => _loadOrders(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 64.w,
                            color: AppColors.gray300,
                          ),
                          Gap(16.h),
                          Text(
                            'No pending orders',
                            style: TextStyles.heading5.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Gap(8.h),
                          Text(
                            'Pull down to refresh',
                            style: TextStyles.bodySmall.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _loadOrders(),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(16.w),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                final orderRef = order['orderReference']?.toString() ?? '---';
                final bundleCode = order['bundleCode']?.toString() ?? '---';
                final createdAt = order['createdAt']?.toString();
                final totalCartons = order['totalCartons']?.toString() ?? '0';
                final totalPackets = order['totalPackets']?.toString() ?? '0';
                final bundleId =
                    order['bundle_id']?.toString() ??
                    order['id']?.toString() ??
                    '';

                return Card(
                  elevation: 2,
                  margin: EdgeInsets.only(bottom: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: InkWell(
                    onTap: () {
                      if (bundleId.isNotEmpty) {
                        // Pass known data as extras so the detail screen can
                        // display orderRef / bundleCode immediately.
                        context.push(
                          '/factory/store-keeper/bundle/$bundleId',
                          extra: <String, String>{
                            'orderRef': orderRef,
                            'bundleCode': bundleCode,
                          },
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(12.r),
                    child: Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  orderRef,
                                  style: TextStyles.heading6.copyWith(
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.accent.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6.r),
                                ),
                                child: Text(
                                  bundleCode,
                                  style: TextStyles.captionBold.copyWith(
                                    color: AppColors.accent,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Gap(12.h),
                          Row(
                            children: [
                              _infoChip(
                                Icons.calendar_today,
                                'Created: ${_formatDate(createdAt)}',
                              ),
                            ],
                          ),
                          Gap(8.h),
                          Row(
                            children: [
                              _infoChip(
                                Icons.inventory,
                                '$totalCartons Cartons',
                              ),
                              Gap(16.w),
                              _infoChip(Icons.archive, '$totalPackets Packets'),
                            ],
                          ),
                          Gap(8.h),
                          Row(
                            children: [
                              const Spacer(),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 14.w,
                                color: AppColors.accent,
                              ),
                              Gap(4.w),
                              Text(
                                'Tap to link',
                                style: TextStyles.caption.copyWith(
                                  color: AppColors.accent,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );

          if (state is StoreKeeperLoggingIn || state is StoreKeeperInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14.w, color: AppColors.textSecondary),
        Gap(4.w),
        Text(
          text,
          style: TextStyles.caption.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
