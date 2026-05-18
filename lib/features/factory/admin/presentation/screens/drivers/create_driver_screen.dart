import 'package:flutter/material.dart' hide SearchBar;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nexatrace_system/features/factory/admin/presentation/bloc/drivers/drivers_bloc.dart';
import 'package:nexatrace_system/shared/theme/colors.dart';
import 'package:nexatrace_system/shared/widgets/app_bars/custom_app_bar.dart';
import 'package:nexatrace_system/shared/widgets/buttons/primary_button.dart';

class CreateDriverScreen extends StatefulWidget {
  const CreateDriverScreen({super.key});
  @override
  State<CreateDriverScreen> createState() => _CreateDriverScreenState();
}

class _CreateDriverScreenState extends State<CreateDriverScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameC = TextEditingController();
  final _phoneC = TextEditingController();
  final _emailC = TextEditingController();
  final _passC = TextEditingController();
  final _licenseC = TextEditingController();
  final _plateC = TextEditingController();
  String? _vehicleType;
  DateTime? _licenseExpiry;
  bool _obscure = true;

  @override
  void dispose() {
    _nameC.dispose();
    _phoneC.dispose();
    _emailC.dispose();
    _passC.dispose();
    _licenseC.dispose();
    _plateC.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<DriversBloc>().add(
      CreateDriver(
        name: _nameC.text.trim(),
        phone: _phoneC.text.trim().isEmpty ? null : _phoneC.text.trim(),
        email: _emailC.text.trim(),
        password: _passC.text,
        licenseNumber: _licenseC.text.trim().isEmpty
            ? null
            : _licenseC.text.trim(),
        licenseExpiry: _licenseExpiry?.toIso8601String(),
        vehiclePlateNumber: _plateC.text.trim().isEmpty
            ? null
            : _plateC.text.trim(),
        vehicleType: _vehicleType,
      ),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _licenseExpiry ?? now.add(const Duration(days: 365)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 20)),
      helpText: 'Select license expiry date',
    );
    if (picked != null) {
      setState(() => _licenseExpiry = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: CustomAppBar(
        title: 'Add Driver',
        onBackPressed: () => context.go('/factory/drivers'),
      ),
      body: BlocConsumer<DriversBloc, DriversState>(
        listenWhen: (prev, curr) =>
            curr.status == DriversStatus.created ||
            curr.status == DriversStatus.error,
        listener: (context, state) {
          if (state.status == DriversStatus.created) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Driver created')));
            context.go('/factory/drivers');
          }
          if (state.status == DriversStatus.error &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final busy = state.status == DriversStatus.creating;
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
                            'Driver Details',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          SizedBox(height: 12.h),
                          _field(
                            _nameC,
                            'Name *',
                            'e.g. John Doe',
                            Icons.person_outline,
                            required: true,
                          ),
                          SizedBox(height: 12.h),
                          _field(
                            _emailC,
                            'Email *',
                            'e.g. john@factory.com',
                            Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            required: true,
                            isEmail: true,
                          ),
                          SizedBox(height: 12.h),
                          TextFormField(
                            controller: _passC,
                            decoration: InputDecoration(
                              labelText: 'Password *',
                              hintText: 'Minimum 6 characters',
                              prefixIcon: const Icon(Icons.lock_outlined),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscure
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () =>
                                    setState(() => _obscure = !_obscure),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                            obscureText: _obscure,
                            textInputAction: TextInputAction.next,
                            validator: (v) => (v ?? '').isEmpty
                                ? 'Password required'
                                : (v!.length < 6 ? 'Min 6 characters' : null),
                          ),
                          SizedBox(height: 12.h),
                          _field(
                            _phoneC,
                            'Phone',
                            'e.g. +1234567890',
                            Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                          ),
                          SizedBox(height: 12.h),
                          _field(
                            _licenseC,
                            'License Number',
                            'e.g. DL-12345678',
                            Icons.badge_outlined,
                          ),
                          SizedBox(height: 12.h),
                          TextFormField(
                            readOnly: true,
                            decoration: InputDecoration(
                              labelText: 'License Expiry Date',
                              hintText: 'Tap to select date',
                              prefixIcon: const Icon(
                                Icons.calendar_today_outlined,
                              ),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () =>
                                    setState(() => _licenseExpiry = null),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                            controller: TextEditingController(
                              text: _licenseExpiry != null
                                  ? '${_licenseExpiry!.year}-${_licenseExpiry!.month.toString().padLeft(2, '0')}-${_licenseExpiry!.day.toString().padLeft(2, '0')}'
                                  : '',
                            ),
                            onTap: _pickDate,
                          ),
                          SizedBox(height: 12.h),
                          _field(
                            _plateC,
                            'Vehicle Plate Number',
                            'e.g. ABC-1234',
                            Icons.directions_car_outlined,
                          ),
                          SizedBox(height: 12.h),
                          DropdownButtonFormField<String>(
                            initialValue: _vehicleType,
                            decoration: InputDecoration(
                              labelText: 'Vehicle Type',
                              prefixIcon: const Icon(
                                Icons.local_shipping_outlined,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                            hint: const Text('Select vehicle type'),
                            items: const [
                              DropdownMenuItem(
                                value: 'Motorcycle',
                                child: Text('Motorcycle'),
                              ),
                              DropdownMenuItem(
                                value: 'Car',
                                child: Text('Car'),
                              ),
                              DropdownMenuItem(
                                value: 'Van',
                                child: Text('Van'),
                              ),
                              DropdownMenuItem(
                                value: 'Truck',
                                child: Text('Truck'),
                              ),
                              DropdownMenuItem(
                                value: 'Other',
                                child: Text('Other'),
                              ),
                            ],
                            onChanged: (v) => setState(() => _vehicleType = v),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  SizedBox(
                    width: double.infinity,
                    child: PrimaryButton(
                      onPressed: _submit,
                      text: 'Create Driver',
                      icon: Icons.save,
                      backgroundColor: AppColors.primary,
                      textColor: Colors.white,
                      isEnabled: !busy,
                      isLoading: busy,
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

  Widget _field(
    TextEditingController c,
    String label,
    String hint,
    IconData icon, {
    TextInputType? keyboardType,
    bool required = false,
    bool isEmail = false,
  }) {
    return TextFormField(
      controller: c,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
      ),
      keyboardType: keyboardType,
      textInputAction: TextInputAction.next,
      validator: (v) {
        if (required && (v ?? '').trim().isEmpty) return '$label is required';
        if (isEmail &&
            (v ?? '').isNotEmpty &&
            !RegExp(
              r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
            ).hasMatch(v!.trim()))
          return 'Invalid email';
        return null;
      },
    );
  }
}
