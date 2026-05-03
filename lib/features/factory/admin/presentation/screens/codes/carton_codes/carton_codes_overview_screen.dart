//lib/features/factory/admin/presentation/screens/codes/carton_codes/carton_codes_overview_screen.dart
import 'package:flutter/material.dart' hide SearchBar;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nexatrace_system/shared/theme/colors.dart';
import 'package:nexatrace_system/features/factory/admin/presentation/bloc/codes/carton_codes/carton_codes_bloc.dart';
import 'package:nexatrace_system/shared/models/code/base_code_model.dart';
import 'package:nexatrace_system/shared/models/code/carton_code_model.dart';
import 'package:nexatrace_system/shared/widgets/app_bars/custom_app_bar.dart';
import 'package:nexatrace_system/shared/widgets/buttons/primary_button.dart';
import 'package:nexatrace_system/shared/widgets/empty_states/empty_state_widget.dart';
import 'package:nexatrace_system/shared/widgets/loading/loading_indicator.dart';
import 'package:nexatrace_system/shared/widgets/search/search_bar.dart'
    as custom;
import 'package:url_launcher/url_launcher.dart';
import 'package:nexatrace_system/core/constants/api_endpoints.dart';

class CartonCodesOverviewScreen extends StatefulWidget {
  const CartonCodesOverviewScreen({super.key});

  @override
  State<CartonCodesOverviewScreen> createState() =>
      _CartonCodesOverviewScreenState();
}

class _CartonCodesOverviewScreenState extends State<CartonCodesOverviewScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartonCodesBloc>().add(const LoadCartonCodes());
    });
  }

  PreferredSizeWidget _buildAppBar() {
    return const _CartonOverviewAppBar();
  }

  Widget _buildFormatFilter(CartonCodesState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Code Format',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: ChoiceChip(
                  label: const Text('All'),
                  selected: state.filterCodeFormat.isEmpty,
                  onSelected: (selected) {
                    if (selected) {
                      context.read<CartonCodesBloc>().add(
                        const FilterCartonCodesByFormat(null),
                      );
                    }
                  },
                  selectedColor: AppColors.primary.withAlpha(30),
                  backgroundColor: AppColors.surface,
                  side: BorderSide(
                    color: state.filterCodeFormat.isEmpty
                        ? AppColors.primary
                        : AppColors.border,
                  ),
                  labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: state.filterCodeFormat.isEmpty
                        ? AppColors.primary
                        : AppColors.textPrimary,
                    fontWeight: state.filterCodeFormat.isEmpty
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ),
              ...CartonCodeFormat.values.map((format) {
                final isSelected = state.filterCodeFormat == format.value;
                return Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: ChoiceChip(
                    label: Text(format.displayName),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        context.read<CartonCodesBloc>().add(
                          FilterCartonCodesByFormat(format.value),
                        );
                      }
                    },
                    selectedColor: AppColors.primary.withAlpha(30),
                    backgroundColor: AppColors.surface,
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : AppColors.border,
                    ),
                    labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatistics(List<CartonCodeModel> codes) {
    if (codes.isEmpty) return const SizedBox.shrink();
    final totalCartons = codes.length;
    final sealedCartons = codes.where((c) => c.isSealed).length;
    final needInspection = codes.where((c) => c.needsInspection).length;
    final totalPackets = codes.fold<int>(0, (sum, c) => sum + c.packetCount);
    final totalUnits = codes.fold<int>(0, (sum, c) => sum + c.totalUnits);
    final overweightCartons = codes.where((c) => c.isOverweight).length;
    final sealedPct = totalCartons > 0
        ? (sealedCartons * 100 ~/ totalCartons)
        : 0;
    final inspPct = totalCartons > 0
        ? (needInspection * 100 ~/ totalCartons)
        : 0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Carton Statistics',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(color: AppColors.primary),
            ),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem(
                  label: 'Total',
                  value: totalCartons.toString(),
                  icon: Icons.inventory_2,
                  color: AppColors.primary,
                ),
                _buildStatItem(
                  label: 'Sealed',
                  value: '$sealedCartons ($sealedPct%)',
                  icon: Icons.lock,
                  color: AppColors.success,
                ),
                _buildStatItem(
                  label: 'Inspect',
                  value: '$needInspection ($inspPct%)',
                  icon: Icons.warning,
                  color: AppColors.warning,
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem(
                  label: 'Packets',
                  value: totalPackets.toString(),
                  icon: Icons.inventory_2,
                  color: AppColors.info,
                ),
                _buildStatItem(
                  label: 'Units',
                  value: totalUnits.toString(),
                  icon: Icons.shopping_bag,
                  color: AppColors.secondary,
                ),
                _buildStatItem(
                  label: 'Overwt',
                  value: overweightCartons.toString(),
                  icon: Icons.warning_amber,
                  color: AppColors.error,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20.w, color: color),
        ),
        SizedBox(height: 8.h),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: BlocConsumer<CartonCodesBloc, CartonCodesState>(
        listener: (context, state) async {
          if (state.status == CartonCodesStatus.exported &&
              state.exportPath != null &&
              state.exportPath!.trim().isNotEmpty) {
            final raw = state.exportPath!.trim();
            final uri = Uri.tryParse(raw);
            final downloadUri = (uri != null && uri.hasScheme)
                ? uri
                : Uri.parse(
                    ApiEndpoints.getFullUrl(
                      raw.startsWith('/') ? raw : '/$raw',
                    ),
                  );
            await launchUrl(downloadUri, mode: LaunchMode.platformDefault);
            if (!context.mounted) return;
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Download started')));
          }
          if (state.status == CartonCodesStatus.error &&
              state.errorMessage != null &&
              state.errorMessage!.trim().isNotEmpty) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
        },
        builder: (context, state) {
          if (state.status == CartonCodesStatus.loading &&
              state.cartonCodes.isEmpty) {
            return const Center(child: LoadingIndicator());
          }
          if (state.status == CartonCodesStatus.error &&
              state.cartonCodes.isEmpty) {
            return Center(
              child: EmptyState(
                icon: Icons.error_outline,
                title: 'Error Loading Carton Codes',
                description: state.errorMessage ?? 'Please try again',
                actionButton: PrimaryButton(
                  text: 'Retry',
                  onPressed: () => context.read<CartonCodesBloc>().add(
                    const LoadCartonCodes(),
                  ),
                ),
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 16.w, 16.w, 0),
                  child: Column(
                    children: [
                      custom.SearchBar(
                        onSearchChanged: (query) => context
                            .read<CartonCodesBloc>()
                            .add(SearchCartonCodes(query)),
                        hintText: 'Search carton codes...',
                      ),
                      SizedBox(height: 12.h),
                      _buildFormatFilter(state),
                      SizedBox(height: 12.h),
                      _buildStatistics(state.filteredCartonCodes),
                      SizedBox(height: 80.h),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CartonOverviewAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const _CartonOverviewAppBar();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartonCodesBloc, CartonCodesState>(
      builder: (context, state) {
        return CustomAppBar(
          title: 'Carton Overview',
          showBackButton: true,
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.filter_list, color: Colors.white),
              tooltip: 'Filter',
            ),
          ],
        );
      },
    );
  }
}
