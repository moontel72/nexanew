import 'package:flutter/material.dart' hide SearchBar;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nexatrace_system/features/factory/admin/presentation/bloc/codes/unit_codes/unit_codes_bloc.dart';
import 'package:nexatrace_system/features/factory/admin/presentation/bloc/products/products_bloc.dart';
import 'package:nexatrace_system/shared/models/code/unit_code_model.dart';
import 'package:nexatrace_system/shared/models/product/product_model.dart';
import 'package:nexatrace_system/shared/theme/colors.dart';
import 'package:nexatrace_system/shared/widgets/app_bars/custom_app_bar.dart';
import 'package:nexatrace_system/shared/widgets/buttons/primary_button.dart';
import 'package:nexatrace_system/shared/widgets/cards/code_card.dart';
import 'package:nexatrace_system/shared/widgets/empty_states/empty_state_widget.dart';
import 'package:nexatrace_system/shared/widgets/loading/loading_indicator.dart';

class UnitCodesListScreen extends StatefulWidget {
  const UnitCodesListScreen({super.key});

  @override
  State<UnitCodesListScreen> createState() => _UnitCodesListScreenState();
}

class _UnitCodesListScreenState extends State<UnitCodesListScreen> {
  final ScrollController _scrollController = ScrollController();
  String? _selectedProductId;
  DateTime? _manufacturingDate;
  DateTime? _expiryDate;
  final TextEditingController _warrantyMonthsController =
      TextEditingController();
  final TextEditingController _productBatchController = TextEditingController();

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
    _warrantyMonthsController.dispose();
    _productBatchController.dispose();
    super.dispose();
  }

  void _goToGenerate() {
    context.go('/factory/codes/unit/generate');
  }

  void _resetDateToDefault({
    required bool isManufacturing,
    required ProductModel product,
  }) {
    setState(() {
      if (isManufacturing) {
        _manufacturingDate = product.defaultManufacturingDate;
      } else {
        _expiryDate = product.defaultExpiryDate;
      }
    });
  }

  void _clearDate({required bool isManufacturing}) {
    setState(() {
      if (isManufacturing) {
        _manufacturingDate = null;
      } else {
        _expiryDate = null;
      }
    });
  }

  Future<void> _pickDate({required bool isManufacturing}) async {
    final now = DateTime.now();
    final initial = (isManufacturing ? _manufacturingDate : _expiryDate) ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 10),
    );
    if (picked == null) return;
    setState(() {
      if (isManufacturing) {
        _manufacturingDate = picked;
      } else {
        _expiryDate = picked;
      }
    });
  }

  void _publishSelected({
    required ProductModel product,
    required Set<String> selectedIds,
  }) {
    if (selectedIds.isEmpty) return;

    // Use product's default dates if available and not overridden by user
    final manufacturingDate =
        _manufacturingDate ?? product.defaultManufacturingDate;
    final expiryDate = _expiryDate ?? product.defaultExpiryDate;

    if (product.requiresManufacturingDate && manufacturingDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select manufacturing date')),
      );
      return;
    }
    if (product.requiresExpiryDate && expiryDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Select expiry date')));
      return;
    }

    final warrantyMonths = product.requiresWarranty
        ? int.tryParse(_warrantyMonthsController.text.trim()) ??
              product.defaultWarrantyMonths
        : null;

    context.read<UnitCodesBloc>().add(
      PublishSelectedUnitCodes(
        productId: product.id,
        unitCodeIds: selectedIds.toList(),
        productBatchNumber: _productBatchController.text.trim().isEmpty
            ? null
            : _productBatchController.text.trim(),
        manufacturingDate: manufacturingDate,
        expiryDate: expiryDate,
        warrantyMonths: warrantyMonths,
      ),
    );
  }

  void _showDetails(UnitCodeModel unit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Unit Details',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 12.h),
                _kv('Code', unit.code),
                _kv('Status', unit.status.name),
                _kv('Product', unit.productId ?? ''),
                _kv('Serial', unit.serialNumber),
                _kv('Auth', unit.authenticationCode),
                SizedBox(height: 16.h),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(
              k,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textTertiary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              v,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
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

          final selectedIds = state.selectedUnitCodeIds;

          return Scrollbar(
            controller: _scrollController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(16.w),
                    child: BlocBuilder<ProductsBloc, ProductsState>(
                      builder: (context, productsState) {
                        final products = productsState.products;

                        if (products.isEmpty) {
                          _selectedProductId = null;
                        }

                        ProductModel? selectedProduct;
                        if (_selectedProductId != null) {
                          for (final p in products) {
                            if (p.id == _selectedProductId) {
                              selectedProduct = p;
                              break;
                            }
                          }
                        }

                        if (products.isNotEmpty && _selectedProductId == null) {
                          _selectedProductId = products.first.id;
                          if (products.first.requiresWarranty) {
                            _warrantyMonthsController.text =
                                (products.first.defaultWarrantyMonths ?? 12)
                                    .toString();
                          } else {
                            _warrantyMonthsController.text = '';
                          }
                        }

                        final canPublish =
                            selectedProduct != null &&
                            selectedIds.isNotEmpty &&
                            productsState.status != ProductsStatus.error;

                        if (productsState.status == ProductsStatus.error) {
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
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
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
                                          context.go(
                                            '/factory/products/create',
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

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
                                Text(
                                  'Publish Unit Codes (README 3I)',
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(fontWeight: FontWeight.w800),
                                ),
                                SizedBox(height: 12.h),
                                DropdownButtonFormField<String>(
                                  isExpanded: true,
                                  initialValue: selectedProduct?.id,
                                  items: products
                                      .map(
                                        (p) => DropdownMenuItem<String>(
                                          value: p.id,
                                          child: Text(
                                            '${p.name} (${p.sku})',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            softWrap: false,
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: products.isEmpty
                                      ? null
                                      : (v) {
                                          setState(() {
                                            _selectedProductId = v;
                                            final p = products.firstWhere(
                                              (x) => x.id == v,
                                              orElse: () => products.first,
                                            );
                                            _warrantyMonthsController.text =
                                                p.requiresWarranty
                                                ? (p.defaultWarrantyMonths ??
                                                          12)
                                                      .toString()
                                                : '';
                                            // Use product's default dates if available
                                            _manufacturingDate =
                                                p.defaultManufacturingDate;
                                            _expiryDate = p.defaultExpiryDate;
                                          });
                                        },
                                  decoration: InputDecoration(
                                    labelText: 'Select Product',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 12.h),
                                TextField(
                                  controller: _productBatchController,
                                  decoration: InputDecoration(
                                    labelText:
                                        'Product Batch Number (Optional)',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                  ),
                                ),
                                if (selectedProduct != null &&
                                    (selectedProduct
                                            .requiresManufacturingDate ||
                                        selectedProduct
                                            .requiresExpiryDate)) ...[
                                  SizedBox(height: 12.h),
                                  LayoutBuilder(
                                    builder: (context, constraints) {
                                      final product = selectedProduct;
                                      if (product == null) {
                                        return const SizedBox.shrink();
                                      }

                                      final isNarrow =
                                          constraints.maxWidth < 640;

                                      final mfgLabelResolved = _manufacturingDate ==
                                              null
                                          ? 'Manufacturing Date'
                                          : 'MFG: ${_manufacturingDate!.toIso8601String().split('T').first}${_manufacturingDate == product.defaultManufacturingDate ? ' (Default)' : ''}';
                                      final expLabelResolved = _expiryDate == null
                                          ? 'Expiry Date'
                                          : 'EXP: ${_expiryDate!.toIso8601String().split('T').first}${_expiryDate == product.defaultExpiryDate ? ' (Default)' : ''}';

                                      Widget dateButton({
                                        required bool show,
                                        required bool isManufacturing,
                                        required String label,
                                      }) {
                                        if (!show) {
                                          return const SizedBox.shrink();
                                        }

                                        final defaultDate = isManufacturing
                                            ? product.defaultManufacturingDate
                                            : product.defaultExpiryDate;
                                        final activeDate = isManufacturing
                                            ? _manufacturingDate
                                            : _expiryDate;

                                        final canResetToDefault =
                                            defaultDate != null &&
                                                activeDate != defaultDate;
                                        final canClear = defaultDate == null &&
                                            activeDate != null;

                                        return Row(
                                          children: [
                                            Expanded(
                                              child: OutlinedButton.icon(
                                                onPressed: () => _pickDate(
                                                  isManufacturing:
                                                      isManufacturing,
                                                ),
                                                icon: const Icon(
                                                  Icons.calendar_month,
                                                ),
                                                label: Text(
                                                  label,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  softWrap: false,
                                                ),
                                              ),
                                            ),
                                            if (canResetToDefault)
                                              IconButton(
                                                tooltip: 'Use default',
                                                onPressed: () =>
                                                    _resetDateToDefault(
                                                  isManufacturing:
                                                      isManufacturing,
                                                  product: product,
                                                ),
                                                icon: const Icon(
                                                  Icons.restart_alt,
                                                ),
                                              ),
                                            if (canClear)
                                              IconButton(
                                                tooltip: 'Clear',
                                                onPressed: () => _clearDate(
                                                  isManufacturing:
                                                      isManufacturing,
                                                ),
                                                icon: const Icon(Icons.clear),
                                              ),
                                          ],
                                        );
                                      }

                                      if (isNarrow) {
                                        return Column(
                                          children: [
                                            dateButton(
                                              show: product
                                                  .requiresManufacturingDate,
                                              isManufacturing: true,
                                              label: mfgLabelResolved,
                                            ),
                                            if (product
                                                    .requiresManufacturingDate &&
                                                product.requiresExpiryDate)
                                              SizedBox(height: 12.h),
                                            dateButton(
                                              show: product.requiresExpiryDate,
                                              isManufacturing: false,
                                              label: expLabelResolved,
                                            ),
                                          ],
                                        );
                                      }

                                      return Row(
                                        children: [
                                          if (product
                                              .requiresManufacturingDate)
                                            Expanded(
                                              child: dateButton(
                                                show: true,
                                                isManufacturing: true,
                                                label: mfgLabelResolved,
                                              ),
                                            ),
                                          if (product
                                                  .requiresManufacturingDate &&
                                              product.requiresExpiryDate)
                                            SizedBox(width: 12.w),
                                          if (product.requiresExpiryDate)
                                            Expanded(
                                              child: dateButton(
                                                show: true,
                                                isManufacturing: false,
                                                label: expLabelResolved,
                                              ),
                                            ),
                                        ],
                                      );
                                    },
                                  ),
                                  if (selectedProduct
                                              .defaultManufacturingDate !=
                                          null ||
                                      selectedProduct.defaultExpiryDate != null)
                                    Padding(
                                      padding: EdgeInsets.only(top: 8.h),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (selectedProduct
                                              .requiresManufacturingDate)
                                            Text(
                                              'MFG Default: ${selectedProduct.defaultManufacturingDate?.toIso8601String().split('T').first ?? 'None'}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                    color: AppColors.success,
                                                    fontStyle: FontStyle.italic,
                                                  ),
                                            ),
                                          if (selectedProduct.requiresExpiryDate)
                                            Text(
                                              'EXP Default: ${selectedProduct.defaultExpiryDate?.toIso8601String().split('T').first ?? 'None'}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                    color: AppColors.success,
                                                    fontStyle: FontStyle.italic,
                                                  ),
                                            ),
                                          if (selectedProduct
                                              .requiresManufacturingDate)
                                            Text(
                                              'MFG Active: ${_manufacturingDate?.toIso8601String().split('T').first ?? selectedProduct.defaultManufacturingDate?.toIso8601String().split('T').first ?? 'None'}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                    color: (_manufacturingDate !=
                                                                null &&
                                                            _manufacturingDate !=
                                                                selectedProduct
                                                                    .defaultManufacturingDate)
                                                        ? AppColors.warning
                                                        : AppColors.textSecondary,
                                                    fontStyle: FontStyle.italic,
                                                  ),
                                            ),
                                          if (selectedProduct.requiresExpiryDate)
                                            Text(
                                              'EXP Active: ${_expiryDate?.toIso8601String().split('T').first ?? selectedProduct.defaultExpiryDate?.toIso8601String().split('T').first ?? 'None'}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                    color: (_expiryDate != null &&
                                                            _expiryDate !=
                                                                selectedProduct
                                                                    .defaultExpiryDate)
                                                        ? AppColors.warning
                                                        : AppColors.textSecondary,
                                                    fontStyle: FontStyle.italic,
                                                  ),
                                            ),
                                        ],
                                      ),
                                    ),
                                ],
                                if (selectedProduct != null &&
                                    selectedProduct.requiresWarranty) ...[
                                  SizedBox(height: 12.h),
                                  TextField(
                                    controller: _warrantyMonthsController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: 'Warranty Months',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          12.r,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                                SizedBox(height: 12.h),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Selected: ${selectedIds.length}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: AppColors.textSecondary,
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                    ),
                                    PrimaryButton(
                                      onPressed: () {
                                        if (!canPublish) return;
                                        _publishSelected(
                                          product: selectedProduct!,
                                          selectedIds: selectedIds,
                                        );
                                      },
                                      text: 'Publish',
                                      icon: Icons.publish,
                                      backgroundColor: AppColors.secondary,
                                      textColor: Colors.white,
                                      isEnabled:
                                          canPublish &&
                                          state.status !=
                                              UnitCodesStatus.publishing,
                                      isLoading:
                                          state.status ==
                                          UnitCodesStatus.publishing,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Scrollbar(
                    controller: _scrollController,
                    thumbVisibility: true,
                    child: ListView.separated(
                      controller: _scrollController,
                      padding: EdgeInsets.only(
                        left: 16.w,
                        right: 16.w,
                        bottom: 16.w,
                      ),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: units.length,
                      separatorBuilder: (_, _) => SizedBox(height: 12.h),
                      itemBuilder: (context, index) {
                        final u = units[index];
                        final isSelected = selectedIds.contains(u.id);

                        return CodeCard(
                          code: u.code,
                          codeType: u.type.name,
                          status: u.status.name,
                          batchNumber: u.batchId,
                          generatedDate: u.generatedAt,
                          productName: u.productId == null
                              ? null
                              : (u.productId ?? ''),
                          actions: [
                            OutlinedButton.icon(
                              onPressed: () => _showDetails(u),
                              icon: const Icon(Icons.visibility_outlined),
                              label: const Text('View Details'),
                            ),
                            OutlinedButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Download will be added soon',
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.download_outlined),
                              label: const Text('Download'),
                            ),
                            OutlinedButton.icon(
                              onPressed: () {
                                final productsState = context
                                    .read<ProductsBloc>()
                                    .state;
                                ProductModel? selectedProduct;
                                if (_selectedProductId != null) {
                                  for (final p in productsState.products) {
                                    if (p.id == _selectedProductId) {
                                      selectedProduct = p;
                                      break;
                                    }
                                  }
                                }

                                if (selectedProduct == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Select a product first'),
                                    ),
                                  );
                                  return;
                                }

                                _publishSelected(
                                  product: selectedProduct,
                                  selectedIds: {u.id},
                                );
                              },
                              icon: const Icon(Icons.publish_outlined),
                              label: const Text('Publish'),
                            ),
                          ],
                          isSelected: isSelected,
                          onSelectedChanged: (v) {
                            context.read<UnitCodesBloc>().add(
                              SelectUnitCode(u.id, v == true),
                            );
                          },
                          onTap: () => _showDetails(u),
                        );
                      },
                    ),
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
