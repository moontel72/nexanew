import 'package:flutter/material.dart' hide SearchBar;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nexatrace_system/features/factory/admin/presentation/bloc/codes/unit_codes/unit_codes_bloc.dart';
import 'package:nexatrace_system/features/factory/admin/presentation/bloc/products/products_bloc.dart';
import 'package:nexatrace_system/shared/models/code/base_code_model.dart';
import 'package:nexatrace_system/shared/models/code/unit_code_model.dart';
import 'package:nexatrace_system/shared/models/product/product_model.dart';
import 'package:nexatrace_system/core/config/api_config.dart';
import 'package:nexatrace_system/shared/theme/colors.dart';
import 'package:nexatrace_system/shared/widgets/app_bars/custom_app_bar.dart';
import 'package:nexatrace_system/shared/widgets/buttons/primary_button.dart';
import 'package:nexatrace_system/shared/widgets/empty_states/empty_state_widget.dart';
import 'package:nexatrace_system/shared/widgets/loading/loading_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

class UnitCodesListScreen extends StatefulWidget {
  const UnitCodesListScreen({super.key});

  @override
  State<UnitCodesListScreen> createState() => _UnitCodesListScreenState();
}

class _BatchDraft {
  String? productId;
  DateTime? mfgOverride;
  DateTime? expOverride;
  final TextEditingController warrantyMonthsController = TextEditingController();
  final TextEditingController productBatchController = TextEditingController();

  void dispose() {
    warrantyMonthsController.dispose();
    productBatchController.dispose();
  }
}

