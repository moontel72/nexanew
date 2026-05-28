import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:trace_odd/core/constants/api_endpoints.dart';
import 'package:trace_odd/core/services/api_service.dart';
import 'package:trace_odd/features/factory/admin/presentation/bloc/products/products_bloc.dart';
import 'package:trace_odd/shared/models/product/product_model.dart';
import 'package:trace_odd/shared/theme/colors.dart';
import 'package:trace_odd/shared/widgets/app_bars/custom_app_bar.dart';
import 'package:trace_odd/shared/widgets/buttons/primary_button.dart';
import 'package:trace_odd/shared/widgets/inputs/custom_text_field.dart';

enum ProductCategoryMode { foodMedical, nonFoodMedical }

class EditProductScreen extends StatefulWidget {
  final String productId;

  const EditProductScreen({super.key, required this.productId});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _skuController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  final _warrantyMonthsController = TextEditingController();
  final _unitPriceController = TextEditingController();
  final _cartonPriceController = TextEditingController();
  final _wholesalePriceController = TextEditingController();
  final _discountValueController = TextEditingController();
  final _moqController = TextEditingController();
  final _bonusThresholdController = TextEditingController();
  final _bonusQuantityController = TextEditingController();
  final _walletCreditController = TextEditingController();
  final _promoCodeController = TextEditingController();
  final _promoDiscountController = TextEditingController();

  ProductCategoryMode _mode = ProductCategoryMode.foodMedical;
  DateTime? _defaultManufacturingDate;
  DateTime? _defaultExpiryDate;

  String _currency = 'PKR';
  String _discountType = 'none';
  bool _marketplaceEnabled = false;
  final List<_VolumeTier> _volumeTiers = [];

