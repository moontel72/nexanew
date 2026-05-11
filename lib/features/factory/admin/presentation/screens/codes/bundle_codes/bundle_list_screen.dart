import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nexatrace_system/features/factory/admin/presentation/bloc/codes/bundle_codes/bundle_bloc.dart';
import 'package:nexatrace_system/features/factory/admin/presentation/bloc/codes/bundle_codes/insights/bundle_insights_bloc.dart';
import 'package:nexatrace_system/features/factory/admin/presentation/screens/codes/bundle_codes/bundle_insights_screen.dart';
import 'package:nexatrace_system/shared/theme/colors.dart';
import 'package:nexatrace_system/shared/widgets/app_bars/custom_app_bar.dart';
import 'package:nexatrace_system/shared/widgets/empty_states/empty_state_widget.dart';
import 'package:nexatrace_system/shared/widgets/loading/loading_indicator.dart';

class BundleListScreen extends StatefulWidget {
  const BundleListScreen({super.key});
  @override
  State<BundleListScreen> createState() => _BundleListScreenState();
}

class _BundleListScreenState extends State<BundleListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BundleBloc>().add(const LoadBundles());
    });
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'draft':
        return AppColors.warning;
      case 'packed':
        return AppColors.info;
      case 'shipped':
        return AppColors.secondary;
      case 'delivered':
        return AppColors.success;
      default:
        return AppColors.textSecondary;
    }
  }

  void _openInsights(String bundleId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => BundleInsightsBloc(),
          child: BundleInsightsScreen(bundleId: bundleId),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Bundles', showBackButton: true),
      body: BlocBuilder<BundleBloc, BundleState>(
        builder: (context, state) {
          if (state.status == BundleStatus.loading && state.bundles.isEmpty) {
            return const Center(child: LoadingIndicator());
          }
          if (state.bundles.isEmpty) {
            return const Center(
              child: EmptyState(
                icon: Icons.layers_outlined,
                title: 'No Bundles Yet',
                description:
                    'Create bundles by linking cartons and packets to an order.',
              ),
            );
          }
          return ListView.builder(
            padding: EdgeInsets.all(16.w),
            itemCount: state.bundles.length,
            itemBuilder: (_, i) {
              final b = state.bundles[i];
              return Card(
                margin: EdgeInsets.only(bottom: 12.h),
                child: ListTile(
                  leading: Icon(Icons.layers, color: _statusColor(b.status)),
                  title: Text(
                    b.bundleCode,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    '${b.orderReference} \u2022 Cartons: ${b.totalCartons} \u2022 Packets: ${b.totalPackets}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Link Units chip
                      ActionChip(
                        avatar: const Icon(Icons.link, size: 16),
                        label: const Text(
                          'Link Units',
                          style: TextStyle(fontSize: 11),
                        ),
                        backgroundColor: AppColors.primary.withAlpha(20),
                        side: const BorderSide(color: AppColors.primary),
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                        onPressed: () => _openInsights(b.id),
                      ),
                      SizedBox(width: 6.w),
                      // Draft badge
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: _statusColor(b.status).withAlpha(30),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          b.status,
                          style: TextStyle(
                            color: _statusColor(b.status),
                            fontWeight: FontWeight.w600,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Tap the whole row to open insights
                  onTap: () => _openInsights(b.id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
