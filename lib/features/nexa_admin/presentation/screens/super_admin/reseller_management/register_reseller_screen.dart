import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nexatrace_system/features/nexa_admin/presentation/bloc/reseller_management/reseller_management_bloc.dart';
import 'package:nexatrace_system/shared/theme/colors.dart';
import 'package:nexatrace_system/shared/widgets/app_bars/custom_app_bar.dart';
import 'package:nexatrace_system/shared/widgets/buttons/primary_button.dart';

class RegisterResellerScreen extends StatefulWidget {
  final bool inShell;
  const RegisterResellerScreen({super.key, this.inShell = false});

  @override
  State<RegisterResellerScreen> createState() => _RegisterResellerScreenState();
}

class _RegisterResellerScreenState extends State<RegisterResellerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtl = TextEditingController();
  final _bizCtl = TextEditingController();
  final _regCtl = TextEditingController();
  final _emailCtl = TextEditingController();
  final _phoneCtl = TextEditingController();
  final _passwordCtl = TextEditingController();
  final _cityCtl = TextEditingController();
  final _addressCtl = TextEditingController();

  bool _submitting = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameCtl.dispose();
    _bizCtl.dispose();
    _regCtl.dispose();
    _emailCtl.dispose();
    _phoneCtl.dispose();
    _passwordCtl.dispose();
    _cityCtl.dispose();
    _addressCtl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);

    context.read<ResellerManagementBloc>().add(
      CreateReseller(
        name: _nameCtl.text.trim(),
        businessName: _bizCtl.text.trim(),
        registrationNo: _regCtl.text.trim(),
        email: _emailCtl.text.trim(),
        phone: _phoneCtl.text.trim(),
        password: _passwordCtl.text,
        city: _cityCtl.text.trim(),
        address: _addressCtl.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Register Reseller',
        showBackButton: !widget.inShell,
      ),
      body: BlocListener<ResellerManagementBloc, ResellerManagementState>(
        listener: (_, state) {
          if (state.status == ResellerLoadStatus.actionSuccess) {
            ScaffoldMessenger.of(context)
              ..clearSnackBars()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.message ?? 'Reseller created'),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            context.go('/resellers');
          }
          if (state.status == ResellerLoadStatus.error &&
              state.errorMessage != null) {
            setState(() => _submitting = false);
            ScaffoldMessenger.of(context)
              ..clearSnackBars()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
          }
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reseller Details',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Fill in the details to onboard a new reseller onto the NexaTrace Marketplace.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.gray500),
                ),
                SizedBox(height: 24.h),

                // ── Profile ───────────────────────────────────
                _sectionHeader('Profile'),
                SizedBox(height: 12.h),
                _field(
                  'Full Name *',
                  _nameCtl,
                  hint: 'Ahmed Khan',
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                SizedBox(height: 14.h),
                _field(
                  'Business Name *',
                  _bizCtl,
                  hint: 'Moon Foody Enterprises',
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                SizedBox(height: 24.h),

                // ── Business Verification ─────────────────────
                _sectionHeader('Business Verification'),
                SizedBox(height: 12.h),
                _field(
                  'Govt Registration No *',
                  _regCtl,
                  hint: 'BRN-2024-001234',
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                SizedBox(height: 4.h),
                Text(
                  'Required per B2B policy. Resellers must provide valid business proof.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.warning,
                    fontSize: 11.sp,
                  ),
                ),
                SizedBox(height: 24.h),

                // ── Login Credentials ─────────────────────────
                _sectionHeader('Login Credentials'),
                SizedBox(height: 12.h),
                _field(
                  'Email Address *',
                  _emailCtl,
                  hint: 'ahmed@moonfoody.pk',
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Required';
                    if (!v.contains('@')) return 'Invalid email';
                    return null;
                  },
                ),
                SizedBox(height: 14.h),
                TextFormField(
                  controller: _passwordCtl,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password *',
                    hintText: 'Min. 8 characters',
                    border: const OutlineInputBorder(),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 12.h,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 20.sp,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    if (v.length < 8) return 'Min. 8 characters';
                    return null;
                  },
                ),
                SizedBox(height: 4.h),
                Text(
                  'This password will be used to log in at\nhttp://135.181.46.27/reseller/login',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.gray500,
                    fontSize: 11.sp,
                  ),
                ),
                SizedBox(height: 24.h),

                // ── Contact ───────────────────────────────────
                _sectionHeader('Contact'),
                SizedBox(height: 12.h),
                _field(
                  'Phone Number *',
                  _phoneCtl,
                  hint: '+92 300 1234567',
                  keyboardType: TextInputType.phone,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                SizedBox(height: 24.h),

                // ── Location ──────────────────────────────────
                _sectionHeader('Location'),
                SizedBox(height: 12.h),
                _field(
                  'City *',
                  _cityCtl,
                  hint: 'Lahore',
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                SizedBox(height: 14.h),
                _field(
                  'Address',
                  _addressCtl,
                  hint: '123 Main Boulevard, Gulberg',
                  maxLines: 3,
                ),
                SizedBox(height: 32.h),

                // ── Submit ────────────────────────────────────
                PrimaryButton(
                  text: _submitting ? 'Registering…' : 'Register Reseller',
                  isLoading: _submitting,
                  isEnabled: !_submitting,
                  onPressed: _submit,
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController ctl, {
    String? hint,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: ctl,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      ),
      validator: validator,
    );
  }
}
