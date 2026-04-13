// Register Company Screen for NexaTrace System
// Allows super admin to register new companies

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nexatrace_system/core/errors/error_handler.dart';
import 'package:nexatrace_system/features/nexa_admin/presentation/bloc/plans/plan_management_bloc.dart';
import 'package:nexatrace_system/shared/theme/colors.dart';
import 'package:nexatrace_system/shared/theme/text_styles.dart';
import 'package:nexatrace_system/core/utils/string_utils.dart';
import 'package:nexatrace_system/core/services/api_service.dart';
import 'package:nexatrace_system/features/nexa_admin/data/repositories/company_management_repository.dart';
import 'package:nexatrace_system/features/nexa_admin/presentation/bloc/companies/company_register_bloc.dart';
import 'package:nexatrace_system/shared/widgets/app_bars/custom_app_bar.dart';
import 'package:nexatrace_system/shared/widgets/buttons/primary_button.dart';
import 'package:nexatrace_system/shared/widgets/inputs/custom_text_field.dart';
import 'package:nexatrace_system/shared/models/subscription/plan_model.dart';

class RegisterCompanyScreen extends StatefulWidget {
  final bool inShell;

  const RegisterCompanyScreen({super.key, this.inShell = false});

  @override
  State<RegisterCompanyScreen> createState() => _RegisterCompanyScreenState();
}

class _RegisterCompanyScreenState extends State<RegisterCompanyScreen> {
  final _formKey = GlobalKey<FormState>();
  late CompanyRegisterBloc _companyRegisterBloc;

  // Form controllers
  final _nameController = TextEditingController();
  final _registrationNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _websiteController = TextEditingController();
  final _industryController = TextEditingController();
  final _countryController = TextEditingController();
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _contactEmailController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _employeeCountController = TextEditingController();
  final _foundedDateController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _selectedStatus = 'active';
  String _selectedCompanyType = 'manufacturing';
  String? _selectedPlanId;
  String? _logoUrl;

