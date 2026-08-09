// Add Sub-Admin Screen — BLoC-driven
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:trace_odd/features/nexa_admin/presentation/bloc/sub_admin/sub_admin_bloc.dart';
import 'package:trace_odd/features/nexa_admin/presentation/bloc/sub_admin/sub_admin_event.dart';
import 'package:trace_odd/features/nexa_admin/presentation/bloc/sub_admin/sub_admin_state.dart';
import 'package:trace_odd/shared/theme/colors.dart';

class AddSubAdminScreen extends StatelessWidget {
  final bool inShell;
  const AddSubAdminScreen({super.key, this.inShell = false});

  static const _verticals = [
    {
      'code': 'bus_transit',
      'label': 'Bus Transit Manager',
      'icon': Icons.directions_bus_rounded,
      'desc':
          'Public transport ecosystem: bus owners, routes, seat layouts, ticketing',
    },
    {
      'code': 'goods_logistics',
      'label': 'Goods & Logistics Manager',
      'icon': Icons.local_shipping_rounded,
      'desc': 'Truck fleet, freight auctions, factory drivers, store keepers',
    },
    {
      'code': 'commercial_marketplace',
      'label': 'Commercial Marketplace Manager',
      'icon': Icons.storefront_rounded,
      'desc': 'B2B marketplace, anti-counterfeit, factories, resellers, shops',
    },
    {
      'code': 'financial_auditor',
      'label': 'Financial & Subscription Auditor',
      'icon': Icons.account_balance_rounded,
      'desc': 'Cross-vertical subscriptions, commissions, penalties, disputes',
    },
    {
      'code': 'cricket_ops',
      'label': 'Cricket Operations Manager',
      'icon': Icons.sports_cricket_rounded,
      'desc':
          'Live cricket streaming, tournament setup, scorekeeping, sponsors & manager provisioning',
    },
  ];
  static const _verticalColors = {
    'bus_transit': Color(0xFF7C3AED),
    'goods_logistics': Color(0xFFDB2777),
    'commercial_marketplace': Color(0xFF2563EB),
    'financial_auditor': Color(0xFFD97706),
    'cricket_ops': Color(0xFF10B981),
  };

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SubAdminBloc(),
      child: _AddSubAdminView(inShell: inShell),
    );
  }
}

class _AddSubAdminView extends StatefulWidget {
  final bool inShell;
  const _AddSubAdminView({required this.inShell});
  @override
  State<_AddSubAdminView> createState() => _AddSubAdminViewState();
}

class _AddSubAdminViewState extends State<_AddSubAdminView> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _cnicCtrl = TextEditingController();
  String _selectedVertical = 'bus_transit';
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _cnicCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedColor =
        AddSubAdminScreen._verticalColors[_selectedVertical] ??
        AppColors.primary;

    return BlocConsumer<SubAdminBloc, SubAdminState>(
      listener: (ctx, state) {
        if (state.actionSuccess != null) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(
              content: Text(state.actionSuccess!),
              backgroundColor: AppColors.success,
            ),
          );
          ctx.read<SubAdminBloc>().add(const ClearSubAdminError());
          ctx.go('/sub-admins');
        }
        if (state.actionError != null) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(
              content: Text(state.actionError!),
              backgroundColor: AppColors.error,
            ),
          );
          ctx.read<SubAdminBloc>().add(const ClearSubAdminError());
        }
      },
      builder: (ctx, state) {
        final bloc = ctx.read<SubAdminBloc>();
        return Scaffold(
          backgroundColor: AppColors.adminContentBackground,
          appBar: widget.inShell
              ? null
              : AppBar(
                  title: const Text('Add Sub-Admin'),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: selectedColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.person_add_alt_rounded,
                          color: AppColors.primary,
                          size: 22,
                        ),
                      ),
                      const Gap(12),
                      const Expanded(
                        child: Text(
                          'Provision Sub-Admin',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Gap(6),
                  const Text(
                    const Text('Assign a sub-admin to manage one of the five ecosystem verticals.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Gap(24),
                  const Text(
                    'Select Vertical',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  const Gap(10),
                  ...AddSubAdminScreen._verticals.map(
                    (v) => _verticalOption(v, selectedColor),
                  ),
                  const Gap(24),
                  const Text(
                    'Identity Details',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  const Gap(10),
                  _field(
                    'Full Name',
                    _nameCtrl,
                    Icons.person_rounded,
                    TextInputType.name,
                  ),
                  const Gap(12),
                  _field(
                    'Email Address',
                    _emailCtrl,
                    Icons.email_rounded,
                    TextInputType.emailAddress,
                  ),
                  const Gap(12),
                  _field(
                    'Phone Number',
                    _phoneCtrl,
                    Icons.phone_rounded,
                    TextInputType.phone,
                  ),
                  const Gap(12),
                  _field(
                    'CNIC (optional)',
                    _cnicCtrl,
                    Icons.credit_card_rounded,
                    TextInputType.text,
                    required: false,
                  ),
                  const Gap(24),
                  const Text(
                    'Initial Credentials',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  const Gap(10),
                  TextFormField(
                    controller: _passwordCtrl,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_rounded),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (v) => (v == null || v.length < 8)
                        ? 'Minimum 8 characters'
                        : null,
                  ),
                  if (state.busFormError != null) ...[
                    const Gap(14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.error.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: AppColors.error,
                            size: 18,
                          ),
                          const Gap(8),
                          Expanded(
                            child: Text(
                              state.busFormError!,
                              style: const TextStyle(
                                color: AppColors.error,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const Gap(22),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: state.actionLoading
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                bloc.add(
                                  CreateSubAdmin(
                                    name: _nameCtrl.text.trim(),
                                    email: _emailCtrl.text.trim().toLowerCase(),
                                    phone: _phoneCtrl.text.trim(),
                                    cnic: _cnicCtrl.text.trim(),
                                    vertical: _selectedVertical,
                                    password: _passwordCtrl.text,
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: state.actionLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Create Sub-Admin',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _verticalOption(Map<String, dynamic> v, Color selectedColor) {
    final code = v['code'] as String;
    final isSelected = _selectedVertical == code;
    final color = AddSubAdminScreen._verticalColors[code] ?? AppColors.primary;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: isSelected ? 2 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? color : AppColors.border,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => setState(() => _selectedVertical = code),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(v['icon'] as IconData, color: color, size: 20),
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      v['label'] as String,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? color : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      v['desc'] as String,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected) Icon(Icons.check_circle, color: color, size: 22),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController ctrl,
    IconData icon,
    TextInputType type, {
    bool required = true,
  }) => TextFormField(
    controller: ctrl,
    keyboardType: type,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    ),
    validator: required
        ? (v) => (v == null || v.trim().isEmpty) ? '$label is required' : null
        : null,
  );
}
