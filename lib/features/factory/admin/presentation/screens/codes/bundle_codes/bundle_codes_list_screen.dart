import 'package:flutter/material.dart' hide SearchBar;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:trace_odd/shared/theme/colors.dart';
import 'package:trace_odd/features/factory/admin/presentation/bloc/codes/bundle_codes/bundle_codes_bloc.dart';
import 'package:trace_odd/shared/models/code/base_code_model.dart';
import 'package:trace_odd/shared/models/code/bundle_code_model.dart';
import 'package:trace_odd/shared/widgets/app_bars/custom_app_bar.dart';
import 'package:trace_odd/shared/widgets/buttons/primary_button.dart';
import 'package:trace_odd/shared/widgets/cards/code_card.dart';
import 'package:trace_odd/shared/widgets/empty_states/empty_state_widget.dart';
import 'package:trace_odd/shared/widgets/filters/filter_chip_row.dart';
import 'package:trace_odd/shared/widgets/loading/loading_indicator.dart';
import 'package:trace_odd/shared/widgets/search/search_bar.dart'
    as custom;
import 'package:url_launcher/url_launcher.dart';
import 'package:trace_odd/core/constants/api_endpoints.dart';

class BundleCodesListScreen extends StatefulWidget {
  const BundleCodesListScreen({super.key});

  @override
  State<BundleCodesListScreen> createState() => _BundleCodesListScreenState();
}

