import 'package:flutter/material.dart' hide SearchBar;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nexatrace_system/features/factory/admin/presentation/bloc/codes/unit_codes/unit_codes_bloc.dart';
import 'package:nexatrace_system/shared/models/code/base_code_model.dart';
import 'package:nexatrace_system/shared/models/code/unit_code_model.dart';
import 'package:nexatrace_system/shared/theme/colors.dart';
import 'package:nexatrace_system/shared/widgets/app_bars/custom_app_bar.dart';
import 'package:nexatrace_system/shared/widgets/buttons/primary_button.dart';
import 'package:nexatrace_system/shared/widgets/empty_states/empty_state_widget.dart';
import 'package:nexatrace_system/shared/widgets/loading/loading_indicator.dart';
import 'package:nexatrace_system/shared/widgets/search/search_bar.dart'
    as custom;
import 'package:url_launcher/url_launcher.dart';
import 'package:nexatrace_system/core/constants/api_endpoints.dart';

class UnitCodesListScreen extends StatefulWidget {
  const UnitCodesListScreen({super.key});
  @override
  State<UnitCodesListScreen> createState() => _UnitCodesListScreenState();
}

class _UnitCodesListScreenState extends State<UnitCodesListScreen> {
  final ScrollController _scrollController = ScrollController();
  final Set<String> _expandedBatches = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UnitCodesBloc>().add(const LoadUnitCodes());
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<_UnitBatchGroup> _groupBatches(List<UnitCodeModel> codes) {
    final map = <String, _UnitBatchGroup>{};
    for (final c in codes) {
      final key = '${c.batchId}|${c.codeFormat}|${c.productId ?? ''}';
      final existing = map[key];
      if (existing == null) {
        map[key] = _UnitBatchGroup(
          batchId: c.batchId,
          codeFormat: c.codeFormat,
          productId: c.productId,
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
    final items = map.values.toList()
      ..sort((a, b) => b.generatedAt.compareTo(a.generatedAt));
    return items;
  }

  Widget _buildFormatFilter(UnitCodesState state) {
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
              _chip(
                'All',
                state.filterCodeFormat.isEmpty,
                () => context.read<UnitCodesBloc>().add(
                  const FilterUnitCodesByFormat(null),
                ),
              ),
              ...CartonCodeFormat.values.map(
                (f) => _chip(
                  f.displayName,
                  state.filterCodeFormat == f.value,
                  () => context.read<UnitCodesBloc>().add(
                    FilterUnitCodesByFormat(f.value),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _chip(String label, bool sel, VoidCallback onTap) {
    return Padding(
      padding: EdgeInsets.only(right: 8.w),
      child: ChoiceChip(
        label: Text(label),
        selected: sel,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.primary.withAlpha(30),
        backgroundColor: AppColors.surface,
        side: BorderSide(color: sel ? AppColors.primary : AppColors.border),
        labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: sel ? AppColors.primary : AppColors.textPrimary,
          fontWeight: sel ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildBatchCard(_UnitBatchGroup group) {
    final batchId = group.batchId.trim().isEmpty ? 'NO-BATCH' : group.batchId;
    final formatName = CartonCodeFormat.fromValue(group.codeFormat).displayName;
    final date = group.generatedAt.toLocal().toString().split(' ').first;
    final key = '${group.batchId}|${group.codeFormat}|${group.productId}';
    final isExpanded = _expandedBatches.contains(key);
    final sortedCodes = List<UnitCodeModel>.from(group.codes)
      ..sort((a, b) => a.code.compareTo(b.code));

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(
              () => isExpanded
                  ? _expandedBatches.remove(key)
                  : _expandedBatches.add(key),
            ),
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
            const Divider(height: 1),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              child: Table(
                columnWidths: const {
                  0: FlexColumnWidth(0.1),
                  1: FlexColumnWidth(0.3),
                  2: FlexColumnWidth(0.2),
                  3: FlexColumnWidth(0.2),
                  4: FlexColumnWidth(0.2),
                },
                children: [
                  TableRow(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: AppColors.borderColor),
                      ),
                    ),
                    children: [
                      _h('#'),
                      _h('Code'),
                      _h('Auth Code'),
                      _h('Serial'),
                      _h('Status'),
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
                        _c(
                          '${i + 1}',
                          AppColors.textSecondary,
                          FontWeight.w500,
                        ),
                        _c(sortedCodes[i].code, null, FontWeight.w600),
                        _c(
                          sortedCodes[i].authenticationCode.length > 12
                              ? '${sortedCodes[i].authenticationCode.substring(0, 12)}...'
                              : sortedCodes[i].authenticationCode,
                          null,
                          null,
                        ),
                        _c(sortedCodes[i].serialNumber, null, null),
                        _c(
                          _statusLabel(sortedCodes[i].status),
                          _statusColor(sortedCodes[i].status),
                          FontWeight.w500,
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _h(String t) => Padding(
    padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
    child: Text(
      t,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
      ),
    ),
  );
  Widget _c(String t, Color? c, FontWeight? w) => Padding(
    padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
    child: Text(
      t,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: c ?? AppColors.textPrimary,
        fontWeight: w ?? FontWeight.normal,
      ),
      overflow: TextOverflow.ellipsis,
    ),
  );
  Color _statusColor(CodeStatus s) => switch (s) {
    CodeStatus.generated => AppColors.warning,
    CodeStatus.linked => AppColors.info,
    CodeStatus.published => AppColors.success,
    CodeStatus.deactivated => AppColors.error,
    CodeStatus.expired => AppColors.textSecondary,
  };

  String _statusLabel(CodeStatus s) => switch (s) {
    CodeStatus.generated => 'Generated',
    CodeStatus.linked => 'Linked',
    CodeStatus.published => 'Published',
    CodeStatus.deactivated => 'Deactivated',
    CodeStatus.expired => 'Expired',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Unit Codes', showBackButton: true),
      body: BlocConsumer<UnitCodesBloc, UnitCodesState>(
        listener: (ctx, state) {
          if (state.status == UnitCodesStatus.exported &&
              state.exportPath != null &&
              state.exportPath!.trim().isNotEmpty) {
            final raw = state.exportPath!.trim();
            final uri = Uri.tryParse(raw);
            launchUrl(
              uri != null && uri.hasScheme
                  ? uri
                  : Uri.parse(
                      ApiEndpoints.getFullUrl(
                        raw.startsWith('/') ? raw : '/$raw',
                      ),
                    ),
              mode: LaunchMode.platformDefault,
            );
          }
        },
        builder: (ctx, state) {
          if (state.status == UnitCodesStatus.loading &&
              state.unitCodes.isEmpty)
            return const Center(child: LoadingIndicator());
          if (state.filteredUnitCodes.isEmpty) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(16.w),
                    child: custom.SearchBar(
                      onSearchChanged: (q) =>
                          context.read<UnitCodesBloc>().add(SearchUnitCodes(q)),
                      hintText: 'Search unit codes...',
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: _buildFormatFilter(state),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: EmptyState(
                      icon: Icons.qr_code_2,
                      title: 'No Unit Codes Found',
                      description: state.searchQuery.isNotEmpty
                          ? 'No matches'
                          : 'Generate unit codes for a product',
                      actionButton: PrimaryButton(
                        text: state.searchQuery.isNotEmpty
                            ? 'Clear'
                            : 'Generate',
                        onPressed: () => state.searchQuery.isNotEmpty
                            ? context.read<UnitCodesBloc>().add(
                                const SearchUnitCodes(''),
                              )
                            : context.go('/factory/codes/unit/generate'),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          final groups = _groupBatches(state.filteredUnitCodes);
          return Scrollbar(
            controller: _scrollController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 16.w, 16.w, 0),
                    child: Column(
                      children: [
                        custom.SearchBar(
                          onSearchChanged: (q) => context
                              .read<UnitCodesBloc>()
                              .add(SearchUnitCodes(q)),
                          hintText: 'Search unit codes...',
                        ),
                        SizedBox(height: 12.h),
                        _buildFormatFilter(state),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Column(
                      children: [
                        ...groups.map(
                          (g) => Padding(
                            padding: EdgeInsets.only(bottom: 12.h),
                            child: _buildBatchCard(g),
                          ),
                        ),
                        SizedBox(height: 80.h),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

@immutable
class _UnitBatchGroup {
  final String batchId, codeFormat;
  final String? productId;
  final int codeCount;
  final DateTime generatedAt;
  final bool isPushed;
  final List<UnitCodeModel> codes;
  const _UnitBatchGroup({
    required this.batchId,
    required this.codeFormat,
    required this.productId,
    required this.codeCount,
    required this.generatedAt,
    required this.isPushed,
    required this.codes,
  });
  _UnitBatchGroup copyWith({
    int? codeCount,
    DateTime? generatedAt,
    bool? isPushed,
    List<UnitCodeModel>? codes,
  }) => _UnitBatchGroup(
    batchId: batchId,
    codeFormat: codeFormat,
    productId: productId,
    codeCount: codeCount ?? this.codeCount,
    generatedAt: generatedAt ?? this.generatedAt,
    isPushed: isPushed ?? this.isPushed,
    codes: codes ?? this.codes,
  );
}
