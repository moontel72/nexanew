import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nexatrace_system/features/factory/admin/presentation/bloc/products/products_bloc.dart';
import 'package:nexatrace_system/shared/theme/colors.dart';
import 'package:nexatrace_system/shared/widgets/app_bars/custom_app_bar.dart';
import 'package:nexatrace_system/shared/widgets/buttons/primary_button.dart';
import 'package:nexatrace_system/shared/widgets/inputs/custom_text_field.dart';

enum ProductCategoryMode {
  foodMedical,
  nonFoodMedical,
}

class CreateProductScreen extends StatefulWidget {
  const CreateProductScreen({super.key});

  @override
  State<CreateProductScreen> createState() => _CreateProductScreenState();
}

class _CreateProductScreenState extends State<CreateProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _skuController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  final _warrantyMonthsController = TextEditingController(text: '12');

  ProductCategoryMode _mode = ProductCategoryMode.foodMedical;
  DateTime? _defaultManufacturingDate;
  DateTime? _defaultExpiryDate;

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _warrantyMonthsController.dispose();
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

  void _submit() {
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

    context.read<ProductsBloc>().add(
          CreateProduct(
            name: _nameController.text.trim(),
            sku: _skuController.text.trim(),
            description: _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
            category: _categoryController.text.trim().isEmpty
                ? null
                : _categoryController.text.trim(),
            productType: isFoodMedical ? 'food_beverage' : 'electronics',
            requiresManufacturingDate: requiresManufacturingDate,
            requiresExpiryDate: requiresExpiryDate,
            requiresWarranty: requiresWarranty,
            defaultWarrantyMonths: defaultWarrantyMonths,
            defaultManufacturingDate: _defaultManufacturingDate,
            defaultExpiryDate: _defaultExpiryDate,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: CustomAppBar(
        title: 'Create Product',
        onBackPressed: () => context.go('/factory/products'),
      ),
      body: BlocConsumer<ProductsBloc, ProductsState>(
        listener: (context, state) {
          if (state.status == ProductsStatus.created) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Product created')),
            );
            context.go('/factory/products');
          }

          if (state.status == ProductsStatus.error && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final isBusy = state.status == ProductsStatus.creating;
          return SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                            'Basic Info',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          SizedBox(height: 12.h),
                          CustomTextField(
                            controller: _nameController,
                            labelText: 'Product Name',
                            hintText: 'Example: Panadol 500mg',
                            validator: (v) {
                              if ((v ?? '').trim().isEmpty) return 'Enter product name';
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
                              if ((v ?? '').trim().length < 3) return 'SKU too short';
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
                            'Product Category (README 3M)',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
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
                            title: const Text('Non Food / Medical (Warranty Months)'),
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
                                        : () => _pickDate(isManufacturing: true),
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
                                        : () => _pickDate(isManufacturing: false),
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
                  SizedBox(
                    width: double.infinity,
                    child: PrimaryButton(
                      onPressed: _submit,
                      text: 'Create Product',
                      icon: Icons.save,
                      backgroundColor: AppColors.secondary,
                      textColor: Colors.white,
                      isEnabled: !isBusy,
                      isLoading: isBusy,
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