class _BundleCodesListScreenState extends State<BundleCodesListScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isSelectionMode = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BundleCodesBloc>().add(const LoadBundleCodes());
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
      context.read<BundleCodesBloc>().add(const LoadMoreBundleCodes());
    }
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        context.read<BundleCodesBloc>().add(const ClearSelection());
      }
    });
  }

  void _selectAllVisible() {
    final state = context.read<BundleCodesBloc>().state;
    final visibleCodes = state.filteredCodes;
    final selectedIds = state.selectedCodes;

    if (visibleCodes.every((code) => selectedIds.contains(code.id))) {
      // Deselect all
      context.read<BundleCodesBloc>().add(const ClearSelection());
    } else {
      // Select all visible
      for (final code in visibleCodes) {
        if (!selectedIds.contains(code.id)) {
          context.read<BundleCodesBloc>().add(SelectBundleCode(code.id));
        }
      }
    }
  }

  void _showFilterDialog() {
    showDialog(context: context, builder: (context) => _FilterDialog());
  }

  void _showCodeDetails(BundleCodeModel code) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _CodeDetailsBottomSheet(code: code),
    );
  }

  void _showActionMenu(BuildContext context, BundleCodeModel code) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _CodeActionMenu(code: code),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: BlocConsumer<BundleCodesBloc, BundleCodesState>(
        listener: (context, state) async {
          if (state.exportStatus == ExportStatus.success &&
              state.exportPath != null &&
              state.exportPath!.trim().isNotEmpty) {
            final raw = state.exportPath!.trim();
            final uri = Uri.tryParse(raw);
            final downloadUri = (uri != null && uri.hasScheme)
                ? uri
                : Uri.parse(
                    ApiEndpoints.getFullUrl(raw.startsWith('/') ? raw : '/$raw'),
                  );

            await launchUrl(downloadUri, mode: LaunchMode.platformDefault);

            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Download started')),
            );
          }

          if (state.exportStatus == ExportStatus.failure &&
              state.error != null &&
              state.error!.trim().isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error!)),
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading && state.codes.isEmpty) {
            return const Center(child: LoadingIndicator());
          }

          return Scrollbar(
            controller: _scrollController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  _buildSearchAndFilters(state),
                  _buildStatistics(state),
                  _buildListContent(state),
                  SizedBox(height: 16.h),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: _buildFloatingActionButton(),
      bottomNavigationBar: _isSelectionMode ? _buildSelectionBar() : null,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return CustomAppBar(
      title: 'Bundle Codes',
      showBackButton: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: _showFilterDialog,
          tooltip: 'Filter',
        ),
        IconButton(
          icon: const Icon(Icons.download),
          onPressed: () {
            // TODO: Export functionality
          },
          tooltip: 'Export',
        ),
        IconButton(
          icon: Icon(_isSelectionMode ? Icons.close : Icons.select_all),
          onPressed: _toggleSelectionMode,
          tooltip: _isSelectionMode ? 'Exit Selection' : 'Select Multiple',
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters(BundleCodesState state) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        children: [
          custom.SearchBar(
            onSearchChanged: (query) {
              context.read<BundleCodesBloc>().add(SearchBundleCodes(query));
            },
            hintText: 'Search bundle codes...',
          ),
          SizedBox(height: 8.h),
          FilterChipRow(
            selectedValue: state.currentFilter?.status?.name,
            onSelectionChanged: (value) {
              final status = value != null && value != 'all'
                  ? CodeStatus.values.firstWhere((e) => e.name == value)
                  : null;
              context.read<BundleCodesBloc>().add(
                FilterBundleCodes(status: status),
              );
            },
            chips: [
              const FilterChipData(label: 'All', value: 'all'),
              FilterChipData(
                label: 'Generated',
                value: CodeStatus.generated.name,
              ),
              FilterChipData(label: 'Linked', value: CodeStatus.linked.name),
              FilterChipData(
                label: 'Published',
                value: CodeStatus.published.name,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics(BundleCodesState state) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      color: Colors.grey[50],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            state.pageInfo,
            style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
          ),
          Row(
            children: [
              Icon(Icons.inventory, size: 14.w, color: Colors.green),
              SizedBox(width: 4.w),
              Text(
                '${state.statistics['total'] ?? 0}',
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 12.w),
              Icon(Icons.check_circle, size: 14.w, color: Colors.blue),
              SizedBox(width: 4.w),
              Text(
                '${state.statistics['selected'] ?? 0}',
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildListContent(BundleCodesState state) {
    if (state.filteredCodes.isEmpty) {
      return Expanded(
        child: EmptyState(
          icon: Icons.inventory,
          title: 'No Bundle Codes Found',
          description: state.searchQuery.isNotEmpty
              ? 'No codes match your search "${state.searchQuery}"'
              : 'Start by generating your first bundle codes',
          actionButton: PrimaryButton(
            text: 'Generate Codes',
            onPressed: () {
              // TODO: Navigate to generate screen
            },
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<BundleCodesBloc>().add(const RefreshBundleCodes());
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.symmetric(vertical: 8.h),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: state.paginatedCodes.length + (state.hasMorePages ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= state.paginatedCodes.length) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: const Center(child: CircularProgressIndicator()),
            );
          }

          final code = state.paginatedCodes[index];
          return _buildCodeListItem(code, state);
        },
      ),
    );
  }

  Widget _buildCodeListItem(BundleCodeModel code, BundleCodesState state) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      child: Column(
        children: [
          CodeCard(
            code: code.code,
            codeType: code.type.name,
            status: code.status.name,
            batchNumber: code.batchId,
            generatedDate: code.generatedAt,
            onTap: () {
              if (_isSelectionMode) {
                context.read<BundleCodesBloc>().add(SelectBundleCode(code.id));
              } else {
                _showCodeDetails(code);
              }
            },
            actions: _isSelectionMode
                ? null
                : [
                    OutlinedButton.icon(
                      onPressed: () => _showCodeDetails(code),
                      icon: const Icon(Icons.visibility_outlined),
                      label: const Text('View Details'),
                    ),
                    OutlinedButton.icon(
                      onPressed: code.status == CodeStatus.published
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
                              final exportFormat =
                                  (format == 'pdf') ? ExportFormat.pdf : ExportFormat.csv;
                              context
                                  .read<BundleCodesBloc>()
                                  .add(
                                    ExportBundleCodes(
                                      format: exportFormat,
                                      codeIds: [code.id],
                                    ),
                                  );
                            }
                          : null,
                      icon: const Icon(Icons.download_outlined),
                      label: const Text('Download'),
                    ),
                    OutlinedButton.icon(
                      onPressed: code.canPublish
                          ? () {
                              context.read<BundleCodesBloc>().add(
                                PublishBundleCode(code.id),
                              );
                            }
                          : null,
                      icon: const Icon(Icons.publish_outlined),
                      label: const Text('Publish'),
                    ),
                  ],
            isSelected: state.selectedCodes.contains(code.id),
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
                    onPressed: () => _showActionMenu(context, code),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () {
        context.go('/factory/codes/bundle/generate');
      },
      icon: const Icon(Icons.add),
      label: const Text('Generate'),
      backgroundColor: AppColors.primary,
    );
  }

  Widget _buildSelectionBar() {
    return BlocBuilder<BundleCodesBloc, BundleCodesState>(
      builder: (context, state) {
        final selectedCount = state.selectedCodes.length;
        final deletableSelected = state.selectedBundleCodes
            .where(
              (code) =>
                  code.status == CodeStatus.generated ||
                  code.status == CodeStatus.linked,
            )
            .length;

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Colors.grey[300]!)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$selectedCount selected',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
              ),
              Row(
                children: [
                  if (deletableSelected > 0)
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _showDeleteConfirmation(context, state);
                      },
                      tooltip: 'Delete Selected',
                    ),
                  IconButton(
                    icon: const Icon(Icons.download),
                    onPressed: () {
                      // TODO: Export selected
                    },
                    tooltip: 'Export Selected',
                  ),
                  IconButton(
                    icon: const Icon(Icons.select_all),
                    onPressed: _selectAllVisible,
                    tooltip: 'Select All',
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, BundleCodesState state) {
    final selectedCodes = state.selectedBundleCodes;
    final deletableCodes = selectedCodes.where(
      (code) =>
          code.status == CodeStatus.generated ||
          code.status == CodeStatus.linked,
    );

    if (deletableCodes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selected codes cannot be deleted'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Bundle Codes'),
        content: Text(
          'Are you sure you want to delete ${deletableCodes.length} bundle codes? '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<BundleCodesBloc>().add(
                DeleteBundleCodeBatch(
                  deletableCodes.map((code) => code.id).toList(),
                ),
              );
              _toggleSelectionMode();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _FilterDialog extends StatefulWidget {
  @override
  State<_FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<_FilterDialog> {
  CodeStatus? _selectedStatus;
  DateTime? _startDate;
  DateTime? _endDate;
  int? _minCartonCount;
  int? _maxCartonCount;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filter Bundle Codes'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatusFilter(),
            SizedBox(height: 16.h),
            _buildDateRangeFilter(),
            SizedBox(height: 16.h),
            _buildCartonCountFilter(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            context.read<BundleCodesBloc>().add(const FilterBundleCodes());
          },
          child: const Text('Clear All'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            context.read<BundleCodesBloc>().add(
              FilterBundleCodes(
                status: _selectedStatus,
                startDate: _startDate,
                endDate: _endDate,
                minCartonCount: _minCartonCount,
                maxCartonCount: _maxCartonCount,
              ),
            );
          },
          child: const Text('Apply Filters'),
        ),
      ],
    );
  }

  Widget _buildStatusFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Status',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          children: CodeStatus.values.map((status) {
            final displayName = _getStatusDisplayName(status);
            return ChoiceChip(
              label: Text(displayName),
              selected: _selectedStatus == status,
              onSelected: (selected) {
                setState(() {
                  _selectedStatus = selected ? status : null;
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDateRangeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date Range',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: _buildDateField(
                'From',
                _startDate,
                (date) => setState(() => _startDate = date),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: _buildDateField(
                'To',
                _endDate,
                (date) => setState(() => _endDate = date),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateField(
    String label,
    DateTime? date,
    Function(DateTime?) onDateSelected,
  ) {
    return GestureDetector(
      onTap: () async {
        final selectedDate = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        if (selectedDate != null) {
          onDateSelected(selectedDate);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        child: Text(
          date != null
              ? '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}'
              : 'Select date',
          style: TextStyle(
            color: date != null ? Colors.black : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildCartonCountFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Carton Count',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Min',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., 5',
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    _minCartonCount = value.isNotEmpty
                        ? int.tryParse(value)
                        : null;
                  });
                },
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Max',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., 20',
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    _maxCartonCount = value.isNotEmpty
                        ? int.tryParse(value)
                        : null;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getStatusDisplayName(CodeStatus status) {
    switch (status) {
      case CodeStatus.generated:
        return 'Generated';
      case CodeStatus.linked:
        return 'Linked';
      case CodeStatus.published:
        return 'Published';
      case CodeStatus.deactivated:
        return 'Deactivated';
      case CodeStatus.expired:
        return 'Expired';
    }
  }
}

class _CodeDetailsBottomSheet extends StatelessWidget {
  final BundleCodeModel code;

  const _CodeDetailsBottomSheet({required this.code});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Bundle Code Details',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.success.withAlpha(25),
                  borderRadius: BorderRadius.circular(4.r),
                  border: Border.all(color: AppColors.success),
                ),
                child: Text(
                  code.status.name.toUpperCase(),
                  style: TextStyle(
                    color: AppColors.success,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _buildDetailRow('Code', code.code),
          _buildDetailRow('Store Keeper Code', code.storeKeeperCode),
          _buildDetailRow('International Code', code.internationalCode),
          _buildDetailRow('Carton Count', '${code.cartonCount}'),
          _buildDetailRow('Total Units', '${code.totalUnits}'),
          _buildDetailRow('Sequence Number', '${code.sequenceNumber}'),
          if (code.productId != null)
            _buildDetailRow('Product ID', code.productId!),
          if (code.productBatchNumber != null)
            _buildDetailRow('Product Batch', code.productBatchNumber!),
          if (code.manufacturingDate != null)
            _buildDetailRow(
              'Manufacturing Date',
              '${code.manufacturingDate!.year}-${code.manufacturingDate!.month.toString().padLeft(2, '0')}-${code.manufacturingDate!.day.toString().padLeft(2, '0')}',
            ),
          if (code.expiryDate != null)
            _buildDetailRow(
              'Expiry Date',
              '${code.expiryDate!.year}-${code.expiryDate!.month.toString().padLeft(2, '0')}-${code.expiryDate!.day.toString().padLeft(2, '0')}',
            ),
          if (code.warrantyMonths != null)
            _buildDetailRow('Warranty', '${code.warrantyMonths} months'),
          _buildDetailRow(
            'Generated',
            '${code.generatedAt.year}-${code.generatedAt.month.toString().padLeft(2, '0')}-${code.generatedAt.day.toString().padLeft(2, '0')}',
          ),
          if (code.linkedAt != null)
            _buildDetailRow(
              'Linked',
              '${code.linkedAt!.year}-${code.linkedAt!.month.toString().padLeft(2, '0')}-${code.linkedAt!.day.toString().padLeft(2, '0')}',
            ),
          if (code.publishedAt != null)
            _buildDetailRow(
              'Published',
              '${code.publishedAt!.year}-${code.publishedAt!.month.toString().padLeft(2, '0')}-${code.publishedAt!.day.toString().padLeft(2, '0')}',
            ),
          SizedBox(height: 24.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Action based on code status
                  },
                  child: Text(_getActionButtonText()),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.w,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(value, style: TextStyle(fontSize: 14.sp)),
          ),
        ],
      ),
    );
  }

  String _getActionButtonText() {
    switch (code.status) {
      case CodeStatus.generated:
        return 'Link to Product';
      case CodeStatus.linked:
        return 'Publish';
      case CodeStatus.published:
        return 'Deactivate';
      case CodeStatus.deactivated:
        return 'Reactivate';
      case CodeStatus.expired:
        return 'Renew';
    }
  }
}

class _CodeActionMenu extends StatelessWidget {
  final BundleCodeModel code;

  const _CodeActionMenu({required this.code});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Actions for ${code.code}',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16.h),
          if (code.status == CodeStatus.generated ||
              code.status == CodeStatus.linked)
            _buildActionButton(context, Icons.delete, 'Delete', Colors.red, () {
              Navigator.pop(context);
              _showDeleteConfirmation(context, code);
            }),
          if (code.status == CodeStatus.generated ||
              code.status == CodeStatus.linked)
            _buildActionButton(
              context,
              Icons.publish,
              'Publish',
              Colors.green,
              () {
                Navigator.pop(context);
                context.read<BundleCodesBloc>().add(PublishBundleCode(code.id));
              },
            ),
          if (code.status == CodeStatus.published)
            _buildActionButton(
              context,
              Icons.block,
              'Deactivate',
              Colors.orange,
              () {
                Navigator.pop(context);
                context.read<BundleCodesBloc>().add(
                  DeactivateBundleCode(code.id),
                );
              },
            ),
          _buildActionButton(
            context,
            Icons.download,
            'Download',
            Colors.purple,
            () {
              Navigator.pop(context);
              // TODO: Download code
            },
          ),
          _buildActionButton(context, Icons.print, 'Print', Colors.teal, () {
            Navigator.pop(context);
            // TODO: Print code
          }),
          _buildActionButton(context, Icons.share, 'Share', Colors.indigo, () {
            Navigator.pop(context);
            // TODO: Share code
          }),
          SizedBox(height: 8.h),
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              minimumSize: Size(double.infinity, 48.h),
            ),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    VoidCallback onPressed,
  ) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label),
      onTap: onPressed,
    );
  }

  void _showDeleteConfirmation(BuildContext context, BundleCodeModel code) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Bundle Code'),
        content: Text(
          'Are you sure you want to delete bundle code ${code.code}? '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<BundleCodesBloc>().add(DeleteBundleCode(code.id));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
