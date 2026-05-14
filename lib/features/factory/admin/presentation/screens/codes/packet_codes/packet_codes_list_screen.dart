//lib/features/factory/admin/presentation/screens/codes/packet_codes/packet_codes_list_screen.dart
import 'package:flutter/material.dart' hide SearchBar;
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nexatrace_system/shared/theme/colors.dart';
import 'package:nexatrace_system/features/factory/admin/presentation/bloc/codes/packet_codes/packet_codes_bloc.dart';
import 'package:nexatrace_system/shared/models/code/base_code_model.dart';
import 'package:nexatrace_system/shared/models/code/packet_code_model.dart';
import 'package:nexatrace_system/shared/widgets/app_bars/custom_app_bar.dart';
import 'package:nexatrace_system/shared/widgets/buttons/primary_button.dart';
import 'package:nexatrace_system/shared/widgets/empty_states/empty_state_widget.dart';
import 'package:nexatrace_system/shared/widgets/loading/loading_indicator.dart';
import 'package:nexatrace_system/shared/widgets/search/search_bar.dart'
    as custom;
import 'package:url_launcher/url_launcher.dart';
import 'package:nexatrace_system/core/constants/api_endpoints.dart';

class PacketCodesListScreen extends StatefulWidget {
  const PacketCodesListScreen({super.key});

  @override
  State<PacketCodesListScreen> createState() => _PacketCodesListScreenState();
}

class _PacketCodesListScreenState extends State<PacketCodesListScreen> {
  final ScrollController _scrollController = ScrollController();

