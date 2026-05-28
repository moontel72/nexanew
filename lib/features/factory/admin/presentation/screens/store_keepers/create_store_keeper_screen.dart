import 'package:flutter/material.dart' hide SearchBar;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:trace_odd/features/factory/admin/presentation/bloc/store_keepers/store_keepers_bloc.dart';
import 'package:trace_odd/shared/theme/colors.dart';
import 'package:trace_odd/shared/widgets/app_bars/custom_app_bar.dart';
import 'package:trace_odd/shared/widgets/buttons/primary_button.dart';

class CreateStoreKeeperScreen extends StatefulWidget {
  const CreateStoreKeeperScreen({super.key});
  @override
  State<CreateStoreKeeperScreen> createState() =>
      _CreateStoreKeeperScreenState();
}

class _CreateStoreKeeperScreenState extends State<CreateStoreKeeperScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameC = TextEditingController();
  final _empC = TextEditingController();
  final _phoneC = TextEditingController();
  final _emailC = TextEditingController();
  final _passC = TextEditingController();
  String? _dutyShift;
  bool _obscure = true;

  @override
  void dispose() {
    _nameC.dispose();
    _empC.dispose();
    _phoneC.dispose();
    _emailC.dispose();
    _passC.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<StoreKeepersBloc>().add(
      CreateStoreKeeper(
        name: _nameC.text.trim(),
        employeeId: _empC.text.trim().isEmpty ? null : _empC.text.trim(),
        phone: _phoneC.text.trim().isEmpty ? null : _phoneC.text.trim(),
        email: _emailC.text.trim(),
        password: _passC.text,
        dutyShift: _dutyShift,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: CustomAppBar(
        title: 'Add Store Keeper',
        onBackPressed: () => context.go('/factory/store-keepers'),
      ),
      body: BlocConsumer<StoreKeepersBloc, StoreKeepersState>(
        listenWhen: (prev, curr) =>
            curr.status == StoreKeepersStatus.created ||
            curr.status == StoreKeepersStatus.error,
        listener: (context, state) {
          if (state.status == StoreKeepersStatus.created) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Store keeper created')),
            );
            context.go('/factory/store-keepers');
          }
          if (state.status == StoreKeepersStatus.error &&
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
          final busy = state.status == StoreKeepersStatus.creating;
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
                            'Store Keeper Details',
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
                            _empC,
                            'Employee ID',
                            'e.g. EMP-001',
                            Icons.badge_outlined,
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
                          DropdownButtonFormField<String>(
                            initialValue: _dutyShift,
                            decoration: InputDecoration(
                              labelText: 'Duty Shift',
                              prefixIcon: const Icon(Icons.schedule_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                            hint: const Text('Select duty shift'),
                            items: const [
                              DropdownMenuItem(
                                value: 'Morning',
                                child: Text('Morning'),
                              ),
                              DropdownMenuItem(
                                value: 'Evening',
                                child: Text('Evening'),
                              ),
                              DropdownMenuItem(
                                value: 'Night',
                                child: Text('Night'),
                              ),
                              DropdownMenuItem(
                                value: 'General',
                                child: Text('General'),
                              ),
                            ],
                            onChanged: (v) => setState(() => _dutyShift = v),
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
                      text: 'Create Store Keeper',
                      icon: Icons.save,
                      backgroundColor: AppColors.secondary,
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
