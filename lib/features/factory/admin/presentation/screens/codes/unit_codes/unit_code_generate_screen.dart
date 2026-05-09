import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nexatrace_system/features/factory/admin/presentation/bloc/codes/unit_codes/unit_codes_bloc.dart';
import 'package:nexatrace_system/features/factory/admin/presentation/bloc/products/products_bloc.dart';
import 'package:nexatrace_system/shared/models/code/base_code_model.dart';
import 'package:nexatrace_system/shared/models/code/code_generation_request.dart';
import 'package:nexatrace_system/shared/models/product/product_model.dart';
import 'package:nexatrace_system/core/utils/auth_state.dart';
import 'package:nexatrace_system/shared/theme/colors.dart';
import 'package:nexatrace_system/shared/widgets/app_bars/custom_app_bar.dart';
import 'package:nexatrace_system/shared/widgets/buttons/primary_button.dart';
import 'package:nexatrace_system/shared/widgets/dialogs/code_generation_success_dialog.dart';
import 'package:nexatrace_system/shared/widgets/inputs/custom_text_field.dart';
import 'package:nexatrace_system/shared/widgets/loading/loading_indicator.dart';

class UnitCodeGenerateScreen extends StatefulWidget {
  const UnitCodeGenerateScreen({super.key});
  @override
  State<UnitCodeGenerateScreen> createState() => _UnitCodeGenerateScreenState();
}

