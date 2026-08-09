import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:trace_odd/core/services/api_client.dart';
import 'package:trace_odd/shared/theme/colors.dart';

/// Sub-Admin page: Add (provision) a new Cricket Operations Manager.
class CricketManagerAddPage extends StatefulWidget {
  const CricketManagerAddPage({super.key});

  @override
  State<CricketManagerAddPage> createState() => _CricketManagerAddPageState();
}

class _CricketManagerAddPageState extends State<CricketManagerAddPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;
  bool _canScore = true;
  bool _canStream = false;
  bool _canSponsor = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final api = ApiClient();
      await api.post(
        '/api/v1/cricket/admin/managers',
        body: {
          'name': _nameCtrl.text.trim(),
          'email': _emailCtrl.text.trim(),
          'phone': _phoneCtrl.text.trim(),
          'password': _passwordCtrl.text,
          'permissions': {
            'can_manage_scores': _canScore,
            'can_manage_streams': _canStream,
            'can_manage_sponsors': _canSponsor,
          },
        },
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cricket Operations Manager created.'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/sub-admin/cricket/managers');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.adminContentBackground,
      appBar: AppBar(
        title: const Text('Add Operations Manager'),
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
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF059669)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.person_add, color: Colors.white, size: 28),
                    Gap(12),
                    Expanded(
                      child: Text(
                        'Provision a Cricket Operations Manager who will handle tournament setup, live scoring, and streaming during matches.',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(24),

              const Text(
                'Account Details',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Gap(12),
              _field('Full Name', _nameCtrl, Icons.person, TextInputType.name),
              const Gap(12),
              _field(
                'Email Address',
                _emailCtrl,
                Icons.email,
                TextInputType.emailAddress,
              ),
              const Gap(12),
              _field(
                'Phone Number',
                _phoneCtrl,
                Icons.phone,
                TextInputType.phone,
                required: false,
              ),
              const Gap(12),
              _field(
                'Password',
                _passwordCtrl,
                Icons.lock,
                TextInputType.visiblePassword,
                validator: (v) =>
                    (v == null || v.length < 8) ? 'Minimum 8 characters' : null,
              ),
              const Gap(24),

              const Text(
                'Permissions',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Gap(8),
              SwitchListTile(
                title: const Text(
                  'Can manage live scores',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: const Text(
                  'Update runs, wickets, extras during matches',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
                value: _canScore,
                activeColor: const Color(0xFF10B981),
                onChanged: (v) => setState(() => _canScore = v),
              ),
              SwitchListTile(
                title: const Text(
                  'Can manage streams',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: const Text(
                  'Activate/deactivate camera feeds',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
                value: _canStream,
                activeColor: const Color(0xFF10B981),
                onChanged: (v) => setState(() => _canStream = v),
              ),
              SwitchListTile(
                title: const Text(
                  'Can manage sponsors',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: const Text(
                  'Assign sponsor banners to matches',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
                value: _canSponsor,
                activeColor: const Color(0xFF10B981),
                onChanged: (v) => setState(() => _canSponsor = v),
              ),
              const Gap(24),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Create Operations Manager',
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
  }

  Widget _field(
    String label,
    TextEditingController ctrl,
    IconData icon,
    TextInputType type, {
    bool required = true,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: type,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFF1B3A4B),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
      validator:
          validator ??
          (required
              ? (v) => (v == null || v.trim().isEmpty)
                    ? '$label is required'
                    : null
              : null),
    );
  }
}
