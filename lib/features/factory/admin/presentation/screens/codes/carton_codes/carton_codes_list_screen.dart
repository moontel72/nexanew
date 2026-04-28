//lib/features/factory/admin/presentation/screens/codes/carton_codes/carton_codes_list_screen.dart
import 'package:flutter/material.dart' hide SearchBar;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nexatrace_system/shared/theme/colors.dart';
import 'package:nexatrace_system/features/factory/admin/presentation/bloc/codes/carton_codes/carton_codes_bloc.dart';
import 'package:nexatrace_system/shared/models/code/base_code_model.dart';
import 'package:nexatrace_system/shared/models/code/carton_code_model.dart';
import 'package:nexatrace_system/shared/widgets/app_bars/custom_app_bar.dart';
import 'package:nexatrace_system/shared/widgets/buttons/primary_button.dart';
import 'package:nexatrace_system/shared/widgets/cards/code_card.dart';
import 'package:nexatrace_system/shared/widgets/empty_states/empty_state_widget.dart';
import 'package:nexatrace_system/shared/widgets/filters/filter_chip_row.dart';
import 'package:nexatrace_system/shared/widgets/loading/loading_indicator.dart';
import 'package:nexatrace_system/shared/widgets/search/search_bar.dart'
    as custom;
import 'package:url_launcher/url_launcher.dart';
import 'package:nexatrace_system/core/constants/api_endpoints.dart';

class CartonCodesListScreen extends StatefulWidget {
  const CartonCodesListScreen({super.key});

  @override
  State<CartonCodesListScreen> createState() => _CartonCodesListScreenState();
}

