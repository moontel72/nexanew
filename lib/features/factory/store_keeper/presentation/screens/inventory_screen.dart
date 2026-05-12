import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:nexatrace_system/features/factory/store_keeper/presentation/bloc/store_keeper_bloc.dart';
import 'package:nexatrace_system/features/factory/store_keeper/presentation/widgets/hierarchy_tree.dart';
import 'package:nexatrace_system/shared/theme/colors.dart';
import 'package:nexatrace_system/shared/theme/text_styles.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});
  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final _searchC = TextEditingController();
  @override
  void dispose() {
    _searchC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Inventory'),
      backgroundColor: AppColors.accent,
      foregroundColor: Colors.white,
    ),
    body: BlocBuilder<StoreKeeperBloc, StoreKeeperState>(
      builder: (context, state) => Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: TextField(
              controller: _searchC,
              decoration: InputDecoration(
                hintText: 'Search by bundle code...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    final q = _searchC.text.trim();
                    if (q.isNotEmpty)
                      context.read<StoreKeeperBloc>().add(
                        LoadHierarchy(bundleId: q),
                      );
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                filled: true,
                fillColor: AppColors.gray50,
              ),
              onSubmitted: (v) {
                if (v.trim().isNotEmpty)
                  context.read<StoreKeeperBloc>().add(
                    LoadHierarchy(bundleId: v.trim()),
                  );
              },
            ),
          ),
          Expanded(child: _buildContent(state)),
        ],
      ),
    ),
  );
  Widget _buildContent(StoreKeeperState state) {
    if (state is InventoryState && state.isLoading)
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      );
    if (state is InventoryState && state.hierarchy != null)
      return SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: HierarchyTreeView(node: state.hierarchy!),
      );
    if (state is ErrorState)
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48.w, color: AppColors.error),
            Gap(16.h),
            Text(
              state.message,
              style: TextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2, size: 64.w, color: AppColors.gray300),
          Gap(16.h),
          Text(
            'Enter a bundle code to view hierarchy',
            style: TextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Gap(8.h),
          Text(
            'Shows: Bundle → Cartons → Packets → Units',
            style: TextStyles.caption.copyWith(color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }
}