  @override
  void initState() {
    super.initState();
    _companyRegisterBloc = CompanyRegisterBloc(
      companyRepository: CompanyManagementRepository(apiService: ApiService()),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlanManagementBloc>().add(
            const PlanManagementEvent.loadPlans(
              status: 'active',
              perPage: 100,
              sortBy: 'sort_order',
              sortOrder: 'asc',
            ),
          );
    });
  }

  @override
  void dispose() {
    _companyRegisterBloc.close();
    _nameController.dispose();
    _registrationNumberController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    _industryController.dispose();
    _countryController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    _contactPersonController.dispose();
    _contactEmailController.dispose();
    _contactPhoneController.dispose();
    _descriptionController.dispose();
    _employeeCountController.dispose();
    _foundedDateController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _companyRegisterBloc,
      child: BlocConsumer<CompanyRegisterBloc, CompanyRegisterState>(
        listener: (context, state) {
          if (state is CompanyRegisterSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Company registered successfully'),
                backgroundColor: AppColors.success,
              ),
            );
            Navigator.pop(context);
          }

          if (state is CompanyRegisterError) {
            final fieldErrors = state.fieldErrors;
            final details = (fieldErrors == null || fieldErrors.isEmpty)
                ? null
                : fieldErrors.entries
                    .take(8)
                    .map((e) => '${e.key}: ${e.value}')
                    .join('\n');

            final message = details == null
                ? state.message
                : '${state.message}\n\n$details';
            ErrorHandler.showPersistentError(
              context,
              title: 'Company Registration Error',
              message: message,
              copyText: 'Company Registration Error\n\n$message',
            );
          }
        },
        builder: (context, state) {
          final body = Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.inShell)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(Icons.arrow_back),
                                tooltip: 'Back',
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Register New Company',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                        ),
                      if (state is CompanyRegisterError &&
                          state.fieldErrors != null &&
                          state.fieldErrors!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: AppColors.error.withOpacity(0.35),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Validation Errors',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.error,
                                        ),
                                  ),
                                  const SizedBox(height: 8),
                                  for (final entry
                                      in state.fieldErrors!.entries.take(10))
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: Text(
                                        '${entry.key}: ${entry.value}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: AppColors.textSecondary,
                                            ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      _buildSectionHeader('Basic Information'),
                      const SizedBox(height: 16),
                      _buildBasicInfoSection(),
                      const SizedBox(height: 24),
                      _buildSectionHeader('Contact Information'),
                      const SizedBox(height: 16),
                      _buildContactInfoSection(),
                      const SizedBox(height: 24),
                      _buildSectionHeader('Additional Information'),
                      const SizedBox(height: 16),
                      _buildAdditionalInfoSection(),
                      const SizedBox(height: 32),
                      PrimaryButton(
                        onPressed: _submitForm,
                        text: 'Register Company',
                        isLoading: state is CompanyRegisterLoading,
                        isEnabled: state is! CompanyRegisterLoading,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          );

          if (widget.inShell) return body;

          return Scaffold(
            appBar: CustomAppBar(
              title: 'Register New Company',
              showBackButton: true,
            ),
            body: body,
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyles.titleMedium.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Company Name
            CustomTextField(
              controller: _nameController,
              labelText: 'Company Name *',
              hintText: 'Enter company name',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Company name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            CustomTextField(
              controller: _registrationNumberController,
              labelText: 'Business Registration No. *',
              hintText: 'Enter registration number',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Business registration number is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Email
            CustomTextField(
              controller: _emailController,
              labelText: 'Email Address *',
              hintText: 'Enter company email',
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Email is required';
                }
                if (!StringUtils.isValidEmail(value)) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Password
            PasswordTextField(
              controller: _passwordController,
              labelText: 'Password *',
              hintText: 'Enter initial password',
              autoValidate: true,
            ),
            const SizedBox(height: 16),

            // Confirm Password
            CustomTextField(
              controller: _confirmPasswordController,
              labelText: 'Confirm Password *',
              hintText: 'Re-enter initial password',
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please confirm password';
                }
                if (value != _passwordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            BlocBuilder<PlanManagementBloc, PlanManagementState>(
              builder: (context, planState) {
                final plans = planState.maybeWhen(
                  loaded: (plans,
                          total,
                          page,
                          perPage,
                          totalPages,
                          search,
                          type,
                          status,
                          sortBy,
                          sortOrder,
                          statistics,
                          availableFeatures) =>
                      plans,
                  orElse: () => <Plan>[],
                );
                final isLoading = planState.maybeWhen(
                  loading: () => true,
                  orElse: () => false,
                );
                final errorMessage = planState.maybeWhen(
                  error: (message, isNetworkError, isServerError,
                          isValidationError, stackTrace) =>
                      message,
                  orElse: () => null,
                );

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Subscription Plan *',
                      style: TextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedPlanId,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: AppColors.outline,
                            width: 1,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: AppColors.outline,
                            width: 1,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      items: plans
                          .map(
                            (p) => DropdownMenuItem<String>(
                              value: p.id,
                              child: Text(p.name),
                            ),
                          )
                          .toList(),
                      onChanged: isLoading
                          ? null
                          : (value) {
                              setState(() {
                                _selectedPlanId = value;
                              });
                            },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Subscription plan is required';
                        }
                        return null;
                      },
                    ),
                    if (isLoading)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: LinearProgressIndicator(),
                      ),
                    if (!isLoading && errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Failed to load plans: $errorMessage',
                                style: TextStyles.bodySmall.copyWith(
                                  color: AppColors.error,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                context.read<PlanManagementBloc>().add(
                                      const PlanManagementEvent.loadPlans(
                                        status: 'active',
                                        perPage: 100,
                                        sortBy: 'sort_order',
                                        sortOrder: 'asc',
                                      ),
                                    );
                              },
                              child: const Text('Reload'),
                            ),
                          ],
                        ),
                      ),
                    if (!isLoading && errorMessage == null && plans.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'No active plans found. Create a plan first.',
                          style: TextStyles.bodySmall.copyWith(
                            color: AppColors.warning,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Company Type *',
                  style: TextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _selectedCompanyType,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: AppColors.outline,
                        width: 1,
                      ),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: 'manufacturing', child: Text('Manufacturing')),
                    DropdownMenuItem(
                        value: 'transport', child: Text('Transport')),
                    DropdownMenuItem(
                        value: 'saas', child: Text('SaaS / Tenant')),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _selectedCompanyType = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Company type is required';
                    }
                    return null;
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            CustomTextField(
              controller: _industryController,
              labelText: 'Industry Type *',
              hintText: 'e.g., FMCG, Pharma, Logistics',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Industry type is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Phone
            CustomTextField(
              controller: _phoneController,
              labelText: 'Phone Number',
              hintText: 'Enter company phone number',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),

            // Website
            CustomTextField(
              controller: _websiteController,
              labelText: 'Website',
              hintText: 'Enter company website URL',
              keyboardType: TextInputType.url,
              validator: (value) {
                if (value == null || value.trim().isEmpty) return null;
                final v = value.trim();
                if (!v.startsWith('http://') && !v.startsWith('https://')) {
                  return 'Website must start with http:// or https://';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Status Dropdown
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status *',
                  style: TextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _selectedStatus,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: AppColors.outline,
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: AppColors.outline,
                        width: 1,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'active',
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text('Active'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'pending',
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppColors.warning,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text('Pending'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'inactive',
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppColors.error,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text('Inactive'),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedStatus = value;
                      });
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Status is required';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfoSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Contact Person
            CustomTextField(
              controller: _contactPersonController,
              labelText: 'Contact Person Name *',
              hintText: 'Enter contact person name',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Contact person name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            CustomTextField(
              controller: _contactEmailController,
              labelText: 'Contact Person Email *',
              hintText: 'Enter contact email address',
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Contact person email is required';
                }
                if (!StringUtils.isValidEmail(value)) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Contact Phone
            CustomTextField(
              controller: _contactPhoneController,
              labelText: 'Contact Person Phone *',
              hintText: 'Enter contact phone number',
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Contact person phone is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Address
            CustomTextField(
              controller: _addressController,
              labelText: 'Address',
              hintText: 'Enter company address',
              maxLines: 3,
              minLines: 2,
            ),
            const SizedBox(height: 16),

            CustomTextField(
              controller: _countryController,
              labelText: 'Country *',
              hintText: 'Enter country',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Country is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            CustomTextField(
              controller: _cityController,
              labelText: 'City *',
              hintText: 'Enter city',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'City is required';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalInfoSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Employee Count
            CustomTextField(
              controller: _employeeCountController,
              labelText: 'Employee Count',
              hintText: 'Enter number of employees',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // Founded Date
            CustomTextField(
              controller: _foundedDateController,
              labelText: 'Founded Date',
              hintText: 'YYYY-MM-DD',
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  _foundedDateController.text =
                      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                }
              },
            ),
            const SizedBox(height: 16),

            // Description
            CustomTextField(
              controller: _descriptionController,
              labelText: 'Description',
              hintText: 'Enter company description',
              maxLines: 4,
              minLines: 3,
            ),
            const SizedBox(height: 16),

            // Logo URL
            CustomTextField(
              labelText: 'Logo URL',
              hintText: 'Enter company logo URL (optional)',
              onChanged: (value) {
                setState(() {
                  _logoUrl = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      ErrorHandler.showPersistentError(
        context,
        title: 'Validation Error',
        message:
            'Please fill all required fields correctly (including password and subscription plan).',
        copyText: 'Please fill all required fields correctly.',
      );
      return;
    }

    final companyData = <String, dynamic>{
      'name': _nameController.text.trim(),
      'business_registration_number': _registrationNumberController.text.trim(),
      'company_type': _selectedCompanyType,
      'industry_type': _industryController.text.trim(),
      'email': _emailController.text.trim(),
      'status': _selectedStatus,
      'plan_id': _selectedPlanId,
      'country': _countryController.text.trim(),
      'city': _cityController.text.trim(),
      'contact_person_name': _contactPersonController.text.trim(),
      'contact_person_email': _contactEmailController.text.trim(),
      'contact_person_phone': _contactPhoneController.text.trim(),
      'employee_count': _employeeCountController.text.isNotEmpty
          ? int.tryParse(_employeeCountController.text)
          : null,
      'founded_date': _foundedDateController.text.isNotEmpty
          ? _foundedDateController.text
          : null,
      'logo_url': _logoUrl,
      'password': _passwordController.text,
    };

    final phone = _phoneController.text.trim();
    if (phone.isNotEmpty) {
      companyData['phone'] = phone;
    }

    final website = _websiteController.text.trim();
    if (website.isNotEmpty) {
      companyData['website'] = website;
    }

    final address = _addressController.text.trim();
    if (address.isNotEmpty) {
      companyData['address'] = address;
    }

    final description = _descriptionController.text.trim();
    if (description.isNotEmpty) {
      companyData['description'] = description;
    }

    _companyRegisterBloc.add(RegisterCompany(companyData: companyData));
  }
}