class _CartonCodesListScreenState extends State<CartonCodesListScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isSelectionMode = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartonCodesBloc>().add(const LoadCartonCodes());
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      // TODO: Implement load more functionality
    }
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        context.read<CartonCodesBloc>().add(const ClearSelection());
      }
    });
  }

  void _selectAllVisible() {
    final state = context.read<CartonCodesBloc>().state;
    final visibleCartons = state.filteredCartonCodes;
    final selectedIds = state.selectedCartonCodeIds;

    if (visibleCartons.every((carton) => selectedIds.contains(carton.id))) {
      // Deselect all
      context.read<CartonCodesBloc>().add(const ClearSelection());
    } else {
      // Select all visible
      for (final carton in visibleCartons) {
        if (!selectedIds.contains(carton.id)) {
          context.read<CartonCodesBloc>().add(
            SelectCartonCode(carton.id, true),
          );
        }
      }
    }
  }

  void _showFilterDialog() {
    // TODO: Implement filter dialog
  }

  void _showCartonDetails(CartonCodeModel carton) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _CartonDetailsBottomSheet(carton: carton),
    );
  }

  void _showActionMenu(BuildContext context, CartonCodeModel carton) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _CartonActionMenu(carton: carton),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return _CartonCodesAppBar(
      isSelectionMode: _isSelectionMode,
      onToggleSelectionMode: _toggleSelectionMode,
      onShowFilterDialog: _showFilterDialog,
    );
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

  Widget _buildCartonCard(CartonCodeModel carton) {
    return Column(
      children: [
        CodeCard(
          code: carton.code,
          codeType:
              '${carton.type.name} (${CartonCodeFormat.fromValue(carton.codeFormat).displayName})',
          status: carton.status.name,
          batchNumber: carton.batchId,
          generatedDate: carton.generatedAt,
          onTap: () => _showCartonDetails(carton),
          actions: [
            OutlinedButton.icon(
              onPressed: () => _showCartonDetails(carton),
              icon: const Icon(Icons.visibility_outlined),
              label: const Text('View Details'),
            ),
            OutlinedButton.icon(
              onPressed: carton.status == CodeStatus.published
                  ? () async {
                      final format = await showModalBottomSheet<String>(
                        context: context,
                        builder: (context) {
                          return SafeArea(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.picture_as_pdf),
                                  title: const Text('Download PDF'),
                                  onTap: () => Navigator.pop(context, 'pdf'),
                                ),
                                ListTile(
                                  leading: const Icon(Icons.table_chart),
                                  title: const Text('Download CSV'),
                                  onTap: () => Navigator.pop(context, 'csv'),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                      if (format == null) return;
                      context.read<CartonCodesBloc>().add(
                        ExportCartonCodes([carton.id], format),
                      );
                    }
                  : null,
              icon: const Icon(Icons.download_outlined),
              label: const Text('Download'),
            ),
            OutlinedButton.icon(
              onPressed: carton.canPublish
                  ? () {
                      context.read<CartonCodesBloc>().add(
                        PublishCartonCode(carton.id),
                      );
                    }
                  : null,
              icon: const Icon(Icons.publish_outlined),
              label: const Text('Publish'),
            ),
          ],
          isSelected:
              _isSelectionMode &&
              context
                  .read<CartonCodesBloc>()
                  .state
                  .selectedCartonCodeIds
                  .contains(carton.id),
        ),
        if (!_isSelectionMode)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.more_vert,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () => _showActionMenu(context, carton),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildSelectionActions() {
    return BlocBuilder<CartonCodesBloc, CartonCodesState>(
      builder: (context, state) {
        if (!_isSelectionMode || !state.hasSelection) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.outline, width: 1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${state.selectedCartonCodeIds.length} carton(s) selected',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: _selectAllVisible,
                    icon: Icon(
                      state.allSelected
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      color: AppColors.primary,
                    ),
                    tooltip: state.allSelected ? 'Deselect All' : 'Select All',
                  ),
                  SizedBox(width: 8.w),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: AppColors.primary),
                    onSelected: (value) {
                      switch (value) {
                        case 'export':
                          // TODO: Implement export
                          break;
                        case 'link':
                          // TODO: Implement batch link
                          break;
                        case 'publish':
                          // TODO: Implement batch publish
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'export',
                        child: Text('Export Selected'),
                      ),
                      const PopupMenuItem(
                        value: 'link',
                        child: Text('Link to Product'),
                      ),
                      const PopupMenuItem(
                        value: 'publish',
                        child: Text('Publish Selected'),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatistics() {
    return BlocBuilder<CartonCodesBloc, CartonCodesState>(
      builder: (context, state) {
        final stats = state.statistics;
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
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
                      label: 'Total Cartons',
                      value: stats['totalCartons'].toString(),
                      icon: Icons.inventory_2,
                      color: AppColors.primary,
                    ),
                    _buildStatItem(
                      label: 'Sealed',
                      value:
                          '${stats['sealedCartons']} (${stats['sealedPercentage']}%)',
                      icon: Icons.lock,
                      color: AppColors.success,
                    ),
                    _buildStatItem(
                      label: 'Need Inspection',
                      value:
                          '${stats['needInspection']} (${stats['inspectionPercentage']}%)',
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
                      label: 'Total Packets',
                      value: stats['totalPackets'].toString(),
                      icon: Icons.inventory_2,
                      color: AppColors.info,
                    ),
                    _buildStatItem(
                      label: 'Total Units',
                      value: stats['totalUnits'].toString(),
                      icon: Icons.shopping_bag,
                      color: AppColors.secondary,
                    ),
                    _buildStatItem(
                      label: 'Overweight',
                      value: stats['overweightCartons'].toString(),
                      icon: Icons.warning_amber,
                      color: AppColors.error,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
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

          if (state.filteredCartonCodes.isEmpty) {
            return Scrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(16.w),
                      child: custom.SearchBar(
                        onSearchChanged: (query) => context
                            .read<CartonCodesBloc>()
                            .add(SearchCartonCodes(query)),
                        hintText: 'Search carton codes...',
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: _buildFormatFilter(state),
                    ),
                    Padding(
                      padding: EdgeInsets.all(16.w),
                      child: EmptyState(
                        icon: Icons.inventory_2,
                        title: 'No Carton Codes Found',
                        description: state.searchQuery.isNotEmpty
                            ? 'No carton codes match your search'
                            : 'Start by generating carton codes',
                        actionButton: PrimaryButton(
                          text: state.searchQuery.isNotEmpty
                              ? 'Clear Search'
                              : 'Generate Codes',
                          onPressed: () {
                            if (state.searchQuery.isNotEmpty) {
                              context.read<CartonCodesBloc>().add(
                                const SearchCartonCodes(''),
                              );
                            } else {
                              context.go('/factory/codes/carton/generate');
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return Scrollbar(
            controller: _scrollController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      children: [
                        custom.SearchBar(
                          onSearchChanged: (query) => context
                              .read<CartonCodesBloc>()
                              .add(SearchCartonCodes(query)),
                          hintText: 'Search carton codes...',
                        ),
                        SizedBox(height: 12.h),
                        // Format filter chips
                        _buildFormatFilter(state),
                        SizedBox(height: 12.h),
                        _buildStatistics(),
                        SizedBox(height: 12.h),
                        FilterChipRow(
                          selectedValue: state.filterStatus?.name,
                          onSelectionChanged: (value) {
                            final status = value != null
                                ? CodeStatus.values.firstWhere(
                                    (e) => e.name == value,
                                  )
                                : null;
                            context.read<CartonCodesBloc>().add(
                              FilterCartonCodes(status: status),
                            );
                          },
                          chips: [
                            const FilterChipData(label: 'All', value: 'all'),
                            FilterChipData(
                              label: 'Generated',
                              value: CodeStatus.generated.name,
                            ),
                            FilterChipData(
                              label: 'Linked',
                              value: CodeStatus.linked.name,
                            ),
                            FilterChipData(
                              label: 'Published',
                              value: CodeStatus.published.name,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.only(
                      bottom: 80.h,
                      left: 16.w,
                      right: 16.w,
                    ),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount:
                        state.filteredCartonCodes.length +
                        (state.isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= state.filteredCartonCodes.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: LoadingIndicator()),
                        );
                      }
                      final carton = state.filteredCartonCodes[index];
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 4.h),
                        child: _buildCartonCard(carton),
                      );
                    },
                  ),
                  SizedBox(height: 16.h),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CartonCodesAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final bool isSelectionMode;
  final VoidCallback onToggleSelectionMode;
  final VoidCallback onShowFilterDialog;

  const _CartonCodesAppBar({
    required this.isSelectionMode,
    required this.onToggleSelectionMode,
    required this.onShowFilterDialog,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartonCodesBloc, CartonCodesState>(
      builder: (context, state) {
        return CustomAppBar(
          title: isSelectionMode
              ? '${state.selectedCartonCodeIds.length} Selected'
              : 'Carton Codes',
          showBackButton: true,
          actions: [
            if (!isSelectionMode)
              IconButton(
                onPressed: onToggleSelectionMode,
                icon: const Icon(Icons.checklist, color: Colors.white),
                tooltip: 'Select Multiple',
              ),
            if (isSelectionMode)
              IconButton(
                onPressed: onToggleSelectionMode,
                icon: const Icon(Icons.close, color: Colors.white),
                tooltip: 'Cancel Selection',
              ),
            if (isSelectionMode && state.hasSelection)
              IconButton(
                onPressed: () {
                  final selectedIds = state.selectedCartonCodeIds.toList();
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(
                        'Delete Selected Cartons',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: AppColors.error),
                      ),
                      content: Text(
                        'Are you sure you want to delete ${selectedIds.length} carton(s)?\n\nThis action cannot be undone.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Cancel',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            context.read<CartonCodesBloc>().add(
                              DeleteCartonCodeBatch(selectedIds),
                            );
                          },
                          child: Text(
                            'Delete',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppColors.error),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.delete_outline, color: Colors.white),
                tooltip: 'Delete Selected',
              ),
            IconButton(
              onPressed: onShowFilterDialog,
              icon: const Icon(Icons.filter_list, color: Colors.white),
              tooltip: 'Filter',
            ),
          ],
        );
      },
    );
  }
}

class _CartonDetailsBottomSheet extends StatelessWidget {
  final CartonCodeModel carton;

  const _CartonDetailsBottomSheet({required this.carton});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Carton Details',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              _buildDetailRow(context, 'Code', carton.code),
              _buildDetailRow(
                context,
                'Format',
                CartonCodeFormat.fromValue(carton.codeFormat).displayName,
              ),
              _buildDetailRow(context, 'Bundle', carton.bundleCode),
              _buildDetailRow(
                context,
                'Status',
                carton.status.name.toUpperCase(),
              ),
              _buildDetailRow(
                context,
                'Sequence',
                carton.sequenceNumber.toString(),
              ),
              _buildDetailRow(
                context,
                'Packets',
                carton.packetCount.toString(),
              ),
              _buildDetailRow(
                context,
                'Total Units',
                carton.totalUnits.toString(),
              ),
              if (carton.weight != null)
                _buildDetailRow(context, 'Weight', '${carton.weight} kg'),
              if (carton.dimensions != null)
                _buildDetailRow(context, 'Dimensions', carton.dimensions!),
              if (carton.cartonType != null)
                _buildDetailRow(context, 'Carton Type', carton.cartonType!),
              if (carton.grade != null)
                _buildDetailRow(context, 'Grade', carton.grade!),
              _buildDetailRow(context, 'Condition', carton.condition),
              _buildDetailRow(
                context,
                'Sealing Status',
                carton.isSealed ? 'Sealed' : 'Open',
              ),
              _buildDetailRow(
                context,
                'Inspection Status',
                carton.lastInspectionDate != null ? 'Inspected' : 'Pending',
              ),
              if (carton.temperatureRequirements != null)
                _buildDetailRow(
                  context,
                  'Temperature',
                  carton.temperatureRequirements!,
                ),
              if (carton.handlingInstructions != null)
                _buildDetailRow(
                  context,
                  'Handling',
                  carton.handlingInstructions!,
                ),
              SizedBox(height: 16.h),
              if (carton.productId != null)
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: EdgeInsets.all(12.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Product Information',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(color: AppColors.primary),
                        ),
                        SizedBox(height: 8.h),
                        _buildDetailRow(
                          context,
                          'Product ID',
                          carton.productId!,
                        ),
                        if (carton.productBatchNumber != null)
                          _buildDetailRow(
                            context,
                            'Batch',
                            carton.productBatchNumber!,
                          ),
                        if (carton.manufacturingDate != null)
                          _buildDetailRow(
                            context,
                            'Manufacturing Date',
                            carton.manufacturingDate!
                                .toLocal()
                                .toString()
                                .split(' ')[0],
                          ),
                        if (carton.expiryDate != null)
                          _buildDetailRow(
                            context,
                            'Expiry Date',
                            carton.expiryDate!.toLocal().toString().split(
                              ' ',
                            )[0],
                          ),
                        if (carton.warrantyMonths != null)
                          _buildDetailRow(
                            context,
                            'Warranty',
                            '${carton.warrantyMonths} months',
                          ),
                      ],
                    ),
                  ),
                ),
              SizedBox(height: 16.h),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class _CartonActionMenu extends StatelessWidget {
  final CartonCodeModel carton;

  const _CartonActionMenu({required this.carton});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<CartonCodesBloc>();

    return Container(
      padding: EdgeInsets.all(16.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Actions for ${carton.code}',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          SizedBox(height: 16.h),
          _buildActionItem(
            context,
            icon: Icons.remove_red_eye,
            label: 'View Details',
            onTap: () {
              Navigator.pop(context);
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => _CartonDetailsBottomSheet(carton: carton),
              );
            },
          ),
          if (carton.status == CodeStatus.generated ||
              carton.status == CodeStatus.linked)
            _buildActionItem(
              context,
              icon: Icons.publish,
              label: 'Publish',
              onTap: () {
                Navigator.pop(context);
                bloc.add(PublishCartonCode(carton.id));
              },
            ),
          if (carton.status == CodeStatus.published)
            _buildActionItem(
              context,
              icon: Icons.block,
              label: 'Deactivate',
              onTap: () {
                Navigator.pop(context);
                _showDeactivateDialog(context, carton);
              },
            ),
          if (!carton.isSealed)
            _buildActionItem(
              context,
              icon: Icons.lock,
              label: 'Seal Carton',
              onTap: () {
                Navigator.pop(context);
                _showSealDialog(context, carton);
              },
            ),
          if (carton.lastInspectionDate == null)
            _buildActionItem(
              context,
              icon: Icons.checklist,
              label: 'Update Inspection',
              onTap: () {
                Navigator.pop(context);
                _showInspectionDialog(context, carton);
              },
            ),
          if (carton.status == CodeStatus.generated ||
              carton.status == CodeStatus.linked)
            _buildActionItem(
              context,
              icon: Icons.delete_outline,
              label: 'Delete',
              color: AppColors.error,
              onTap: () {
                Navigator.pop(context);
                _showDeleteDialog(context, carton);
              },
            ),
          _buildActionItem(
            context,
            icon: Icons.qr_code,
            label: 'View QR Code',
            onTap: () {
              Navigator.pop(context);
              // TODO: Implement QR code view
            },
          ),
          _buildActionItem(
            context,
            icon: Icons.barcode_reader,
            label: 'View Barcode',
            onTap: () {
              Navigator.pop(context);
              // TODO: Implement barcode view
            },
          ),
        ],
      ),
    );
  }

  void _showSealDialog(BuildContext context, CartonCodeModel carton) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Seal Carton',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        content: Text(
          'Are you sure you want to seal carton ${carton.code}?\n\nOnce sealed, the carton cannot be reopened without authorization.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Get current user ID
              context.read<CartonCodesBloc>().add(
                SealCarton(carton.id, 'current_user_id'),
              );
            },
            child: Text(
              'Seal',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _showInspectionDialog(BuildContext context, CartonCodeModel carton) {
    final conditionController = TextEditingController(text: carton.condition);
    final notesController = TextEditingController(
      text: carton.inspectionNotes ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Update Carton Inspection',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Condition:',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.h),
              DropdownButtonFormField<String>(
                initialValue: carton.condition,
                items: const [
                  DropdownMenuItem(value: 'New', child: Text('New')),
                  DropdownMenuItem(value: 'Good', child: Text('Good')),
                  DropdownMenuItem(value: 'Damaged', child: Text('Damaged')),
                  DropdownMenuItem(
                    value: 'Repair needed',
                    child: Text('Repair needed'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    conditionController.text = value;
                  }
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Inspection Notes:',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.h),
              TextField(
                controller: notesController,
                decoration: InputDecoration(
                  hintText: 'Enter inspection notes...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          TextButton(
            onPressed: () {
              if (conditionController.text.isNotEmpty) {
                Navigator.pop(context);
                context.read<CartonCodesBloc>().add(
                  UpdateCartonInspection(
                    carton.id,
                    conditionController.text,
                    notesController.text,
                  ),
                );
              }
            },
            child: Text(
              'Update',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.primary),
      title: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: color ?? AppColors.textPrimary),
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  void _showDeleteDialog(BuildContext context, CartonCodeModel carton) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Carton Code',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: AppColors.error),
        ),
        content: Text(
          'Are you sure you want to delete carton code ${carton.code}?\n\nThis action cannot be undone.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<CartonCodesBloc>().add(DeleteCartonCode(carton.id));
            },
            child: Text(
              'Delete',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeactivateDialog(BuildContext context, CartonCodeModel carton) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Deactivate Carton Code',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: AppColors.warning),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Please provide a reason for deactivating carton code ${carton.code}:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                hintText: 'e.g., Damaged, Returned, Expired',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          TextButton(
            onPressed: () {
              if (reasonController.text.isNotEmpty) {
                Navigator.pop(context);
                context.read<CartonCodesBloc>().add(
                  DeactivateCartonCode(carton.id, reasonController.text),
                );
              }
            },
            child: Text(
              'Deactivate',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.warning),
            ),
          ),
        ],
      ),
    );
  }
}
