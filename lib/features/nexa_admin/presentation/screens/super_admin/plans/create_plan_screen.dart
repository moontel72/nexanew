import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nexatrace_system/core/errors/error_handler.dart';
import 'package:nexatrace_system/features/nexa_admin/presentation/bloc/plans/plan_management_bloc.dart';
import 'package:nexatrace_system/routes/app_router.dart';
import 'package:nexatrace_system/shared/theme/colors.dart';
import 'package:nexatrace_system/shared/widgets/buttons/primary_button.dart';
import 'package:nexatrace_system/shared/widgets/inputs/custom_text_field.dart';

class CreatePlanScreen extends StatefulWidget {
  final bool inShell;

  const CreatePlanScreen({super.key, this.inShell = false});

  @override
  State<CreatePlanScreen> createState() => _CreatePlanScreenState();
}

class _CreatePlanScreenState extends State<CreatePlanScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isFormValid = false;

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _currencyController = TextEditingController(text: 'USD');
  final _sortOrderController = TextEditingController(text: '0');

  final _monthlyUnitCodesController = TextEditingController();
  final _storesController = TextEditingController();
  final _driversController = TextEditingController();
  final _transportConnectionsController = TextEditingController();
  final _loadsPerMonthController = TextEditingController();

  String _type = 'basic';
  String _status = 'active';
  String _billingCycle = 'monthly';
  bool _isFeatured = false;
  bool _isPopular = false;

  final List<String> _manualFeatures = [];
  final _featureInputController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _currencyController.dispose();
    _sortOrderController.dispose();
    _monthlyUnitCodesController.dispose();
    _storesController.dispose();
    _driversController.dispose();
    _transportConnectionsController.dispose();
    _loadsPerMonthController.dispose();
    _featureInputController.dispose();
    super.dispose();
  }

  void _addFeature() {
    final feature = _featureInputController.text.trim();
    if (feature.isNotEmpty && !_manualFeatures.contains(feature)) {
      setState(() {
        _manualFeatures.add(feature);
        _featureInputController.clear();
      });
    }
  }

  void _removeFeature(String feature) {
    setState(() {
      _manualFeatures.remove(feature);
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final price = double.tryParse(_priceController.text.trim());
    if (price == null) {
      ErrorHandler.showPersistentError(
        context,
        title: 'Validation Error',
        message: 'Price must be a valid number',
        copyText:
            'Create Plan Validation Error\n\nPrice must be a valid number',
      );
      return;
    }

    final sortOrder = int.tryParse(_sortOrderController.text.trim());

    final limits = <String, dynamic>{
      if (int.tryParse(_monthlyUnitCodesController.text.trim()) != null)
        'monthly_unit_codes': int.parse(
          _monthlyUnitCodesController.text.trim(),
        ),
      if (int.tryParse(_storesController.text.trim()) != null)
        'stores': int.parse(_storesController.text.trim()),
      if (int.tryParse(_driversController.text.trim()) != null)
        'drivers': int.parse(_driversController.text.trim()),
      if (int.tryParse(_transportConnectionsController.text.trim()) != null)
        'transport_connections_per_month': int.parse(
          _transportConnectionsController.text.trim(),
        ),
      if (int.tryParse(_loadsPerMonthController.text.trim()) != null)
        'max_loads_per_month': int.parse(_loadsPerMonthController.text.trim()),
      'is_featured': _isFeatured,
      'is_popular': _isPopular,
    };

    final selectedFeatures = _manualFeatures.map((f) {
      return PlanFeatureInput(id: f, isEnabled: true);
    }).toList();

    context.read<PlanManagementBloc>().add(
      PlanManagementEvent.createPlan(
        name: _nameController.text.trim(),
        type: _type,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        price: price,
        billingCycle: _billingCycle,
        currency: _currencyController.text.trim().isEmpty
            ? 'USD'
            : _currencyController.text.trim(),
        status: _status,
        isFeatured: _isFeatured,
        isPopular: _isPopular,
        sortOrder: sortOrder,
        limits: limits,
        features: selectedFeatures.isEmpty ? null : selectedFeatures,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = BlocConsumer<PlanManagementBloc, PlanManagementState>(
      listener: (context, state) {
        state.maybeWhen(
          planCreated: (plan, message) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: AppColors.success,
              ),
            );
            context.read<PlanManagementBloc>().add(
              const PlanManagementEvent.loadPlans(
                status: 'active',
                perPage: 100,
                sortBy: 'sort_order',
                sortOrder: 'asc',
              ),
            );
            context.read<AppRouter>().goToPlans(context);
          },
          error: (message, _, _, _, _) {
            ErrorHandler.showPersistentError(
              context,
              title: 'Plan Error',
              message: message,
              copyText: 'Plan Error\n\n$message',
            );
          },
          orElse: () {},
        );
      },
      builder: (context, state) {
        final isSubmitting = state.maybeWhen(
          loading: () => true,
          orElse: () => false,
        );

        return Container(
          color: widget.inShell ? AppColors.surface : AppColors.background,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.always,
                  onChanged: () {
                    setState(() {
                      _isFormValid = _formKey.currentState?.validate() ?? false;
                    });
                  },
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
                                'Create Plan',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                        ),
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              CustomTextField(
                                controller: _nameController,
                                labelText: 'Plan Name *',
                                hintText: 'e.g., Basic Plan',
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return 'Plan name is required';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              CustomTextField(
                                controller: _descriptionController,
                                labelText: 'Description',
                                hintText: 'Short description (optional)',
                                maxLines: 3,
                                minLines: 2,
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: CustomTextField(
                                      controller: _priceController,
                                      labelText: 'Price *',
                                      hintText: 'e.g., 49',
                                      keyboardType: TextInputType.number,
                                      validator: (v) {
                                        if (v == null || v.trim().isEmpty) {
                                          return 'Price is required';
                                        }
                                        if (double.tryParse(v.trim()) == null) {
                                          return 'Enter a valid number';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: CustomTextField(
                                      controller: _currencyController,
                                      labelText: 'Currency *',
                                      hintText: 'USD',
                                      validator: (v) {
                                        if (v == null || v.trim().isEmpty) {
                                          return 'Currency is required';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      initialValue: _type,
                                      decoration: InputDecoration(
                                        labelText: 'Plan Type *',
                                        filled: true,
                                        fillColor: AppColors.surface,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          borderSide: BorderSide(
                                            color: AppColors.outline,
                                            width: 1,
                                          ),
                                        ),
                                      ),
                                      items: const [
                                        DropdownMenuItem(
                                          value: 'free',
                                          child: Text('Free'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'basic',
                                          child: Text('Basic'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'standard',
                                          child: Text('Standard'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'premium',
                                          child: Text('Premium'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'custom',
                                          child: Text('Custom'),
                                        ),
                                      ],
                                      onChanged: (v) {
                                        if (v == null) return;
                                        setState(() {
                                          _type = v;
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      initialValue: _billingCycle,
                                      decoration: InputDecoration(
                                        labelText: 'Billing Cycle *',
                                        filled: true,
                                        fillColor: AppColors.surface,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          borderSide: BorderSide(
                                            color: AppColors.outline,
                                            width: 1,
                                          ),
                                        ),
                                      ),
                                      items: const [
                                        DropdownMenuItem(
                                          value: 'monthly',
                                          child: Text('Monthly'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'quarterly',
                                          child: Text('Quarterly'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'yearly',
                                          child: Text('Yearly'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'one_time',
                                          child: Text('One Time'),
                                        ),
                                      ],
                                      onChanged: (v) {
                                        if (v == null) return;
                                        setState(() {
                                          _billingCycle = v;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      initialValue: _status,
                                      decoration: InputDecoration(
                                        labelText: 'Status *',
                                        filled: true,
                                        fillColor: AppColors.surface,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          borderSide: BorderSide(
                                            color: AppColors.outline,
                                            width: 1,
                                          ),
                                        ),
                                      ),
                                      items: const [
                                        DropdownMenuItem(
                                          value: 'active',
                                          child: Text('Active'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'inactive',
                                          child: Text('Inactive'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'archived',
                                          child: Text('Archived'),
                                        ),
                                      ],
                                      onChanged: (v) {
                                        if (v == null) return;
                                        setState(() {
                                          _status = v;
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: CustomTextField(
                                      controller: _sortOrderController,
                                      labelText: 'Sort Order',
                                      hintText: '0',
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              SwitchListTile(
                                value: _isFeatured,
                                title: const Text('Featured Plan'),
                                onChanged: (v) {
                                  setState(() {
                                    _isFeatured = v;
                                  });
                                },
                              ),
                              SwitchListTile(
                                value: _isPopular,
                                title: const Text('Popular Plan'),
                                onChanged: (v) {
                                  setState(() {
                                    _isPopular = v;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Limits',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 12),
                              CustomTextField(
                                controller: _monthlyUnitCodesController,
                                labelText: 'Monthly Unit Codes',
                                hintText: 'e.g., 50000',
                                keyboardType: TextInputType.number,
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: CustomTextField(
                                      controller: _storesController,
                                      labelText: 'Stores',
                                      hintText: 'e.g., 5',
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: CustomTextField(
                                      controller: _driversController,
                                      labelText: 'Drivers',
                                      hintText: 'e.g., 3',
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: CustomTextField(
                                      controller:
                                          _transportConnectionsController,
                                      labelText:
                                          'Transport Connections / Month',
                                      hintText: 'e.g., 10',
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: CustomTextField(
                                      controller: _loadsPerMonthController,
                                      labelText: 'Loads / Month',
                                      hintText: 'e.g., 5',
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Features (Manual Entry)',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: CustomTextField(
                                      controller: _featureInputController,
                                      labelText: 'Add Feature',
                                      hintText: 'e.g., API Access',
                                      onSubmitted: (_) => _addFeature(),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    onPressed: _addFeature,
                                    icon: const Icon(Icons.add_circle),
                                    color: AppColors.primary,
                                    iconSize: 36,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              if (_manualFeatures.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.only(top: 8),
                                  child: Text('No features added yet.'),
                                )
                              else
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: _manualFeatures.map((f) {
                                    return Chip(
                                      label: Text(f),
                                      deleteIcon: const Icon(
                                        Icons.close,
                                        size: 18,
                                      ),
                                      onDeleted: () => _removeFeature(f),
                                    );
                                  }).toList(),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      PrimaryButton(
                        text: 'Create Plan',
                        icon: Icons.save,
                        isLoading: isSubmitting,
                        isEnabled: _isFormValid,
                        onPressed: _submit,
                      ),
                      const SizedBox(height: 12),
                      PrimaryButton(
                        text: 'Back to Plans',
                        backgroundColor: AppColors.gray200,
                        textColor: AppColors.textPrimary,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    if (widget.inShell) return content;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Create Plan')),
      body: content,
    );
  }
}
