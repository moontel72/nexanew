import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:trace_odd/core/services/api_client.dart';

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
      backgroundColor: const Color(0xFF0C1D2C),
      appBar: AppBar(
        title: const Text(
          'Add Operations Manager',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        backgroundColor: const Color(0xFF0F2936),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/sub-admin/dashboard'),
          tooltip: 'Back to Dashboard',
        ),
        actions: [
          TextButton.icon(
            onPressed: () => context.go('/sub-admin/cricket/managers'),
            icon: const Icon(Icons.people, color: Colors.white, size: 18),
            label: const Text(
              'View All',
              style: TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
        ],
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
                        'Provision a Cricket Operations Manager who will handle tournaments, live scoring, and streaming.',
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(24),

              // Account Details
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

              // Permissions (dark card with white text)
              const Text(
                'Permissions',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Gap(8),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1B3A4B),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
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
                    const Divider(height: 1, color: Color(0x20FFFFFF)),
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
                    const Divider(height: 1, color: Color(0x20FFFFFF)),
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
                  ],
                ),
              ),
              const Gap(24),

              // Login info card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFF10B981).withOpacity(0.3),
                  ),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Color(0xFF10B981),
                          size: 18,
                        ),
                        Gap(8),
                        Text(
                          'Manager Login',
                          style: TextStyle(
                            color: Color(0xFF10B981),
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    Gap(6),
                    Text(
                      'Cricket Operations Managers log in at:',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    Gap(4),
                    SelectableText(
                      '/cricket-manager/login',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(20),

              // Submit + Back buttons
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
              const Gap(12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: const BorderSide(color: Colors.white24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => context.go('/sub-admin/dashboard'),
                  icon: const Icon(Icons.arrow_back, size: 18),
                  label: const Text('Back to Dashboard'),
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
