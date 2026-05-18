import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:nexatrace_system/features/factory/driver/presentation/bloc/driver_bloc.dart';
import 'package:nexatrace_system/features/factory/driver/presentation/widgets/driver_feature_scaffold.dart';
import 'package:nexatrace_system/shared/theme/colors.dart';

class DriverPaymentHistoryScreen extends StatefulWidget {
  const DriverPaymentHistoryScreen({super.key});

  @override
  State<DriverPaymentHistoryScreen> createState() =>
      _DriverPaymentHistoryScreenState();
}

class _DriverPaymentHistoryScreenState
    extends State<DriverPaymentHistoryScreen> {
  String? _activeFilter;

  @override
  void initState() {
    super.initState();
    context.read<DriverBloc>().add(const LoadPaymentHistory());
  }

  void _applyFilter(String? filter) {
    setState(() => _activeFilter = filter);
    context.read<DriverBloc>().add(LoadPaymentHistory(typeFilter: filter));
  }

  Future<void> _onRefresh() async {
    context.read<DriverBloc>().add(
      LoadPaymentHistory(typeFilter: _activeFilter),
    );
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'salary':
        return Icons.work;
      case 'commission':
        return Icons.percent;
      case 'bonus':
        return Icons.card_giftcard;
      case 'trip_fee':
      case 'expense_reimbursement':
        return Icons.receipt_long;
      default:
        return Icons.payment;
    }
  }

  String _labelForType(String type) {
    switch (type) {
      case 'salary':
        return 'Salary';
      case 'commission':
        return 'Commission';
      case 'bonus':
        return 'Bonus';
      case 'trip_fee':
        return 'Trip Fee';
      case 'expense_reimbursement':
        return 'Reimbursement';
      default:
        return type;
    }
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'salary':
        return AppColors.primary;
      case 'commission':
        return AppColors.secondary;
      case 'bonus':
        return AppColors.accent;
      case 'trip_fee':
        return const Color(0xFF9C27B0);
      default:
        return AppColors.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    const filters = [
      (null, 'All'),
      ('salary', 'Salary'),
      ('commission', 'Commission'),
      ('bonus', 'Bonus'),
      ('trip_fee', 'Trip Fee'),
      ('expense_reimbursement', 'Reimbursement'),
    ];

    return DriverFeatureScaffold(
      title: 'Payment History',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Total Earnings summary
          BlocBuilder<DriverBloc, DriverState>(
            builder: (context, state) {
              if (state is! PaymentHistoryLoaded) {
                return const SizedBox.shrink();
              }
              final total = state.transactions
                  .where((p) => p.type.name == 'credit')
                  .fold<double>(0, (sum, p) => sum + p.amount);

              return Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Column(
                  children: [
                    Text(
                      'Total Earnings',
                      style: TextStyle(
                        color: AppColors.white.withOpacity(0.85),
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '\$${total.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          SizedBox(height: 16.h),
          // Filter chips
          SizedBox(
            height: 38.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: filters.length,
              separatorBuilder: (_, __) => SizedBox(width: 8.w),
              itemBuilder: (context, index) {
                final (filter, label) = filters[index];
                final isActive = _activeFilter == filter;
                return ChoiceChip(
                  label: Text(label),
                  selected: isActive,
                  onSelected: (_) => _applyFilter(filter),
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    fontSize: 13.sp,
                    color: isActive ? AppColors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                  backgroundColor: AppColors.surface,
                  side: BorderSide(
                    color: isActive ? AppColors.primary : AppColors.border,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 14.h),
          // Transaction list
          SizedBox(
            height: 500.h,
            child: BlocBuilder<DriverBloc, DriverState>(
              builder: (context, state) {
                if (state is DriverLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is! PaymentHistoryLoaded) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.history,
                          size: 48.sp,
                          color: AppColors.gray400,
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          'No transactions found',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (state.transactions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.history,
                          size: 48.sp,
                          color: AppColors.gray400,
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          'No transactions found',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final transactions = state.transactions;
                return RefreshIndicator(
                  onRefresh: _onRefresh,
                  color: AppColors.primary,
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: transactions.length,
                    separatorBuilder: (_, __) => SizedBox(height: 10.h),
                    itemBuilder: (context, index) {
                      final tx = transactions[index];
                      final type = tx.type;
                      final amount = tx.amount;
                      final desc = tx.description;
                      final date = tx.createdAt;
                      final status = tx.status;
                      final icon = _iconForType(type.name);
                      final label = _labelForType(type.name);
                      final color = _colorForType(type.name);

                      return Container(
                        padding: EdgeInsets.all(14.w),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44.w,
                              height: 44.w,
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Icon(icon, color: color, size: 22),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        label,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14.sp,
                                        ),
                                      ),
                                      SizedBox(width: 8.w),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8.w,
                                          vertical: 2.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: status == 'paid'
                                              ? AppColors.success.withOpacity(
                                                  0.12,
                                                )
                                              : AppColors.warning.withOpacity(
                                                  0.12,
                                                ),
                                          borderRadius: BorderRadius.circular(
                                            4.r,
                                          ),
                                        ),
                                        child: Text(
                                          status == 'paid' ? 'PAID' : 'PENDING',
                                          style: TextStyle(
                                            fontSize: 10.sp,
                                            fontWeight: FontWeight.w700,
                                            color: status == 'paid'
                                                ? AppColors.success
                                                : AppColors.warning,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (desc.isNotEmpty)
                                    Padding(
                                      padding: EdgeInsets.only(top: 3.h),
                                      child: Text(
                                        desc,
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: AppColors.textSecondary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  Padding(
                                    padding: EdgeInsets.only(top: 3.h),
                                    child: Text(
                                      DateFormat('MMM d, yyyy').format(date),
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        color: AppColors.textTertiary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '\$${amount.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16.sp,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                SizedBox(height: 6.h),
                                InkWell(
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text(
                                          'Invoice download started…',
                                        ),
                                        backgroundColor: AppColors.info,
                                      ),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(6.r),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8.w,
                                      vertical: 4.h,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: AppColors.primary,
                                      ),
                                      borderRadius: BorderRadius.circular(6.r),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.download,
                                          size: 14.sp,
                                          color: AppColors.primary,
                                        ),
                                        SizedBox(width: 4.w),
                                        Text(
                                          'Invoice',
                                          style: TextStyle(
                                            fontSize: 11.sp,
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
