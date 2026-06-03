// Add Sub-Admin Screen — Create a new sub-admin assignment
//
// Master Admin provisions a new Sub-Admin by selecting a vertical,
// filling identity details, and setting initial credentials.

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:trace_odd/core/config/api_config.dart';
import 'package:trace_odd/core/services/api_client.dart';
import 'package:trace_odd/shared/theme/colors.dart';

class AddSubAdminScreen extends StatefulWidget {
  final bool inShell;
  const AddSubAdminScreen({super.key, this.inShell = false});

  @override
  State<AddSubAdminScreen> createState() => _AddSubAdminScreenState();
}

class _AddSubAdminScreenState extends State<AddSubAdminScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _cnicController = TextEditingController();

  String _selectedVertical = 'bus_transit';
  bool _isLoading = false;
  String? _error;
  bool _obscurePassword = true;

  static const _verticals = [
    {'code': 'bus_transit', 'label': 'Bus Transit Manager', 'icon': Icons.directions_bus_rounded, 'desc': 'Public transport ecosystem: bus owners, routes, seat layouts, ticketing'},
    {'code': 'goods_logistics', 'label': 'Goods & Logistics Manager', 'icon': Icons.local_shipping_rounded, 'desc': 'Truck fleet, freight auctions, factory drivers, store keepers'},
    {'code': 'commercial_marketplace', 'label': 'Commercial Marketplace Manager', 'icon': Icons.storefront_rounded, 'desc': 'B2B marketplace, anti-counterfeit, factories, resellers, shops'},
    {'code': 'financial_auditor', 'label': 'Financial & Subscription Auditor', 'icon': Icons.account_balance_rounded, 'desc': 'Cross-vertical subscriptions, commissions, penalties, disputes'},
  ];

  static const _verticalColors = {
    'bus_transit': Color(0xFF7C3AED),
    'goods_logistics': Color(0xFFDB2777),
    'commercial_marketplace': Color(0xFF2563EB),
    'financial_auditor': Color(0xFFD97706),
  };

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _cnicController.dispose();
    super.dispose();
  }

  Future<void> _createSubAdmin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() { _isLoading = true; _error = null; });

    try {
      final api = ApiClient();
      await api.post(
        '${ApiConfig.apiBaseUrl}/admin/sub-admins/create',
        body: {
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim().toLowerCase(),
          'phone': _phoneController.text.trim(),
          'cnic': _cnicController.text.trim(),
          'vertical': _selectedVertical,
          'password': _passwordController.text,
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sub-Admin created successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        context.go('/sub-admins');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedColor = _verticalColors[_selectedVertical] ?? AppColors.primary;

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
              // ── Header ────────────────────────────────────
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: selectedColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.person_add_alt_rounded, color: AppColors.primary, size: 22),
                  ),
                  const Gap(12),
                  const Expanded(
                    child: Text(
                      'Provision Sub-Admin',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
              const Gap(6),
              const Text(
                'Assign a sub-admin to manage one of the four ecosystem verticals.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const Gap(24),

              // ── Vertical Selection ────────────────────────
              const Text('Select Vertical', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const Gap(10),
              ..._verticals.map((v) => _verticalOption(v, selectedColor)),
              const Gap(24),

              // ── Identity Fields ───────────────────────────
              const Text('Identity Details', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const Gap(10),
              _buildTextField('Full Name', _nameController, Icons.person_rounded, TextInputType.name),
              const Gap(12),
              _buildTextField('Email Address', _emailController, Icons.email_rounded, TextInputType.emailAddress),
              const Gap(12),
              _buildTextField('Phone Number', _phoneController, Icons.phone_rounded, TextInputType.phone),
              const Gap(12),
              _buildTextField('CNIC (optional)', _cnicController, Icons.credit_card_rounded, TextInputType.text, required: false),
              const Gap(24),

              // ── Credentials ───────────────────────────────
              const Text('Initial Credentials', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const Gap(10),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_rounded),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) {
                  if (v == null || v.length < 8) return 'Minimum 8 characters';
                  return null;
                },
              ),

              if (_error != null) ...[
                const Gap(16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.error, size: 18),
                      const Gap(8),
                      Expanded(child: Text(_error!, style: const TextStyle(color: AppColors.error, fontSize: 13))),
                    ],
                  ),
                ),
              ],

              const Gap(24),

              // ── Submit ────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createSubAdmin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Create Sub-Admin', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _verticalOption(Map<String, dynamic> v, Color selectedColor) {
    final code = v['code'] as String;
    final isSelected = _selectedVertical == code;
    final color = _verticalColors[code] ?? AppColors.primary;

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
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle, color: color, size: 22),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, TextInputType type, {bool required = true}) {
    return TextFormField(
      controller: controller,
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
}