class _UnitCodeGenerateScreenState extends State<UnitCodeGenerateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _countCtrl = TextEditingController(text: '10');
  final _prefixCtrl = TextEditingController(text: 'U');
  final _batchNameCtrl = TextEditingController();
  final _warrantyCtrl = TextEditingController();
  final _countFormatter = TextEditingController();

  ProductModel? _selectedProduct;
  CartonCodeFormat _selectedFormat = CartonCodeFormat.qr;
  DateTime? _mfgDate;
  DateTime? _expDate;

  @override
  void initState() {
    super.initState();
    context.read<ProductsBloc>().add(const LoadProducts());
  }

  @override
  void dispose() {
    _countCtrl.dispose();
    _prefixCtrl.dispose();
    _batchNameCtrl.dispose();
    _warrantyCtrl.dispose();
    _countFormatter.dispose();
    super.dispose();
  }

  bool get _isAuthCode => _selectedFormat.value == 'auth_code';
  bool get _showFoodFields =>
      _selectedProduct?.requiresManufacturingDate == true ||
      _selectedProduct?.requiresExpiryDate == true;
  bool get _showWarrantyField => _selectedProduct?.requiresWarranty == true;

  void _generate() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a product'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    final request = UnitCodeGenerationRequest(
      factoryId: getFactoryId() ?? '',
      subscriptionPlanId: '',
      count: int.parse(_countCtrl.text),
      prefix: _prefixCtrl.text.trim(),
      packetCode: '',
      batchName: _batchNameCtrl.text.trim().isEmpty
          ? null
          : _batchNameCtrl.text.trim(),
      codeFormat: _selectedFormat.value,
    );
    context.read<UnitCodesBloc>().add(
      GenerateUnitCodes(
        request,
        productId: _selectedProduct?.id,
        manufacturingDate: _showFoodFields
            ? _mfgDate?.toIso8601String().split('T').first
            : null,
        expiryDate: _showFoodFields
            ? _expDate?.toIso8601String().split('T').first
            : null,
        warrantyMonths: _showWarrantyField
            ? int.tryParse(_warrantyCtrl.text)
            : null,
      ),
    );
  }

  void _showSuccess(int count) {
    showDialog(
      context: context,
      builder: (ctx) => CodeGenerationSuccessDialog(
        title: 'Unit Codes Generated',
        content:
            'Successfully generated $count ${_selectedFormat.displayName} unit codes for ${_selectedProduct?.name ?? 'product'}.',
        onOk: () => Navigator.pop(ctx),
        onViewCodes: () {
          Navigator.pop(ctx);
          context.go('/factory/codes/unit');
        },
      ),
    );
  }

  // ── Product Dropdown ────────────────────────────────────────────

  Widget _buildProductSelector(List<ProductModel> products) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Product',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(color: AppColors.primary),
            ),
            SizedBox(height: 12.h),
            DropdownButtonFormField<ProductModel>(
              initialValue: _selectedProduct,
              decoration: const InputDecoration(
                labelText: 'Select Product',
                border: OutlineInputBorder(),
              ),
              items: products
                  .map(
                    (p) => DropdownMenuItem(
                      value: p,
                      child: Text(p.name, overflow: TextOverflow.ellipsis),
                    ),
                  )
                  .toList(),
              onChanged: (p) => setState(() => _selectedProduct = p),
            ),
          ],
        ),
      ),
    );
  }

  // ── Dynamic Metadata ────────────────────────────────────────────

  Widget _buildMetadataSection() {
    if (_selectedProduct == null || (!_showFoodFields && !_showWarrantyField))
      return const SizedBox.shrink();
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Product Metadata',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(color: AppColors.primary),
            ),
            SizedBox(height: 12.h),
            if (_showFoodFields) ...[
              Row(
                children: [
                  Expanded(
                    child: _datePicker(
                      'MFG Date',
                      _mfgDate,
                      (d) => setState(() => _mfgDate = d),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _datePicker(
                      'EXP Date',
                      _expDate,
                      (d) => setState(() => _expDate = d),
                    ),
                  ),
                ],
              ),
            ],
            if (_showWarrantyField) ...[
              SizedBox(height: _showFoodFields ? 12.h : 0),
              CustomTextField(
                controller: _warrantyCtrl,
                labelText: 'Warranty (months)',
                hintText: 'e.g., 24',
                keyboardType: TextInputType.number,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _datePicker(
    String label,
    DateTime? value,
    Function(DateTime) onPicked,
  ) {
    return InkWell(
      onTap: () async {
        final d = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2035),
        );
        if (d != null) onPicked(d);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        child: Text(
          value != null
              ? '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}'
              : 'Select date',
        ),
      ),
    );
  }

  // ── Format Selector ─────────────────────────────────────────────

  Widget _buildFormatSelector() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Code Format',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(color: AppColors.primary),
            ),
            SizedBox(height: 4.h),
            Text(
              'Select ONE format for this batch',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
            SizedBox(height: 12.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: CartonCodeFormat.values.map((f) {
                final sel = _selectedFormat.value == f.value;
                return ChoiceChip(
                  label: Text(
                    f.value == 'auth_code' ? '🔒 Auth Code' : f.displayName,
                  ),
                  selected: sel,
                  onSelected: (_) => setState(() => _selectedFormat = f),
                  selectedColor: AppColors.primary.withAlpha(30),
                  backgroundColor: AppColors.surface,
                  side: BorderSide(
                    color: sel ? AppColors.primary : AppColors.border,
                    width: sel ? 2 : 1,
                  ),
                  labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: sel ? AppColors.primary : AppColors.textPrimary,
                    fontWeight: sel ? FontWeight.w600 : FontWeight.normal,
                  ),
                  avatar: sel
                      ? Icon(
                          Icons.check_circle,
                          size: 18,
                          color: AppColors.primary,
                        )
                      : Icon(
                          _fmtIcon(f.value),
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                );
              }).toList(),
            ),
            // Add Auth Code as extra chip
            SizedBox(height: 4.h),
            ChoiceChip(
              label: const Text('🔒 Auth Code (Anti-Counterfeit)'),
              selected: _isAuthCode,
              onSelected: (_) => setState(
                () => _selectedFormat = CartonCodeFormat.fromValue('auth_code'),
              ),
              selectedColor: AppColors.error.withAlpha(30),
              backgroundColor: AppColors.surface,
              side: BorderSide(
                color: _isAuthCode ? AppColors.error : AppColors.border,
                width: _isAuthCode ? 2 : 1,
              ),
              labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: _isAuthCode ? AppColors.error : AppColors.textPrimary,
                fontWeight: _isAuthCode ? FontWeight.w600 : FontWeight.normal,
              ),
              avatar: _isAuthCode
                  ? Icon(Icons.security, size: 18, color: AppColors.error)
                  : Icon(
                      Icons.security,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
            ),
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(8),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: AppColors.primary.withAlpha(25)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: AppColors.primary),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      _isAuthCode
                          ? 'Anti-counterfeit code for customer verification via scan'
                          : _selectedFormat.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _fmtIcon(String f) {
    switch (f) {
      case 'itf14':
        return Icons.bar_chart;
      case 'gs1_128':
        return Icons.qr_code_scanner;
      case 'code128_industrial':
        return Icons.factory;
      case 'qr':
        return Icons.qr_code_2;
      case 'datamatrix':
        return Icons.grid_on;
      case 'code128_label':
        return Icons.label;
      default:
        return Icons.code;
    }
  }

  // ── Build ───────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocListener<UnitCodesBloc, UnitCodesState>(
      listener: (ctx, state) {
        if (state.status == UnitCodesStatus.generated)
          _showSuccess(state.generatedCount);
      },
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: CustomAppBar(
          title: 'Generate Unit Codes',
          onBackPressed: () => context.go('/factory/codes/unit'),
        ),
        body: BlocBuilder<ProductsBloc, ProductsState>(
          builder: (ctx, productState) {
            if (productState.status == ProductsStatus.loading)
              return const Center(child: LoadingIndicator());
            final products = productState.products;
            return Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.all(16.w),
                children: [
                  _buildProductSelector(products),
                  SizedBox(height: 24.h),
                  _buildMetadataSection(),
                  SizedBox(height: 24.h),
                  _buildFormatSelector(),
                  SizedBox(height: 24.h),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Generation Details',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(color: AppColors.primary),
                          ),
                          SizedBox(height: 12.h),
                          CustomTextField(
                            controller: _countCtrl,
                            labelText: 'Quantity',
                            hintText: 'e.g., 500',
                            keyboardType: TextInputType.number,
                            validator: (v) =>
                                (v == null ||
                                    v.isEmpty ||
                                    int.tryParse(v) == null)
                                ? 'Enter valid number'
                                : null,
                          ),
                          SizedBox(height: 12.h),
                          CustomTextField(
                            controller: _batchNameCtrl,
                            labelText: 'Batch Name / ID (Optional)',
                            hintText: 'e.g., Hadi-1',
                          ),
                          SizedBox(height: 12.h),
                          CustomTextField(
                            controller: _prefixCtrl,
                            labelText: 'Prefix (Optional)',
                            hintText: 'e.g., U',
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 32.h),
                  BlocBuilder<UnitCodesBloc, UnitCodesState>(
                    builder: (_, s) => s.status == UnitCodesStatus.generating
                        ? const Center(child: LoadingIndicator())
                        : PrimaryButton(
                            onPressed: _generate,
                            text:
                                'Generate ${_selectedFormat.displayName} Unit Codes',
                            icon: Icons.qr_code,
                          ),
                  ),
                  SizedBox(height: 32.h),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