  bool _isSelectionMode = false;
  final Set<String> _expandedBatches = {};

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PacketCodesBloc>().add(const LoadPacketCodes());
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {}
  }

  void _showFilterDialog() {}

  void _showPacketDetails(PacketCodeModel packet) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _PacketDetailsBottomSheet(packet: packet),
    );
  }

  void _showActionMenu(BuildContext context, PacketCodeModel packet) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _PacketActionMenu(packet: packet),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return _PacketCodesAppBar(onShowFilterDialog: _showFilterDialog);
  }

  List<_PacketBatchGroup> _groupBatches(List<PacketCodeModel> codes) {
    final map = <String, _PacketBatchGroup>{};
    for (final c in codes) {
      final key = '${c.batchId}|${c.codeFormat}';
      final existing = map[key];
      if (existing == null) {
        map[key] = _PacketBatchGroup(
          batchId: c.batchId,
          codeFormat: c.codeFormat,
          codeCount: 1,
          generatedAt: c.generatedAt,
          isPushed: c.status == CodeStatus.published,
          codes: [c],
        );
      } else {
        map[key] = existing.copyWith(
          codeCount: existing.codeCount + 1,
          generatedAt: c.generatedAt.isAfter(existing.generatedAt)
              ? c.generatedAt
              : existing.generatedAt,
          isPushed: existing.isPushed || c.status == CodeStatus.published,
          codes: [...existing.codes, c],
        );
      }
    }
    final items = map.values.toList();
    items.sort((a, b) => b.generatedAt.compareTo(a.generatedAt));
    return items;
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

  String _batchKey(_PacketBatchGroup group) =>
      '${group.batchId}|${group.codeFormat}';

  Widget _buildBatchCard(_PacketBatchGroup group) {
    final batchId = group.batchId.trim().isEmpty ? 'NO-BATCH' : group.batchId;
    final formatName = CartonCodeFormat.fromValue(group.codeFormat).displayName;
    final date = group.generatedAt.toLocal().toString().split(' ').first;
    final isValidBatch = group.batchId.trim().isNotEmpty;
    final key = _batchKey(group);
    final isExpanded = _expandedBatches.contains(key);

    final sortedCodes = List<PacketCodeModel>.from(group.codes)
      ..sort((a, b) => a.code.compareTo(b.code));

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedBatches.remove(key);
                } else {
                  _expandedBatches.add(key);
                }
              });
            },
            child: Padding(
              padding: EdgeInsets.all(12.w),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '$formatName - Batch: $batchId',
                                style: Theme.of(context).textTheme.titleSmall,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: group.isPushed
                                    ? AppColors.success.withAlpha(30)
                                    : AppColors.warning.withAlpha(30),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                group.isPushed ? 'Finalized' : 'Draft',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: group.isPushed
                                          ? AppColors.success
                                          : AppColors.warning,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          '${group.codeCount} Codes \u2022 Generated: $date',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  AnimatedRotation(
                    turns: isExpanded ? 0.25 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.chevron_right,
                      color: AppColors.textSecondary,
                      size: 24.w,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            const Divider(height: 1, color: AppColors.borderColor),
            if (!isValidBatch)
              Padding(
                padding: EdgeInsets.all(12.w),
                child: Text(
                  'BatchId missing for these codes. Regenerate to enable actions.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              child: Table(
                columnWidths: const {
                  0: FlexColumnWidth(0.15),
                  1: FlexColumnWidth(0.40),
                  2: FlexColumnWidth(0.20),
                  3: FlexColumnWidth(0.25),
                },
                children: [
                  TableRow(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: AppColors.borderColor,
                          width: 1,
                        ),
                      ),
                    ),
                    children: [
                      _tableHeader('#'),
                      _tableHeader('Code Data'),
                      _tableHeader('Format'),
                      _tableHeader('Status'),
                    ],
                  ),
                  for (int i = 0; i < sortedCodes.length; i++)
                    TableRow(
                      decoration: BoxDecoration(
                        color: i.isEven
                            ? AppColors.surface.withAlpha(50)
                            : Colors.transparent,
                      ),
                      children: [
                        _tableCell(
                          '${i + 1}',
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                        _tableCell(
                          sortedCodes[i].code,
                          fontWeight: FontWeight.w600,
                        ),
                        _tableCell(formatName),
                        _tableCell(
                          sortedCodes[i].statusDisplayName,
                          color: _statusColor(sortedCodes[i].status),
                          fontWeight: FontWeight.w500,
                        ),
                      ],
                    ),
                ],
              ),
            ),
            SizedBox(height: 8.h),
            Padding(
              padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 12.h),
              child: Row(
                children: [
                  if (!group.isPushed) ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: isValidBatch
                            ? () => _confirmDeleteBatch(context, group)
                            : null,
                        icon: const Icon(Icons.delete_outline, size: 18),
                        label: const Text('Delete'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          OutlinedButton.icon(
                            onPressed: isValidBatch
                                ? () => _confirmPushBatch(context, group)
                                : null,
                            icon: const Icon(Icons.publish_outlined, size: 18),
                            label: const Text('Push'),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            '${group.codeCount} codes',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 10.sp,
                                ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),
                  ],
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: (group.isPushed && isValidBatch)
                          ? () => _downloadBatch(context, group)
                          : null,
                      icon: group.isPushed
                          ? const Icon(Icons.download_outlined, size: 18)
                          : const Icon(Icons.lock_outlined, size: 18),
                      label: Text(group.isPushed ? 'Download' : 'Locked'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _tableHeader(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _tableCell(String text, {Color? color, FontWeight? fontWeight}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: color ?? AppColors.textPrimary,
          fontWeight: fontWeight ?? FontWeight.normal,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Color _statusColor(CodeStatus status) {
    switch (status) {
      case CodeStatus.generated:
        return AppColors.warning;
      case CodeStatus.linked:
        return AppColors.info;
      case CodeStatus.published:
        return AppColors.success;
      case CodeStatus.deactivated:
        return AppColors.error;
      case CodeStatus.expired:
        return AppColors.textSecondary;
    }
  }

  void _confirmDeleteBatch(BuildContext context, _PacketBatchGroup group) {
    final bloc = context.read<PacketCodesBloc>();
    final formatName = CartonCodeFormat.fromValue(group.codeFormat).displayName;
    final batchId = group.batchId.trim().isEmpty ? 'NO-BATCH' : group.batchId;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Delete Batch',
          style: Theme.of(
            ctx,
          ).textTheme.titleMedium?.copyWith(color: AppColors.error),
        ),
        content: Text(
          'Delete all ${group.codeCount} codes?\n\n$formatName \u2022 $batchId',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              bloc.add(
                DeletePacketBatchByGroup(
                  batchId: group.batchId,
                  codeFormat: group.codeFormat,
                ),
              );
            },
            child: Text(
              'Delete All',
              style: Theme.of(
                ctx,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmPushBatch(BuildContext context, _PacketBatchGroup group) {
    final bloc = context.read<PacketCodesBloc>();
    final formatName = CartonCodeFormat.fromValue(group.codeFormat).displayName;
    final batchId = group.batchId.trim().isEmpty ? 'NO-BATCH' : group.batchId;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Push Batch'),
        content: Text(
          'Finalize all ${group.codeCount} codes?\n\n$formatName \u2022 $batchId',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              bloc.add(
                PushPacketBatch(
                  batchId: group.batchId,
                  codeFormat: group.codeFormat,
                  count: group.codeCount,
                ),
              );
            },
            child: const Text('Push All'),
          ),
        ],
      ),
    );
  }

  void _downloadBatch(BuildContext context, _PacketBatchGroup group) async {
    final bloc = context.read<PacketCodesBloc>();
    final format = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('Download PDF'),
              onTap: () => Navigator.pop(ctx, 'pdf'),
            ),
            ListTile(
              leading: const Icon(Icons.table_chart),
              title: const Text('Download CSV'),
              onTap: () => Navigator.pop(ctx, 'csv'),
            ),
          ],
        ),
      ),
    );
    if (format == null) return;
    bloc.add(ExportPacketBatch(group.batchId, group.codeFormat, format));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: BlocConsumer<PacketCodesBloc, PacketCodesState>(
        listener: (context, state) {
          _handleExportState(context, state);
        },
        builder: (context, state) {
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

          if (state.filteredPacketCodes.isEmpty) {
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
                            .read<PacketCodesBloc>()
                            .add(SearchPacketCodes(query)),
                        hintText: 'Search packet codes...',
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: _buildFormatFilter(state),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: EmptyState(
                        icon: Icons.inventory_2,
                        title: 'No Packet Codes Found',
                        description: state.searchQuery.isNotEmpty
                            ? 'No packet codes match your search'
                            : 'Start by generating packet codes',
                        actionButton: PrimaryButton(
                          text: state.searchQuery.isNotEmpty
                              ? 'Clear Search'
                              : 'Generate Codes',
                          onPressed: () {
                            if (state.searchQuery.isNotEmpty) {
                              context.read<PacketCodesBloc>().add(
                                const SearchPacketCodes(''),
                              );
                            } else {
                              final fmt = state.filterCodeFormat.isNotEmpty
                                  ? state.filterCodeFormat
                                  : null;
                              if (fmt != null) {
                                context.go(
                                  '/factory/codes/packet/generate?format=$fmt',
                                );
                              } else {
                                context.go('/factory/codes/packet/generate');
                              }
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 16.w, 16.w, 0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        custom.SearchBar(
                          onSearchChanged: (query) => context
                              .read<PacketCodesBloc>()
                              .add(SearchPacketCodes(query)),
                          hintText: 'Search packet codes...',
                        ),
                        SizedBox(height: 12.h),
                        _buildFormatFilter(state),
                      ],
                    ),
                  ),
                  Builder(
                    builder: (context) {
                      final groups = _groupBatches(state.filteredPacketCodes);
                      if (groups.isEmpty) {
                        return Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 32.h,
                          ),
                          child: const EmptyState(
                            icon: Icons.inventory_2,
                            title: 'No Batch Groups',
                            description: 'No batch groups could be formed.',
                          ),
                        );
                      }
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Column(
                          children: [
                            ...groups.map(
                              (group) => Padding(
                                padding: EdgeInsets.only(bottom: 12.h),
                                child: _buildBatchCard(group),
                              ),
                            ),
                            if (state.isLoadingMore)
                              const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(child: LoadingIndicator()),
                              ),
                            SizedBox(height: 80.h),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleExportState(BuildContext context, PacketCodesState state) {
    if (state.status == PacketCodesStatus.exported &&
        state.exportPath != null &&
        state.exportPath!.trim().isNotEmpty) {
      final raw = state.exportPath!.trim();
      final uri = Uri.tryParse(raw);
      final downloadUri = (uri != null && uri.hasScheme)
          ? uri
          : Uri.parse(
              ApiEndpoints.getFullUrl(raw.startsWith('/') ? raw : '/$raw'),
            );
      launchUrl(downloadUri, mode: LaunchMode.platformDefault).then((_) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Download started')));
          // Reset export state immediately to prevent ghost download popups
          context.read<PacketCodesBloc>().add(const ClearSelection());
        }
      });
    }
  }
}

class _PacketCodesAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final VoidCallback onShowFilterDialog;
  const _PacketCodesAppBar({required this.onShowFilterDialog});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PacketCodesBloc, PacketCodesState>(
      builder: (context, state) {
        return CustomAppBar(
          title: 'Packet Codes',
          showBackButton: true,
          actions: [
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

@immutable
class _PacketBatchGroup {
  final String batchId;
  final String codeFormat;
  final int codeCount;
  final DateTime generatedAt;
  final bool isPushed;
  final List<PacketCodeModel> codes;

  const _PacketBatchGroup({
    required this.batchId,
    required this.codeFormat,
    required this.codeCount,
    required this.generatedAt,
    required this.isPushed,
    required this.codes,
  });

  _PacketBatchGroup copyWith({
    int? codeCount,
    DateTime? generatedAt,
    bool? isPushed,
    List<PacketCodeModel>? codes,
  }) {
    return _PacketBatchGroup(
      batchId: batchId,
      codeFormat: codeFormat,
      codeCount: codeCount ?? this.codeCount,
      generatedAt: generatedAt ?? this.generatedAt,
      isPushed: isPushed ?? this.isPushed,
      codes: codes ?? this.codes,
    );
  }
}

class _PacketDetailsBottomSheet extends StatelessWidget {
  final PacketCodeModel packet;
  const _PacketDetailsBottomSheet({required this.packet});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20.w),
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
                SizedBox(height: 20.h),
                Text(
                  'Packet Code Details',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16.h),
                _dr(context, 'Code', packet.code),
                // ── QR Code for Store Keeper Scanning ──
                Center(
                  child: Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        QrImageView(
                          data: packet.id,
                          version: QrVersions.auto,
                          size: 150.w,
                          eyeStyle: const QrEyeStyle(
                            eyeShape: QrEyeShape.square,
                            color: Color(0xFFE65100),
                          ),
                          dataModuleStyle: const QrDataModuleStyle(
                            dataModuleShape: QrDataModuleShape.square,
                            color: Color(0xFFE65100),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Scan with Store Keeper App',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 10.sp,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: packet.id));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Packet ID copied!'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.copy, size: 14.w, color: AppColors.accent),
                              SizedBox(width: 4.w),
                              Text(
                                'Copy UUID',
                                style: TextStyle(fontSize: 10.sp, color: AppColors.accent),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                _dr(context, 'Type', packet.type.name),
                _dr(context, 'Status', packet.status.name),
                _dr(context, 'Batch ID', packet.batchId),
                _dr(
                  context,
                  'Format',
                  CartonCodeFormat.fromValue(packet.codeFormat).displayName,
                ),
                _dr(
                  context,
                  'Generated',
                  packet.generatedAt.toLocal().toString().split('.')[0],
                ),
                if (packet.cartonCode.isNotEmpty)
                  _dr(context, 'Carton Code', packet.cartonCode),
                _dr(context, 'Units', packet.unitCount.toString()),
                if (packet.weight != null)
                  _dr(context, 'Weight', '${packet.weight} g'),
                if (packet.dimensions != null)
                  _dr(context, 'Dimensions', packet.dimensions!),
                if (packet.packetType != null)
                  _dr(context, 'Packet Type', packet.packetType!),
                if (packet.material != null)
                  _dr(context, 'Material', packet.material!),
                _dr(context, 'Sealed', packet.isSealed ? 'Yes' : 'No'),
                _dr(context, 'Condition', packet.condition),
                _dr(
                  context,
                  'Tamper Evidence',
                  packet.hasTamperEvidence ? 'Yes' : 'No',
                ),
                _dr(
                  context,
                  'Child Safety',
                  packet.hasChildSafety ? 'Yes' : 'No',
                ),
                if (packet.serialNumber != null)
                  _dr(context, 'Serial Number', packet.serialNumber!),
                SizedBox(height: 16.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _dr(BuildContext context, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110.w,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class _PacketActionMenu extends StatelessWidget {
  final PacketCodeModel packet;
  const _PacketActionMenu({required this.packet});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
              SizedBox(height: 20.h),
              Text(
                'Actions for ${packet.code}',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16.h),
              _action(context, Icons.visibility, 'View Details', () {
                Navigator.pop(context);
                _detailsPopup(context, packet);
              }),
              if (packet.canPublish)
                _action(context, Icons.publish, 'Publish Code', () {
                  Navigator.pop(context);
                  context.read<PacketCodesBloc>().add(
                    PublishPacketCode(packet.id),
                  );
                }),
              if (packet.isSealed)
                _action(
                  context,
                  Icons.lock_open,
                  'Unseal Packet',
                  () => _sealDlg(context, packet),
                ),
              _action(
                context,
                Icons.inventory_2,
                'Inspect Packet',
                () => _inspDlg(context, packet),
              ),
              if (packet.canDelete)
                _action(
                  context,
                  Icons.delete,
                  'Delete Code',
                  () => _delDlg(context, packet),
                  color: AppColors.error,
                ),
              if (packet.canDeactivate)
                _action(
                  context,
                  Icons.block,
                  'Deactivate Code',
                  () => _deactDlg(context, packet),
                  color: AppColors.warning,
                ),
              SizedBox(height: 8.h),
            ],
          ),
        ),
      ),
    );
  }

  void _detailsPopup(BuildContext context, PacketCodeModel code) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _PacketDetailsBottomSheet(packet: code),
    );
  }

  void _sealDlg(BuildContext context, PacketCodeModel packet) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Unseal Packet'),
        content: Text(
          'Unseal packet ${packet.code}?\n\nThis cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Unseal'),
          ),
        ],
      ),
    );
  }

  void _inspDlg(BuildContext context, PacketCodeModel packet) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Inspect Packet'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Inspect packet ${packet.code}'),
            SizedBox(height: 12.h),
            TextField(
              controller: ctrl,
              decoration: InputDecoration(
                hintText: 'Inspection notes...',
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
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _action(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap, {
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.textPrimary, size: 22.w),
      title: Text(label),
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
    );
  }

  void _delDlg(BuildContext context, PacketCodeModel packet) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Delete Packet Code',
          style: Theme.of(
            ctx,
          ).textTheme.titleMedium?.copyWith(color: AppColors.error),
        ),
        content: Text(
          'Delete packet code ${packet.code}?\n\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<PacketCodesBloc>().add(DeletePacketCode(packet.id));
            },
            child: Text(
              'Delete',
              style: Theme.of(
                ctx,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _deactDlg(BuildContext context, PacketCodeModel packet) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Deactivate Packet Code',
          style: Theme.of(
            ctx,
          ).textTheme.titleMedium?.copyWith(color: AppColors.warning),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Reason for deactivating ${packet.code}:'),
            SizedBox(height: 16.h),
            TextField(
              controller: ctrl,
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
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (ctrl.text.isNotEmpty) {
                Navigator.pop(ctx);
                context.read<PacketCodesBloc>().add(
                  DeactivatePacketCode(packet.id, ctrl.text),
                );
              }
            },
            child: Text(
              'Deactivate',
              style: Theme.of(
                ctx,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.warning),
            ),
          ),
        ],
      ),
    );
  }
}
