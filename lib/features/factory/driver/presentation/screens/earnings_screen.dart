import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:nexatrace_system/features/factory/driver/presentation/bloc/driver_bloc.dart';
import 'package:nexatrace_system/features/factory/driver/domain/entities/driver_earnings.dart';
import 'package:nexatrace_system/features/factory/driver/presentation/widgets/driver_feature_scaffold.dart';
import 'package:nexatrace_system/shared/theme/colors.dart';

class DriverEarningsScreen extends StatefulWidget {
  const DriverEarningsScreen({super.key});

  @override
  State<DriverEarningsScreen> createState() => _DriverEarningsScreenState();
}

class _DriverEarningsScreenState extends State<DriverEarningsScreen> {
  String _selectedPeriod = 'week';

  @override
  void initState() {
    super.initState();
    context.read<DriverBloc>().add(
      const LoadEarnings(startDate: null, endDate: null),
    );
  }

  void _changePeriod(String period) {
    setState(() => _selectedPeriod = period);
    DateTime? start;
    DateTime? end = DateTime.now();
    switch (period) {
      case 'week':
        start = end.subtract(const Duration(days: 7));
        break;
      case 'month':
        start = end.subtract(const Duration(days: 30));
        break;
      case 'year':
        start = end.subtract(const Duration(days: 365));
        break;
    }
    context.read<DriverBloc>().add(
      LoadEarnings(startDate: start, endDate: end),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DriverFeatureScaffold(
      title: 'Earnings',
      actions: [
        IconButton(
          onPressed: () => context.push('/factory/driver/payment-history'),
          icon: const Icon(Icons.receipt_long),
          tooltip: 'Payment History',
        ),
      ],
      child: BlocBuilder<DriverBloc, DriverState>(
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Period selector chips
              _periodChips(),
              SizedBox(height: 16.h),

              if (state is DriverLoading)
                const Center(child: CircularProgressIndicator()),

              if (state is DriverError) _errorCard(state.message),

              if (state is EarningsLoaded) ...[
                _earningsSummary(state.earnings),
                SizedBox(height: 16.h),
                _earningsBreakdown(state.earnings),
                SizedBox(height: 16.h),
                _pendingAlert(state.earnings),
              ],

              if (state is! EarningsLoaded &&
                  state is! DriverLoading &&
                  state is! DriverError)
                _placeholderCard(),
            ],
          );
        },
      ),
    );
  }

  Widget _periodChips() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: ['week', 'month', 'year'].map((period) {
        final selected = _selectedPeriod == period;
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: ChoiceChip(
            label: Text(period.toUpperCase()),
            selected: selected,
            selectedColor: AppColors.primary,
            labelStyle: TextStyle(
              color: selected ? Colors.white : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            onSelected: (_) => _changePeriod(period),
          ),
        );
      }).toList(),
    );
  }

  Widget _earningsSummary(DriverEarnings earnings) {
    final fmt = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Total Earnings',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14.sp,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            fmt.format(earnings.totalEarnings),
            style: TextStyle(
              color: Colors.white,
              fontSize: 32.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Net Pay: ${fmt.format(earnings.currentBalance)}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _miniStat(
                'Paid',
                fmt.format(earnings.currentBalance - earnings.pendingEarnings),
                AppColors.success,
              ),
              _miniStat(
                'Pending',
                fmt.format(earnings.pendingEarnings),
                AppColors.warning,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12.sp,
          ),
        ),
      ],
    );
  }

  Widget _earningsBreakdown(DriverEarnings earnings) {
    final fmt = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Earnings Breakdown',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          _breakdownRow('Salary', fmt.format(0.0), Icons.work),
          _breakdownRow('Commission', fmt.format(0.0), Icons.percent),
          _breakdownRow('Bonus', fmt.format(earnings.bonusAmount), Icons.star),
          _breakdownRow('Trip Fees', fmt.format(0.0), Icons.local_shipping),
          Divider(height: 24.h),
          _breakdownRow(
            'Net Pay',
            fmt.format(earnings.currentBalance),
            Icons.account_balance_wallet,
            isBold: true,
            color: AppColors.success,
          ),
        ],
      ),
    );
  }

  Widget _breakdownRow(
    String label,
    String value,
    IconData icon, {
    bool isBold = false,
    Color? color,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        children: [
          Icon(icon, size: 18.sp, color: color ?? AppColors.textSecondary),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              color: color ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _pendingAlert(DriverEarnings earnings) {
    if (earnings.pendingEarnings <= 0) return const SizedBox.shrink();
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: AppColors.warning,
            size: 24.sp,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              'You cannot receive \$${earnings.pendingEarnings.toStringAsFixed(2)} '
              'until you inform the admin. Amount will be given after admin approval. (4N)',
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.warning,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorCard(String message) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(message, style: TextStyle(color: AppColors.error)),
    );
  }

  Widget _placeholderCard() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(
            Icons.payments_outlined,
            size: 48.sp,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 12.h),
          Text(
            'Loading earnings data...',
            style: TextStyle(fontSize: 15.sp, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
