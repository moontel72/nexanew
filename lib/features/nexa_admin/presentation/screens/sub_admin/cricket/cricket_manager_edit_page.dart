import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:trace_odd/core/services/api_client.dart';

/// Sub-Admin page: Edit an existing Cricket Operations Manager.
class CricketManagerEditPage extends StatefulWidget {
  final Map<String, dynamic> manager;

  const CricketManagerEditPage({super.key, required this.manager});

  @override
  State<CricketManagerEditPage> createState() => _CricketManagerEditPageState();
}

class _CricketManagerEditPageState extends State<CricketManagerEditPage> {
  final _formKey = GlobalKey<FormState>();
  late final _nameCtrl = TextEditingController(
    text: widget.manager['name']?.toString() ?? '',
  );
  late final _emailCtrl = TextEditingController(
    text: widget.manager['email']?.toString() ?? '',
  );
  late final _phoneCtrl = TextEditingController(
    text: widget.manager['phone']?.toString() ?? '',
  );
  final _passwordCtrl = TextEditingController();
  bool _loading = false;

  Map<String, dynamic> get _permissions => widget.manager['permissions'] is Map
      ? Map<String, dynamic>.from(widget.manager['permissions'] as Map)
      : const <String, dynamic>{};

  late bool _canScore = _permissions['can_manage_scores'] == true;
  late bool _canStream = _permissions['can_manage_streams'] == true;
  late bool _canSponsor = _permissions['can_manage_sponsors'] == true;
  late bool _canStudio = _permissions['can_access_studio'] == true;

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
      final id = widget.manager['id'];
      final body = <String, dynamic>{
        'name': _nameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'permissions': {
          'can_manage_scores': _canScore,
          'can_manage_streams': _canStream,
          'can_manage_sponsors': _canSponsor,
          'can_access_studio': _canStudio,
        },
      };
      if (_passwordCtrl.text.isNotEmpty) {
        body['password'] = _passwordCtrl.text;
      }
      final api = ApiClient();
      await api.put('/api/v1/cricket/admin/managers/$id', body: body);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cricket Operations Manager updated.'),
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
          'Edit Operations Manager',
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
                    Icon(Icons.edit, color: Colors.white, size: 28),
                    Gap(12),
                    Expanded(
                      child: Text(
                        'Update account details and permissions for this Cricket Operations Manager.',
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
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Email Address is required';
                  }
                  if (!RegExp(
                    r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                  ).hasMatch(v.trim())) {
                    return 'Enter a valid email address';
                  }
                  return null;
                },
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
                required: false,
                hint: 'Leave blank to keep current password',
                validator: (v) => (v == null || v.isEmpty || v.length >= 8)
                    ? null
                    : 'Minimum 8 characters',
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
                      activeThumbColor: const Color(0xFF10B981),
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
                      activeThumbColor: const Color(0xFF10B981),
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
                      activeThumbColor: const Color(0xFF10B981),
                      onChanged: (v) => setState(() => _canSponsor = v),
                    ),
                    const Divider(height: 1, color: Color(0x20FFFFFF)),
                    SwitchListTile(
                      title: const Text(
                        'Studio Director Access',
                        style: TextStyle(color: Colors.white),
                      ),
                      subtitle: const Text(
                        'Allows opening Todd Studio from the manager panel',
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                      value: _canStudio,
                      activeThumbColor: const Color(0xFF10B981),
                      onChanged: (v) => setState(() => _canStudio = v),
                    ),
                  ],
                ),
              ),
              const Gap(24),

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
                          'Update Operations Manager',
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
    String? hint,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: type,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
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
