// Add Bus Company Screen — Super Admin adds a new bus fleet company
// Pattern follows RegisterCompanyScreen with bus-specific fields

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:nexatrace_system/core/services/api_service.dart';
import 'package:nexatrace_system/features/nexa_admin/data/models/company/bus_company_model.dart';
import 'package:nexatrace_system/features/nexa_admin/data/repositories/company_management_repository.dart';
import 'package:nexatrace_system/features/nexa_admin/presentation/bloc/companies/company_register_bloc.dart';
import 'package:nexatrace_system/shared/theme/colors.dart';
import 'package:nexatrace_system/shared/widgets/buttons/primary_button.dart';
import 'package:nexatrace_system/shared/widgets/inputs/custom_text_field.dart';

/// Add Bus Company Screen — Super Admin registration form for bus fleet companies
class AddBusCompanyScreen extends StatefulWidget {
  final bool inShell;

  const AddBusCompanyScreen({super.key, this.inShell = false});

  @override
  State<AddBusCompanyScreen> createState() => _AddBusCompanyScreenState();
}

class _AddBusCompanyScreenState extends State<AddBusCompanyScreen> {
  final _formKey = GlobalKey<FormState>();
  late CompanyRegisterBloc _companyRegisterBloc;

  final _companyNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _registrationNumberController = TextEditingController();
  final _countryController = TextEditingController(text: 'Pakistan');
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();
  final _fleetSizeController = TextEditingController(text: '1');
  final _routeCountController = TextEditingController();
  final _websiteController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedStatus = 'active';
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _companyRegisterBloc = CompanyRegisterBloc(
      companyRepository: CompanyManagementRepository(apiService: ApiService()),
    );
  }

  @override
  void dispose() {
    _companyRegisterBloc.close();
    _companyNameController.dispose();
    _ownerNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _registrationNumberController.dispose();
    _countryController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    _fleetSizeController.dispose();
    _routeCountController.dispose();
    _websiteController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _companyRegisterBloc,
      child: BlocListener<CompanyRegisterBloc, CompanyRegisterState>(
        listener: (context, state) {
          if (state is CompanyRegisterSuccess) {
            setState(() => _isSubmitting = false);
            final name = state.company['name']?.toString() ?? 'Unknown';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Bus company "$name" created successfully!'),
                backgroundColor: AppColors.success,
              ),
            );
            _clearForm();
          } else if (state is CompanyRegisterError) {
            setState(() => _isSubmitting = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    final body = SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Form(
        key: _formKey,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              Gap(24.h),
              _companyInfoSection(),
              Gap(24.h),
              _ownerInfoSection(),
              Gap(24.h),
              _fleetSection(),
              Gap(24.h),
              _credentialsSection(),
              Gap(24.h),
              _additionalSection(),
              Gap(32.h),
              _submitButton(),
              Gap(24.h),
            ],
          ),
        ),
      ),
    );

    if (widget.inShell) return body;
    return Scaffold(
      appBar: AppBar(title: const Text('Add Bus Company')),
      body: body,
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                Icons.directions_bus,
                size: 28.w,
                color: AppColors.info,
              ),
            ),
            Gap(12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Register New Bus Company',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Create a bus fleet company account with owner credentials',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.gray600),
                  ),
                ],
              ),
            ),
          ],
        ),
        Gap(16.h),
        Divider(color: AppColors.border),
      ],
    );
  }

  Widget _sectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20.w, color: AppColors.primary),
        Gap(8.w),
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _companyInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Company Information', Icons.business),
        Gap(16.h),
        CustomTextField(
          controller: _companyNameController,
          labelText: 'Company Name *',
          hintText: 'e.g., Daewoo Express, Faisal Movers',
          prefixIcon: const Icon(Icons.directions_bus),
          validator: (v) => (v == null || v.trim().isEmpty)
              ? 'Company name is required'
              : null,
        ),
        Gap(12.h),
        CustomTextField(
          controller: _registrationNumberController,
          labelText: 'Registration Number *',
          hintText: 'e.g., SECP-12345',
          prefixIcon: const Icon(Icons.numbers),
          validator: (v) => (v == null || v.trim().isEmpty)
              ? 'Registration number is required'
              : null,
        ),
        Gap(12.h),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: _countryController,
                labelText: 'Country *',
                prefixIcon: const Icon(Icons.public),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Country is required'
                    : null,
              ),
            ),
            Gap(12.w),
            Expanded(
              child: CustomTextField(
                controller: _cityController,
                labelText: 'City *',
                prefixIcon: const Icon(Icons.location_city),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'City is required' : null,
              ),
            ),
          ],
        ),
        Gap(12.h),
        CustomTextField(
          controller: _addressController,
          labelText: 'Address',
          hintText: 'Full office/terminal address',
          prefixIcon: const Icon(Icons.location_on),
          maxLines: 2,
        ),
        Gap(12.h),
        CustomTextField(
          controller: _websiteController,
          labelText: 'Website',
          hintText: 'e.g., https://www.daewoo.com.pk',
          prefixIcon: const Icon(Icons.language),
          keyboardType: TextInputType.url,
        ),
      ],
    );
  }

  Widget _ownerInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Owner Information', Icons.person),
        Gap(16.h),
        CustomTextField(
          controller: _ownerNameController,
          labelText: 'Owner Full Name *',
          hintText: 'e.g., Ahmed Khan',
          prefixIcon: const Icon(Icons.badge),
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Owner name is required' : null,
        ),
        Gap(12.h),
        CustomTextField(
          controller: _emailController,
          labelText: 'Owner Email *',
          hintText: 'owner@buscompany.com',
          prefixIcon: const Icon(Icons.email),
          keyboardType: TextInputType.emailAddress,
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Email is required';
            if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim())) {
              return 'Enter a valid email';
            }
            return null;
          },
        ),
        Gap(12.h),
        CustomTextField(
          controller: _phoneController,
          labelText: 'Phone Number *',
          hintText: 'e.g., +92 300 1234567',
          prefixIcon: const Icon(Icons.phone),
          keyboardType: TextInputType.phone,
          validator: (v) => (v == null || v.trim().isEmpty)
              ? 'Phone number is required'
              : null,
        ),
      ],
    );
  }

  Widget _fleetSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Fleet Details', Icons.airport_shuttle),
        Gap(16.h),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: _fleetSizeController,
                labelText: 'Fleet Size',
                hintText: 'Number of buses',
                prefixIcon: const Icon(Icons.confirmation_number),
                keyboardType: TextInputType.number,
              ),
            ),
            Gap(12.w),
            Expanded(
              child: CustomTextField(
                controller: _routeCountController,
                labelText: 'Active Routes',
                hintText: 'Number of routes',
                prefixIcon: const Icon(Icons.alt_route),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        Gap(12.h),
        CustomTextField(
          controller: _descriptionController,
          labelText: 'Company Description',
          hintText: 'Brief description of the bus company services...',
          prefixIcon: const Icon(Icons.description),
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _credentialsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Login Credentials', Icons.lock),
        Gap(16.h),
        CustomTextField(
          controller: _passwordController,
          labelText: 'Password *',
          hintText: 'Minimum 8 characters',
          prefixIcon: const Icon(Icons.lock_outline),
          obscureText: true,
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Password is required';
            if (v.length < 8) return 'Password must be at least 8 characters';
            return null;
          },
        ),
        Gap(12.h),
        CustomTextField(
          controller: _confirmPasswordController,
          labelText: 'Confirm Password *',
          hintText: 'Re-enter password',
          prefixIcon: const Icon(Icons.lock),
          obscureText: true,
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Confirm your password';
            if (v != _passwordController.text) return 'Passwords do not match';
            return null;
          },
        ),
        Gap(12.h),
        Row(
          children: [
            Text(
              'Account Status: ',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Gap(8.w),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'active', label: Text('Active')),
                ButtonSegment(value: 'inactive', label: Text('Inactive')),
              ],
              selected: {_selectedStatus},
              onSelectionChanged: (v) =>
                  setState(() => _selectedStatus = v.first),
            ),
          ],
        ),
      ],
    );
  }

  Widget _additionalSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Additional Info', Icons.info_outline),
        Gap(16.h),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.info.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.info.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Icon(Icons.info, color: AppColors.info, size: 20.w),
              Gap(8.w),
              Expanded(
                child: Text(
                  'A login link will be generated for the bus company owner. '
                  'The owner can log in at /bus-fleet/login using the email '
                  'and password provided above.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.gray700),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _submitButton() {
    return SizedBox(
      width: double.infinity,
      child: PrimaryButton(
        text: _isSubmitting ? 'Registering...' : 'Register Bus Company',
        onPressed: () {
          if (!_isSubmitting) _submitForm();
        },
        isLoading: _isSubmitting,
      ),
    );
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final metadata = <String, dynamic>{
      'fleet_size': int.tryParse(_fleetSizeController.text.trim()) ?? 0,
      'active_routes': int.tryParse(_routeCountController.text.trim()) ?? 0,
      'owner_name': _ownerNameController.text.trim(),
      'company_type': busCompanyTypeId,
    };

    _companyRegisterBloc.add(
      RegisterCompany(
        companyData: {
          'name': _companyNameController.text.trim(),
          'business_registration_number': _registrationNumberController.text
              .trim(),
          'email': _emailController.text.trim(),
          'phone': _phoneController.text.trim(),
          'website': _websiteController.text.trim().isEmpty
              ? null
              : _websiteController.text.trim(),
          'country': _countryController.text.trim(),
          'city': _cityController.text.trim(),
          'address': _addressController.text.trim().isEmpty
              ? null
              : _addressController.text.trim(),
          'password': _passwordController.text,
          'company_type': busCompanyTypeId,
          'industry_type': 'transportation',
          'contact_person_name': _ownerNameController.text.trim(),
          'contact_person_email': _emailController.text.trim(),
          'contact_person_phone': _phoneController.text.trim(),
          'status': _selectedStatus,
          'description': _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          'metadata': metadata,
          'plan_id': 'basic',
        },
      ),
    );
  }

  void _clearForm() {
    _companyNameController.clear();
    _ownerNameController.clear();
    _emailController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    _phoneController.clear();
    _registrationNumberController.clear();
    _cityController.clear();
    _addressController.clear();
    _fleetSizeController.text = '1';
    _routeCountController.clear();
    _websiteController.clear();
    _descriptionController.clear();
    _formKey.currentState?.reset();
  }
}