  bool _initialized = false;
  bool _isDeleting = false;
  PlatformFile? _selectedImage;
  bool _isUploadingImage = false;
  String? _existingImageUrl;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProduct();
    });
  }

  void _loadProduct() {
    final bloc = context.read<ProductsBloc>();
    final product = bloc.state.products
        .where((p) => p.id == widget.productId)
        .firstOrNull;

    if (product == null) {
      // Product not in local list, trigger reload
      bloc.add(const LoadProducts());
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Loading product details…')));
      return;
    }

    _populateFromProduct(product);
  }

  void _populateFromProduct(ProductModel p) {
    if (_initialized) return;
    _initialized = true;

    _nameController.text = p.name;
    _skuController.text = p.sku;
    _descriptionController.text = p.description ?? '';
    _categoryController.text = p.category ?? '';

    // Product category mode
    if (p.requiresWarranty) {
      _mode = ProductCategoryMode.nonFoodMedical;
      _warrantyMonthsController.text = (p.defaultWarrantyMonths ?? 12)
          .toString();
    } else {
      _mode = ProductCategoryMode.foodMedical;
      _defaultManufacturingDate = p.defaultManufacturingDate;
      _defaultExpiryDate = p.defaultExpiryDate;
      _warrantyMonthsController.text = '12';
    }

    // Commercial pricing
    _unitPriceController.text = p.unitPrice != null
        ? p.unitPrice.toString()
        : '';
    _cartonPriceController.text = p.cartonPrice != null
        ? p.cartonPrice.toString()
        : '';
    _wholesalePriceController.text = p.wholesalePrice != null
        ? p.wholesalePrice.toString()
        : '';
    _currency = const ['PKR', 'USD', 'EUR'].contains(p.currency)
        ? p.currency
        : 'PKR';
    _discountType = p.discountType ?? 'none';
    _discountValueController.text = p.discountValue != null
        ? p.discountValue.toString()
        : '';
    _moqController.text = p.moq.toString();
    _marketplaceEnabled = p.marketplaceEnabled;
    _bonusThresholdController.text = p.bonusThreshold != null
        ? p.bonusThreshold.toString()
        : '';
    _bonusQuantityController.text = p.bonusQuantity != null
        ? p.bonusQuantity.toString()
        : '';
    _walletCreditController.text = p.walletCredit != null
        ? p.walletCredit.toString()
        : '';
    _promoCodeController.text = p.promoCode ?? '';
    _promoDiscountController.text = p.promoDiscount != null
        ? p.promoDiscount.toString()
        : '';

    // Volume tiers
    if (p.volumeDiscounts != null && p.volumeDiscounts!.isNotEmpty) {
      _volumeTiers.clear();
      for (final t in p.volumeDiscounts!) {
        _volumeTiers.add(
          _VolumeTier(
            minQty: t.minQuantity,
            discountPercent: t.discountPercent,
          ),
        );
      }
    }

    // Existing image
    _existingImageUrl = p.imageUrl;

    setState(() {});
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _warrantyMonthsController.dispose();
    _unitPriceController.dispose();
    _cartonPriceController.dispose();
    _wholesalePriceController.dispose();
    _discountValueController.dispose();
    _moqController.dispose();
    _bonusThresholdController.dispose();
    _bonusQuantityController.dispose();
    _walletCreditController.dispose();
    _promoCodeController.dispose();
    _promoDiscountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isManufacturing}) async {
    final now = DateTime.now();
    final initial =
        (isManufacturing ? _defaultManufacturingDate : _defaultExpiryDate) ??
        now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 10),
    );
    if (picked == null) return;
    setState(() {
      if (isManufacturing) {
        _defaultManufacturingDate = picked;
      } else {
        _defaultExpiryDate = picked;
      }
    });
  }

  void _saveChanges() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final isFoodMedical = _mode == ProductCategoryMode.foodMedical;
    final requiresManufacturingDate = isFoodMedical;
    final requiresExpiryDate = isFoodMedical;
    final requiresWarranty = !isFoodMedical;
    final defaultWarrantyMonths = requiresWarranty
        ? int.tryParse(_warrantyMonthsController.text.trim())
        : null;

    if (isFoodMedical) {
      if (_defaultManufacturingDate == null || _defaultExpiryDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select Manufacturing Date and Expiry Date'),
          ),
        );
        return;
      }
    }

    String? imageUrl = _existingImageUrl;

    // Upload new image if selected
    if (_selectedImage != null) {
      setState(() => _isUploadingImage = true);
      try {
        final response = await ApiService().uploadFile(
          ApiEndpoints.fileUpload,
          _selectedImage!.path ?? '',
          'file',
          fileBytes: _selectedImage!.bytes,
          fileName: _selectedImage!.name,
        );
        final data = response is Map ? response : null;
        final uploadedUrl =
            data?['url']?.toString() ?? data?['data']?['url']?.toString();
        if (uploadedUrl != null && uploadedUrl.isNotEmpty) {
          imageUrl = uploadedUrl;
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to upload image. Please try again.'),
                backgroundColor: AppColors.error,
              ),
            );
          }
          setState(() => _isUploadingImage = false);
          return;
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Image upload failed: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        setState(() => _isUploadingImage = false);
        return;
      }
      setState(() => _isUploadingImage = false);
    }

    final unitPrice = double.tryParse(_unitPriceController.text.trim());
    final cartonPrice = double.tryParse(_cartonPriceController.text.trim());
    final wholesalePrice = double.tryParse(
      _wholesalePriceController.text.trim(),
    );
    final discountValue = double.tryParse(_discountValueController.text.trim());
    final moq = int.tryParse(_moqController.text.trim()) ?? 1;
    final bonusThreshold = int.tryParse(_bonusThresholdController.text.trim());
    final bonusQuantity = int.tryParse(_bonusQuantityController.text.trim());
    final walletCredit = double.tryParse(_walletCreditController.text.trim());
    final promoDiscount = double.tryParse(_promoDiscountController.text.trim());

    final volumeDiscounts = _volumeTiers
        .map(
          (t) => <String, dynamic>{
            'min_qty': t.minQty,
            'discount_percent': t.discountPercent,
          },
        )
        .toList();

    context.read<ProductsBloc>().add(
      UpdateProduct(
        id: widget.productId,
        name: _nameController.text.trim(),
        sku: _skuController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        category: _categoryController.text.trim().isEmpty
            ? null
            : _categoryController.text.trim(),
        productType: isFoodMedical ? 'food_beverage' : 'electronics',
        unitPrice: unitPrice,
        cartonPrice: cartonPrice,
        wholesalePrice: wholesalePrice,
        currency: _currency,
        discountType: _discountType == 'none' ? null : _discountType,
        discountValue: _discountType != 'none' ? discountValue : null,
        moq: moq,
        marketplaceEnabled: _marketplaceEnabled,
        bonusQuantity: bonusQuantity,
        bonusThreshold: bonusThreshold,
        walletCredit: walletCredit,
        promoCode: _promoCodeController.text.trim().isEmpty
            ? null
            : _promoCodeController.text.trim(),
        promoDiscount: promoDiscount,
        volumeDiscounts: volumeDiscounts.isNotEmpty ? volumeDiscounts : null,
        imageUrl: imageUrl,
      ),
    );
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text(
          'Are you sure you want to delete "${_nameController.text.trim()}"?\n\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isDeleting = true);
      context.read<ProductsBloc>().add(DeleteProduct(widget.productId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: CustomAppBar(
        title: 'Edit Product',
        onBackPressed: () => context.go('/factory/products'),
      ),
      body: BlocConsumer<ProductsBloc, ProductsState>(
        listener: (context, state) {
          // React to product reload (after LoadProducts triggered in _loadProduct)
          if (state.status == ProductsStatus.loaded && !_initialized) {
            final p = state.products
                .where((x) => x.id == widget.productId)
                .firstOrNull;
            if (p != null) {
              _populateFromProduct(p);
            }
          }

          if (state.status == ProductsStatus.updated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  _isDeleting
                      ? 'Product deleted successfully'
                      : 'Product updated successfully',
                ),
              ),
            );
            context.go('/factory/products');
          }

          if (state.status == ProductsStatus.error &&
              state.errorMessage != null) {
            setState(() => _isDeleting = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final isBusy = state.status == ProductsStatus.updating || _isDeleting;

          if (!_initialized) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ========== Section 1: Basic Information ==========
                  Card(
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
                            '📋 Basic Information',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          SizedBox(height: 12.h),
                          CustomTextField(
                            controller: _nameController,
                            labelText: 'Product Name',
                            hintText: 'Example: Panadol 500mg',
                            validator: (v) {
                              if ((v ?? '').trim().isEmpty)
                                return 'Enter product name';
                              return null;
                            },
                          ),
                          SizedBox(height: 12.h),
                          CustomTextField(
                            controller: _skuController,
                            labelText: 'SKU',
                            hintText: 'Example: SKU-001',
                            validator: (v) {
                              if ((v ?? '').trim().isEmpty) return 'Enter SKU';
                              if ((v ?? '').trim().length < 3)
                                return 'SKU too short';
                              return null;
                            },
                          ),
                          SizedBox(height: 12.h),
                          CustomTextField(
                            controller: _categoryController,
                            labelText: 'Category (Optional)',
                            hintText: 'Example: Medicine, Food, Electronics',
                          ),
                          SizedBox(height: 12.h),
                          CustomTextField(
                            controller: _descriptionController,
                            labelText: 'Description (Optional)',
                            hintText: 'Optional',
                            maxLines: 3,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // ========== Section 2: Product Category ==========
                  Card(
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
                            '📦 Product Category',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          SizedBox(height: 12.h),
                          RadioListTile<ProductCategoryMode>(
                            value: ProductCategoryMode.foodMedical,
                            groupValue: _mode,
                            onChanged: isBusy
                                ? null
                                : (v) => setState(() {
                                    _mode = v!;
                                    _warrantyMonthsController.text = '12';
                                  }),
                            title: const Text('Food / Medical (Expiry Date)'),
                            subtitle: const Text(
                              'Requires manufacturing + expiry dates when publishing unit codes.',
                            ),
                          ),
                          RadioListTile<ProductCategoryMode>(
                            value: ProductCategoryMode.nonFoodMedical,
                            groupValue: _mode,
                            onChanged: isBusy
                                ? null
                                : (v) => setState(() {
                                    _mode = v!;
                                    _defaultManufacturingDate = null;
                                    _defaultExpiryDate = null;
                                  }),
                            title: const Text(
                              'Non Food / Medical (Warranty Months)',
                            ),
                            subtitle: const Text(
                              'Warranty starts when customer scans authenticity.',
                            ),
                          ),
                          if (_mode == ProductCategoryMode.foodMedical) ...[
                            SizedBox(height: 12.h),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: isBusy
                                        ? null
                                        : () =>
                                              _pickDate(isManufacturing: true),
                                    icon: const Icon(Icons.calendar_month),
                                    label: Text(
                                      _defaultManufacturingDate == null
                                          ? 'Manufacturing Date'
                                          : 'MFG: ${_defaultManufacturingDate!.toIso8601String().split('T').first}',
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: isBusy
                                        ? null
                                        : () =>
                                              _pickDate(isManufacturing: false),
                                    icon: const Icon(Icons.calendar_month),
                                    label: Text(
                                      _defaultExpiryDate == null
                                          ? 'Expiry Date'
                                          : 'EXP: ${_defaultExpiryDate!.toIso8601String().split('T').first}',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                          if (_mode == ProductCategoryMode.nonFoodMedical) ...[
                            SizedBox(height: 12.h),
                            CustomTextField(
                              controller: _warrantyMonthsController,
                              labelText: 'Default Warranty Months',
                              hintText: 'Example: 12',
                              keyboardType: TextInputType.number,
                              validator: (v) {
                                final parsed = int.tryParse((v ?? '').trim());
                                if (parsed == null || parsed < 0) {
                                  return 'Enter warranty months';
                                }
                                if (parsed > 240) return 'Max 240 months';
                                return null;
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // ========== Section 3: Commercial Pricing ==========
                  Card(
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
                            '💰 Commercial Pricing',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          SizedBox(height: 12.h),
                          CustomTextField(
                            controller: _unitPriceController,
                            labelText: 'Unit Price (PKR)',
                            hintText: 'e.g. 1500',
                            keyboardType: TextInputType.number,
                            prefixIcon: const Padding(
                              padding: EdgeInsets.only(left: 12),
                              child: Text(
                                'Rs.',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                          SizedBox(height: 12.h),
                          CustomTextField(
                            controller: _cartonPriceController,
                            labelText: 'Carton Price',
                            hintText: 'e.g. 12000',
                            keyboardType: TextInputType.number,
                            prefixIcon: const Padding(
                              padding: EdgeInsets.only(left: 12),
                              child: Text(
                                'Rs.',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                          SizedBox(height: 12.h),
                          CustomTextField(
                            controller: _wholesalePriceController,
                            labelText: 'Wholesale Bulk Price',
                            hintText: 'e.g. 950',
                            keyboardType: TextInputType.number,
                            prefixIcon: const Padding(
                              padding: EdgeInsets.only(left: 12),
                              child: Text(
                                'Rs.',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                          SizedBox(height: 12.h),
                          DropdownButtonFormField<String>(
                            initialValue: _currency,
                            decoration: const InputDecoration(
                              labelText: 'Currency',
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'PKR',
                                child: Text('PKR'),
                              ),
                              DropdownMenuItem(
                                value: 'USD',
                                child: Text('USD'),
                              ),
                              DropdownMenuItem(
                                value: 'EUR',
                                child: Text('EUR'),
                              ),
                            ],
                            onChanged: (v) {
                              if (v != null) setState(() => _currency = v);
                            },
                          ),
                          SizedBox(height: 12.h),
                          DropdownButtonFormField<String>(
                            initialValue: _discountType,
                            decoration: const InputDecoration(
                              labelText: 'Discount Type',
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'none',
                                child: Text('None'),
                              ),
                              DropdownMenuItem(
                                value: 'percentage',
                                child: Text('Percentage'),
                              ),
                              DropdownMenuItem(
                                value: 'fixed',
                                child: Text('Fixed Amount'),
                              ),
                            ],
                            onChanged: (v) {
                              if (v != null) {
                                setState(() {
                                  _discountType = v;
                                  if (v == 'none') {
                                    _discountValueController.clear();
                                  }
                                });
                              }
                            },
                          ),
                          if (_discountType != 'none') ...[
                            SizedBox(height: 12.h),
                            CustomTextField(
                              controller: _discountValueController,
                              labelText: _discountType == 'percentage'
                                  ? 'Discount %'
                                  : 'Discount Amount',
                              hintText: _discountType == 'percentage'
                                  ? 'e.g. 10'
                                  : 'e.g. 200',
                              keyboardType: TextInputType.number,
                            ),
                          ],
                          SizedBox(height: 12.h),
                          CustomTextField(
                            controller: _moqController,
                            labelText: 'MOQ (Minimum Order Quantity)',
                            hintText: 'Default: 1',
                            keyboardType: TextInputType.number,
                          ),
                          SizedBox(height: 12.h),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('List on Marketplace'),
                            value: _marketplaceEnabled,
                            onChanged: (v) =>
                                setState(() => _marketplaceEnabled = v),
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            'Bonus Offer (Buy X get Y free)',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  controller: _bonusThresholdController,
                                  labelText: 'Buy (Threshold)',
                                  hintText: 'e.g. 10',
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: CustomTextField(
                                  controller: _bonusQuantityController,
                                  labelText: 'Get (Free)',
                                  hintText: 'e.g. 1',
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),
                          CustomTextField(
                            controller: _walletCreditController,
                            labelText: 'Wallet Credit Points',
                            hintText: 'e.g. 50',
                            keyboardType: TextInputType.number,
                          ),
                          SizedBox(height: 12.h),
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  controller: _promoCodeController,
                                  labelText: 'Promo Code',
                                  hintText: 'e.g. SUMMER20',
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: CustomTextField(
                                  controller: _promoDiscountController,
                                  labelText: 'Promo Discount %',
                                  hintText: 'e.g. 15',
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // ========== Section 4: Volume Discounts ==========
                  Card(
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
                            '🏷 Volume Discounts',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          SizedBox(height: 12.h),
                          if (_volumeTiers.isNotEmpty) ...[
                            ...List.generate(_volumeTiers.length, (i) {
                              final tier = _volumeTiers[i];
                              return Padding(
                                padding: EdgeInsets.only(bottom: 8.h),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: CustomTextField(
                                        labelText: 'Min Qty',
                                        hintText: 'e.g. 50',
                                        keyboardType: TextInputType.number,
                                        initialValue: tier.minQty.toString(),
                                        onChanged: (v) {
                                          final parsed = int.tryParse(v);
                                          if (parsed != null) {
                                            setState(() {
                                              _volumeTiers[i] = _VolumeTier(
                                                minQty: parsed,
                                                discountPercent:
                                                    tier.discountPercent,
                                              );
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    Expanded(
                                      child: CustomTextField(
                                        labelText: 'Discount %',
                                        hintText: 'e.g. 5',
                                        keyboardType: TextInputType.number,
                                        initialValue: tier.discountPercent
                                            .toString(),
                                        onChanged: (v) {
                                          final parsed = double.tryParse(v);
                                          if (parsed != null) {
                                            setState(() {
                                              _volumeTiers[i] = _VolumeTier(
                                                minQty: tier.minQty,
                                                discountPercent: parsed,
                                              );
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                    SizedBox(width: 4.w),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.remove_circle_outline,
                                        color: AppColors.error,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _volumeTiers.removeAt(i);
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ] else
                            Padding(
                              padding: EdgeInsets.only(bottom: 8.h),
                              child: Text(
                                'No volume discount tiers added yet.',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: AppColors.textTertiary),
                              ),
                            ),
                          SizedBox(height: 4.h),
                          OutlinedButton.icon(
                            onPressed: () {
                              setState(() {
                                _volumeTiers.add(
                                  const _VolumeTier(
                                    minQty: 0,
                                    discountPercent: 0,
                                  ),
                                );
                              });
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Add Tier'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // ========== Product Image ==========
                  Card(
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
                            '🖼️ Product Image',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          SizedBox(height: 12.h),
                          GestureDetector(
                            onTap: isBusy || _isUploadingImage
                                ? null
                                : () async {
                                    final result = await FilePicker.platform
                                        .pickFiles(
                                          type: FileType.image,
                                          allowMultiple: false,
                                        );
                                    if (result != null &&
                                        result.files.isNotEmpty) {
                                      setState(() {
                                        _selectedImage = result.files.first;
                                      });
                                    }
                                  },
                            child: Container(
                              width: double.infinity,
                              height: 180.h,
                              decoration: BoxDecoration(
                                color: AppColors.gray50,
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: AppColors.border,
                                  width: 1.5,
                                ),
                              ),
                              child:
                                  _selectedImage != null &&
                                      _selectedImage!.bytes != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(11.r),
                                      child: Image.memory(
                                        _selectedImage!.bytes!,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                      ),
                                    )
                                  : _existingImageUrl != null &&
                                        _existingImageUrl!.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(11.r),
                                      child: Image.network(
                                        _existingImageUrl!,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                        errorBuilder: (_, __, ___) => Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.camera_alt_outlined,
                                              size: 40.sp,
                                              color: AppColors.gray400,
                                            ),
                                            SizedBox(height: 8.h),
                                            Text(
                                              'Upload Product Image',
                                              style: TextStyle(
                                                fontSize: 13.sp,
                                                color: AppColors.gray500,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            SizedBox(height: 4.h),
                                            Text(
                                              'Tap to change image',
                                              style: TextStyle(
                                                fontSize: 11.sp,
                                                color: AppColors.gray400,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.camera_alt_outlined,
                                          size: 40.sp,
                                          color: AppColors.gray400,
                                        ),
                                        SizedBox(height: 8.h),
                                        Text(
                                          'Upload Product Image',
                                          style: TextStyle(
                                            fontSize: 13.sp,
                                            color: AppColors.gray500,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        SizedBox(height: 4.h),
                                        Text(
                                          'Tap to select an image',
                                          style: TextStyle(
                                            fontSize: 11.sp,
                                            color: AppColors.gray400,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                          if (_selectedImage != null) ...[
                            SizedBox(height: 8.h),
                            Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  size: 16.sp,
                                  color: AppColors.success,
                                ),
                                SizedBox(width: 6.w),
                                Expanded(
                                  child: Text(
                                    _selectedImage!.name,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: AppColors.textSecondary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() => _selectedImage = null);
                                  },
                                  child: Icon(
                                    Icons.close,
                                    size: 18.sp,
                                    color: AppColors.error,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // ========== Save Changes Button ==========
                  SizedBox(
                    width: double.infinity,
                    child: PrimaryButton(
                      onPressed: isBusy || _isUploadingImage
                          ? () {}
                          : _saveChanges,
                      text: 'Save Changes',
                      icon: Icons.save,
                      backgroundColor: AppColors.secondary,
                      textColor: Colors.white,
                      isEnabled: !isBusy && !_isUploadingImage,
                      isLoading:
                          (state.status == ProductsStatus.updating &&
                              !_isDeleting) ||
                          _isUploadingImage,
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // ========== Delete Button ==========
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: isBusy ? () {} : _confirmDelete,
                      icon: _isDeleting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.error,
                              ),
                            )
                          : const Icon(
                              Icons.delete_outline,
                              color: AppColors.error,
                            ),
                      label: Text(
                        _isDeleting ? 'Deleting…' : 'Delete Product',
                        style: const TextStyle(color: AppColors.error),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.error),
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 32.h),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _VolumeTier {
  final int minQty;
  final double discountPercent;

  const _VolumeTier({required this.minQty, required this.discountPercent});
}