class _UnitCodesListScreenState extends State<UnitCodesListScreen> {
  final ScrollController _scrollController = ScrollController();
  final Map<String, _BatchDraft> _batchDrafts = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UnitCodesBloc>().add(const LoadUnitCodes());
      context.read<ProductsBloc>().add(const LoadProducts());
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    for (final draft in _batchDrafts.values) {
      draft.dispose();
    }
    super.dispose();
  }

  void _goToGenerate() {
    context.go('/factory/codes/unit/generate');
  }

  _BatchDraft _draftForBatch(String batchName) {
    return _batchDrafts.putIfAbsent(batchName, () => _BatchDraft());
  }

  Future<void> _pickBatchDate({
    required String batchName,
    required bool isManufacturing,
  }) async {
    final draft = _draftForBatch(batchName);
    final now = DateTime.now();
    final current = isManufacturing ? draft.mfgOverride : draft.expOverride;
    final initial = current ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 10),
    );
    if (picked == null) return;
    setState(() {
      if (isManufacturing) {
        draft.mfgOverride = picked;
      } else {
        draft.expOverride = picked;
      }
    });
  }

  void _useDefaultDates({
    required String batchName,
    required bool isManufacturing,
  }) {
    final draft = _draftForBatch(batchName);
    setState(() {
      if (isManufacturing) {
        draft.mfgOverride = null;
      } else {
        draft.expOverride = null;
      }
    });
  }

  void _publishBatch({
    required String batchName,
    required List<UnitCodeModel> batchUnits,
    required ProductModel product,
  }) {
    if (batchUnits.isEmpty) return;

    final draft = _draftForBatch(batchName);
    final manufacturingDate =
        draft.mfgOverride ?? product.defaultManufacturingDate;
    final expiryDate = draft.expOverride ?? product.defaultExpiryDate;

    if (product.requiresManufacturingDate && manufacturingDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select manufacturing date')),
      );
      return;
    }
    if (product.requiresExpiryDate && expiryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select expiry date')),
      );
      return;
    }

    final warrantyMonths = product.requiresWarranty
        ? int.tryParse(draft.warrantyMonthsController.text.trim()) ??
            product.defaultWarrantyMonths
        : null;

    context.read<UnitCodesBloc>().add(
      PublishSelectedUnitCodes(
        productId: product.id,
        unitCodeIds: batchUnits.map((e) => e.id).toList(),
        productBatchNumber: draft.productBatchController.text.trim().isEmpty
            ? null
            : draft.productBatchController.text.trim(),
        manufacturingDate: manufacturingDate,
        expiryDate: expiryDate,
        warrantyMonths: warrantyMonths,
      ),
    );
  }

  void _exportBatch({
    required List<UnitCodeModel> batchUnits,
    required String format,
  }) {
    if (batchUnits.isEmpty) return;
    context.read<UnitCodesBloc>().add(
          ExportUnitCodes(batchUnits.map((e) => e.id).toList(), format),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: CustomAppBar(
        title: 'Unit Codes',
        showBackButton: false,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: PrimaryButton(
              onPressed: _goToGenerate,
              text: 'Generate',
              icon: Icons.add,
              backgroundColor: AppColors.secondary,
              textColor: Colors.white,
            ),
          ),
        ],
      ),
      body: BlocConsumer<UnitCodesBloc, UnitCodesState>(
        listener: (context, state) {
          if (state.status == UnitCodesStatus.error &&
              state.errorMessage != null) {
            final msg = state.errorMessage!.trim();
            if (msg == 'DOWNLOAD_LOCKED' || msg.startsWith('DOWNLOAD_LOCKED|')) {
              final parts = msg.split('|');
              final invoiceNumber = parts.length > 1 ? parts[1].trim() : '';
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Download Locked'),
                  content: Text(
                    invoiceNumber.isEmpty
                        ? 'Please pay the pending invoice to proceed.'
                        : 'Please pay Invoice #$invoiceNumber to proceed.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
              return;
            }

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.error,
              ),
            );
          }

          if (state.status == UnitCodesStatus.published) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Unit codes published')),
            );
          }

          if (state.status == UnitCodesStatus.exported) {
            final rawPath = (state.exportPath ?? '').trim();
            if (rawPath.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Export completed but no file path returned'),
                  backgroundColor: AppColors.error,
                ),
              );
              return;
            }

            final url = rawPath.startsWith('http')
                ? rawPath
                : '${ApiConfig.baseUrl}${rawPath.startsWith('/') ? '' : '/'}$rawPath';

            launchUrl(
              Uri.parse(url),
              mode: LaunchMode.platformDefault,
            );
          }
        },
        builder: (context, state) {
          if (state.status == UnitCodesStatus.loading ||
              state.status == UnitCodesStatus.generating) {
            return const Center(child: LoadingIndicator());
          }

          if (state.status == UnitCodesStatus.error) {
            return Center(
              child: EmptyState(
                title: 'Failed to load unit codes',
                description: state.errorMessage ?? 'Unknown error',
                icon: Icons.error_outline,
                iconColor: AppColors.error,
                actionButton: PrimaryButton(
                  text: 'Retry',
                  icon: Icons.refresh,
                  backgroundColor: AppColors.secondary,
                  textColor: Colors.white,
                  onPressed: () {
                    context.read<UnitCodesBloc>().add(const LoadUnitCodes());
                  },
                ),
              ),
            );
          }

          final units = state.filteredUnitCodes;
          if (units.isEmpty) {
            return Center(
              child: EmptyState(
                title: 'No unit codes yet',
                description:
                    'Generate unit codes to enable product authentication.',
                icon: Icons.qr_code_2,
                iconColor: AppColors.secondary,
                actionButton: PrimaryButton(
                  text: 'Generate Unit Codes',
                  icon: Icons.add,
                  backgroundColor: AppColors.secondary,
                  textColor: Colors.white,
                  onPressed: _goToGenerate,
                ),
              ),
            );
          }
          final batches = <String, List<UnitCodeModel>>{};
          for (final u in units) {
            final key = u.batchId.trim().isEmpty ? 'Unbatched' : u.batchId.trim();
            batches.putIfAbsent(key, () => []).add(u);
          }

          final batchEntries = batches.entries.toList()
            ..sort((a, b) {
              final aMax = a.value
                  .map((e) => e.generatedAt)
                  .fold<DateTime?>(null, (p, c) => p == null || c.isAfter(p) ? c : p);
              final bMax = b.value
                  .map((e) => e.generatedAt)
                  .fold<DateTime?>(null, (p, c) => p == null || c.isAfter(p) ? c : p);
              if (aMax == null && bMax == null) return 0;
              if (aMax == null) return 1;
              if (bMax == null) return -1;
              return bMax.compareTo(aMax);
            });

          return BlocBuilder<ProductsBloc, ProductsState>(
            builder: (context, productsState) {
              final products = productsState.products;
              final productsById = {
                for (final p in products) p.id: p,
              };

              return Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    children: [
                      if (productsState.status == ProductsStatus.error)
                        Padding(
                          padding: EdgeInsets.all(16.w),
                          child: Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              side: BorderSide(color: AppColors.border),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(16.w),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Products API Error',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(fontWeight: FontWeight.w800),
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    productsState.errorMessage ??
                                        'Failed to load products. Fix the backend error and retry.',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                  ),
                                  SizedBox(height: 12.h),
                                  Row(
                                    children: [
                                      PrimaryButton(
                                        text: 'Retry',
                                        icon: Icons.refresh,
                                        backgroundColor: AppColors.secondary,
                                        textColor: Colors.white,
                                        width: 140,
                                        onPressed: () {
                                          context.read<ProductsBloc>().add(
                                                const LoadProducts(),
                                              );
                                        },
                                      ),
                                      SizedBox(width: 12.w),
                                      PrimaryButton(
                                        text: 'Create Product',
                                        icon: Icons.add,
                                        backgroundColor: AppColors.primary,
                                        textColor: Colors.white,
                                        width: 180,
                                        onPressed: () {
                                          context.go('/factory/products/create');
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      if (products.isEmpty && productsState.status != ProductsStatus.loading)
                        Padding(
                          padding: EdgeInsets.all(16.w),
                          child: Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              side: BorderSide(color: AppColors.border),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(16.w),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'No products yet',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(fontWeight: FontWeight.w800),
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    'Create a product first. Each unit batch must be linked to a product before publish.',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                  ),
                                  SizedBox(height: 12.h),
                                  PrimaryButton(
                                    text: 'Create Product',
                                    icon: Icons.add,
                                    backgroundColor: AppColors.secondary,
                                    textColor: Colors.white,
                                    onPressed: () => context.go('/factory/products/create'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ListView.separated(
                        padding: EdgeInsets.only(
                          left: 16.w,
                          right: 16.w,
                          bottom: 16.w,
                        ),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: batchEntries.length,
                        separatorBuilder: (_, _) => SizedBox(height: 12.h),
                        itemBuilder: (context, index) {
                          final entry = batchEntries[index];
                          final batchName = entry.key;
                          final batchUnits = entry.value;

                          final existingProductIds = batchUnits
                              .map((e) => e.productId)
                              .whereType<String>()
                              .where((e) => e.trim().isNotEmpty)
                              .toSet();
                          final existingProductId =
                              existingProductIds.length == 1 ? existingProductIds.first : null;

                          final draft = _draftForBatch(batchName);
                          if (draft.productId == null && existingProductId != null) {
                            draft.productId = existingProductId;
                          }

                          final product = draft.productId == null
                              ? null
                              : productsById[draft.productId];

                          if (product != null) {
                            if (product.requiresWarranty &&
                                draft.warrantyMonthsController.text.trim().isEmpty) {
                              draft.warrantyMonthsController.text =
                                  (product.defaultWarrantyMonths ?? 12).toString();
                            }
                          }

                          final isBatchPublished = batchUnits.every(
                            (e) => e.status == CodeStatus.published,
                          );
                          final canPublish = product != null && !isBatchPublished;
                          final canDownload = isBatchPublished;

                          final defaultMfg = product?.defaultManufacturingDate;
                          final defaultExp = product?.defaultExpiryDate;
                          final activeMfg = draft.mfgOverride ?? defaultMfg;
                          final activeExp = draft.expOverride ?? defaultExp;

                          return Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              side: BorderSide(color: AppColors.border),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(16.w),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  LayoutBuilder(
                                    builder: (context, constraints) {
                                      final isNarrow =
                                          constraints.maxWidth < 900;

                                      final dropdown =
                                          DropdownButtonFormField<String>(
                                        key: ValueKey(
                                          'product_${batchName}_${draft.productId ?? ''}',
                                        ),
                                        isExpanded: true,
                                        initialValue: draft.productId,
                                        items: products
                                            .map(
                                              (p) => DropdownMenuItem<String>(
                                                value: p.id,
                                                child: Text(
                                                  '${p.name} (${p.sku})',
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  softWrap: false,
                                                ),
                                              ),
                                            )
                                            .toList(),
                                        onChanged: products.isEmpty
                                            ? null
                                            : (v) {
                                                setState(() {
                                                  draft.productId = v;
                                                  draft.mfgOverride = null;
                                                  draft.expOverride = null;
                                                  draft.productBatchController
                                                      .text = '';
                                                  draft.warrantyMonthsController
                                                      .text = '';
                                                });
                                              },
                                        decoration: InputDecoration(
                                          labelText: 'Product',
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12.r),
                                          ),
                                        ),
                                      );

                                      final header = Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            batchName,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            softWrap: false,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleSmall
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w800,
                                                ),
                                          ),
                                          SizedBox(height: 4.h),
                                          Text(
                                            '${batchUnits.length} unit codes',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            softWrap: false,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color:
                                                      AppColors.textSecondary,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                        ],
                                      );

                                      final statusChip = Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 10.w,
                                          vertical: 4.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: (isBatchPublished
                                                  ? AppColors.success
                                                  : AppColors.warning)
                                              .withValues(alpha: 0.12),
                                          borderRadius:
                                              BorderRadius.circular(999),
                                          border: Border.all(
                                            color: isBatchPublished
                                                ? AppColors.success
                                                : AppColors.warning,
                                          ),
                                        ),
                                        child: Text(
                                          isBatchPublished
                                              ? 'PUBLISHED'
                                              : 'GENERATED',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          softWrap: false,
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall
                                              ?.copyWith(
                                                color: isBatchPublished
                                                    ? AppColors.success
                                                    : AppColors.warning,
                                                fontWeight: FontWeight.w800,
                                              ),
                                        ),
                                      );

                                      if (isNarrow) {
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(child: header),
                                                SizedBox(width: 12.w),
                                                statusChip,
                                              ],
                                            ),
                                            SizedBox(height: 12.h),
                                            dropdown,
                                          ],
                                        );
                                      }

                                      return Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(child: header),
                                          SizedBox(width: 12.w),
                                          statusChip,
                                          SizedBox(width: 16.w),
                                          SizedBox(
                                            width: 380.w,
                                            child: dropdown,
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                  if (product == null) ...[
                                    SizedBox(height: 10.h),
                                    Text(
                                      'Select a product to link this batch before publishing.',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: AppColors.warning,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ],
                                  if (product != null &&
                                      (product.requiresManufacturingDate ||
                                          product.requiresExpiryDate)) ...[
                                    SizedBox(height: 12.h),
                                    if (product.requiresManufacturingDate)
                                      Row(
                                        children: [
                                          Expanded(
                                            child: OutlinedButton.icon(
                                              onPressed: () =>
                                                  _pickBatchDate(
                                                batchName: batchName,
                                                isManufacturing: true,
                                              ),
                                              icon: const Icon(
                                                Icons.calendar_month,
                                              ),
                                              label: Text(
                                                activeMfg == null
                                                    ? 'Manufacturing Date'
                                                    : 'MFG: ${activeMfg.toIso8601String().split('T').first}${draft.mfgOverride == null ? ' (Default)' : ' (Override)'}',
                                                maxLines: 1,
                                                overflow:
                                                    TextOverflow.ellipsis,
                                                softWrap: false,
                                              ),
                                            ),
                                          ),
                                          if (draft.mfgOverride != null)
                                            IconButton(
                                              tooltip: 'Use default',
                                              onPressed: () =>
                                                  _useDefaultDates(
                                                batchName: batchName,
                                                isManufacturing: true,
                                              ),
                                              icon: const Icon(
                                                Icons.restart_alt,
                                              ),
                                            ),
                                        ],
                                      ),
                                    if (product.requiresExpiryDate) ...[
                                      SizedBox(height: 12.h),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: OutlinedButton.icon(
                                              onPressed: () =>
                                                  _pickBatchDate(
                                                batchName: batchName,
                                                isManufacturing: false,
                                              ),
                                              icon: const Icon(
                                                Icons.calendar_month,
                                              ),
                                              label: Text(
                                                activeExp == null
                                                    ? 'Expiry Date'
                                                    : 'EXP: ${activeExp.toIso8601String().split('T').first}${draft.expOverride == null ? ' (Default)' : ' (Override)'}',
                                                maxLines: 1,
                                                overflow:
                                                    TextOverflow.ellipsis,
                                                softWrap: false,
                                              ),
                                            ),
                                          ),
                                          if (draft.expOverride != null)
                                            IconButton(
                                              tooltip: 'Use default',
                                              onPressed: () =>
                                                  _useDefaultDates(
                                                batchName: batchName,
                                                isManufacturing: false,
                                              ),
                                              icon: const Icon(
                                                Icons.restart_alt,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                    SizedBox(height: 8.h),
                                    if (product.requiresManufacturingDate)
                                      Text(
                                        'MFG Default: ${defaultMfg?.toIso8601String().split('T').first ?? 'None'}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: AppColors.success,
                                              fontStyle: FontStyle.italic,
                                            ),
                                      ),
                                    if (product.requiresExpiryDate)
                                      Text(
                                        'EXP Default: ${defaultExp?.toIso8601String().split('T').first ?? 'None'}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: AppColors.success,
                                              fontStyle: FontStyle.italic,
                                            ),
                                      ),
                                  ],
                                  if (product != null &&
                                      product.requiresWarranty) ...[
                                    SizedBox(height: 12.h),
                                    TextField(
                                      controller:
                                          draft.warrantyMonthsController,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        labelText: 'Warranty Months',
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12.r),
                                        ),
                                      ),
                                    ),
                                  ],
                                  if (product != null) ...[
                                    SizedBox(height: 12.h),
                                    TextField(
                                      controller:
                                          draft.productBatchController,
                                      decoration: InputDecoration(
                                        labelText:
                                            'Product Batch Number (Optional)',
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12.r),
                                        ),
                                      ),
                                    ),
                                  ],
                                  SizedBox(height: 12.h),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: !canDownload
                                              ? null
                                              : () => _exportBatch(
                                                    batchUnits: batchUnits,
                                                    format: 'csv',
                                                  ),
                                          icon: const Icon(
                                            Icons.download_outlined,
                                          ),
                                          label: const Text('Download Batch'),
                                        ),
                                      ),
                                      SizedBox(width: 12.w),
                                      Expanded(
                                        child: PrimaryButton(
                                          onPressed: () {
                                            if (!canPublish) return;
                                            _publishBatch(
                                              batchName: batchName,
                                              batchUnits: batchUnits,
                                              product: product,
                                            );
                                          },
                                          text: isBatchPublished
                                              ? 'Published'
                                              : 'Publish Batch',
                                          icon: Icons.publish,
                                          backgroundColor:
                                              AppColors.secondary,
                                          textColor: Colors.white,
                                          isEnabled: canPublish &&
                                              state.status !=
                                                  UnitCodesStatus.publishing,
                                          isLoading: state.status ==
                                              UnitCodesStatus.publishing,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 14.h),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Codes',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w800,
                                          ),
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: DataTable(
                                      columns: const [
                                        DataColumn(label: Text('Serial')),
                                        DataColumn(label: Text('Code')),
                                        DataColumn(
                                          label: Text('Storekeeper Code'),
                                        ),
                                        DataColumn(label: Text('Auth Code')),
                                        DataColumn(label: Text('Status')),
                                      ],
                                      rows: [
                                        for (final u in batchUnits)
                                          DataRow(
                                            cells: [
                                              DataCell(Text(u.serialNumber)),
                                              DataCell(Text(u.code)),
                                              DataCell(
                                                Text(u.storeKeeperCode),
                                              ),
                                              DataCell(
                                                Text(u.authenticationCode),
                                              ),
                                              DataCell(
                                                Text(
                                                  u.status.name.toUpperCase(),
                                                ),
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 16.h),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
