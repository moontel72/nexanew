//lib/features/factory/admin/presentation/screens/codes/packet_codes/packet_codes_overview_screen.dart
import 'package:flutter/material.dart' hide SearchBar;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trace_odd/shared/theme/colors.dart';
import 'package:trace_odd/features/factory/admin/presentation/bloc/codes/packet_codes/packet_codes_bloc.dart';
import 'package:trace_odd/shared/models/code/base_code_model.dart';
import 'package:trace_odd/shared/models/code/packet_code_model.dart';
import 'package:trace_odd/shared/widgets/app_bars/custom_app_bar.dart';
import 'package:trace_odd/shared/widgets/buttons/primary_button.dart';
import 'package:trace_odd/shared/widgets/empty_states/empty_state_widget.dart';
import 'package:trace_odd/shared/widgets/loading/loading_indicator.dart';
import 'package:trace_odd/shared/widgets/search/search_bar.dart'
    as custom;
import 'package:url_launcher/url_launcher.dart';
import 'package:trace_odd/core/constants/api_endpoints.dart';

class PacketCodesOverviewScreen extends StatefulWidget {
  const PacketCodesOverviewScreen({super.key});

  @override
  State<PacketCodesOverviewScreen> createState() =>
      _PacketCodesOverviewScreenState();
}

class _PacketCodesOverviewScreenState extends State<PacketCodesOverviewScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PacketCodesBloc>().add(const LoadPacketCodes());
    });
  }

  PreferredSizeWidget _buildAppBar() {
    return const _PacketOverviewAppBar();
  }

  Widget _buildFormatFilter(PacketCodesState state) {
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
                      context.read<PacketCodesBloc>().add(
                        const FilterPacketCodesByFormat(null),
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
                        context.read<PacketCodesBloc>().add(
                          FilterPacketCodesByFormat(format.value),
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

  Widget _buildStatistics(List<PacketCodeModel> codes) {
    if (codes.isEmpty) return const SizedBox.shrink();
    final totalPackets = codes.length;
    final sealedPackets = codes.where((c) => c.isSealed).length;
    final intactPackets = codes.where((c) => c.condition == 'Intact').length;
    final totalUnits = codes.fold<int>(0, (sum, c) => sum + c.unitCount);
    final damagedPackets = codes.where((c) => c.condition == 'Damaged').length;
    final tamperEvidencePackets = codes
        .where((c) => c.hasTamperEvidence)
        .length;
    final sealedPct = totalPackets > 0
        ? (sealedPackets * 100 ~/ totalPackets)
        : 0;
    final intactPct = totalPackets > 0
        ? (intactPackets * 100 ~/ totalPackets)
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
              'Packet Statistics',
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
                  value: totalPackets.toString(),
                  icon: Icons.inventory_2,
                  color: AppColors.primary,
                ),
                _buildStatItem(
                  label: 'Sealed',
                  value: '$sealedPackets ($sealedPct%)',
                  icon: Icons.lock,
                  color: AppColors.success,
                ),
                _buildStatItem(
                  label: 'Intact',
                  value: '$intactPackets ($intactPct%)',
                  icon: Icons.check_circle,
                  color: AppColors.info,
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem(
                  label: 'Units',
                  value: totalUnits.toString(),
                  icon: Icons.shopping_bag,
                  color: AppColors.secondary,
                ),
                _buildStatItem(
                  label: 'Damaged',
                  value: damagedPackets.toString(),
                  icon: Icons.warning_amber,
                  color: AppColors.error,
                ),
                _buildStatItem(
                  label: 'Tamper Evid.',
                  value: tamperEvidencePackets.toString(),
                  icon: Icons.shield,
                  color: AppColors.warning,
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
      body: BlocConsumer<PacketCodesBloc, PacketCodesState>(
        listener: (context, state) async {
          if (state.status == PacketCodesStatus.exported &&
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
          if (state.status == PacketCodesStatus.error &&
              state.errorMessage != null &&
              state.errorMessage!.trim().isNotEmpty) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
        },
        builder: (context, state) {
          if (state.status == PacketCodesStatus.loading &&
              state.packetCodes.isEmpty) {
            return const Center(child: LoadingIndicator());
          }
          if (state.status == PacketCodesStatus.error &&
              state.packetCodes.isEmpty) {
            return Center(
              child: EmptyState(
                icon: Icons.error_outline,
                title: 'Error Loading Packet Codes',
                description: state.errorMessage ?? 'Please try again',
                actionButton: PrimaryButton(
                  text: 'Retry',
                  onPressed: () => context.read<PacketCodesBloc>().add(
                    const LoadPacketCodes(),
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
                            .read<PacketCodesBloc>()
                            .add(SearchPacketCodes(query)),
                        hintText: 'Search packet codes...',
                      ),
                      SizedBox(height: 12.h),
                      _buildFormatFilter(state),
                      SizedBox(height: 12.h),
                      _buildStatistics(state.filteredPacketCodes),
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

class _PacketOverviewAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const _PacketOverviewAppBar();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PacketCodesBloc, PacketCodesState>(
      builder: (context, state) {
        return CustomAppBar(
          title: 'Packet Overview',
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
