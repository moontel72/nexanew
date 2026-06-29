/// Storekeeper HR Management Screen — Admin view for managing terminal storekeepers.
///
/// Features:
///   - Create Storekeeper form (name, phone, terminal, email, password)
///   - Directory data table listing all storekeepers with Active/Inactive toggle
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:trace_odd/core/services/api_service.dart';

class StorekeeperManagementScreen extends StatefulWidget {
  const StorekeeperManagementScreen({super.key});

  @override
  State<StorekeeperManagementScreen> createState() =>
      _StorekeeperManagementScreenState();
}

class _StorekeeperManagementScreenState
    extends State<StorekeeperManagementScreen> {
  final _api = ApiService();
  static const _prefix = '/api/v1/bus-fleet/storekeepers';

  List<Map<String, dynamic>> _storekeepers = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final r = await _api.get(_prefix);
      final data = r['data'] as Map<String, dynamic>? ?? {};
      final list = (data['data'] as List<dynamic>?) ?? [];
      if (mounted) {
        setState(() {
          _storekeepers = list.cast<Map<String, dynamic>>();
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _create() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => const _CreateStorekeeperDialog(),
    );
    if (result != null) {
      try {
        await _api.post(_prefix, body: result);
        _load();
      } catch (e) {
        _showError(e.toString());
      }
    }
  }

  Future<void> _toggleStatus(Map<String, dynamic> sk) async {
    final newStatus =
        sk['status'] == 'active' ? 'suspended' : 'active';
    try {
      await _api.put('$_prefix/${sk['id']}', body: {'status': newStatus});
      _load();
    } catch (e) {
      _showError(e.toString());
    }
  }

  void _showError(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B2838),
        title: const Text('Manage Terminal Storekeepers',
            style: TextStyle(color: Colors.white, fontSize: 16)),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add, color: Color(0xFF00B4D8)),
            tooltip: 'Add Storekeeper',
            onPressed: _create,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Error: $_error',
                          style:
                              const TextStyle(color: Colors.redAccent)),
                      const Gap(8),
                      ElevatedButton(
                          onPressed: _load, child: const Text('Retry')),
                    ],
                  ),
                )
              : _storekeepers.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.people_outline,
                              size: 48, color: Colors.white24),
                          const Gap(8),
                          const Text('No storekeepers registered.',
                              style: TextStyle(color: Colors.white54)),
                          const Gap(12),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.person_add, size: 16),
                            label: const Text('Add Storekeeper'),
                            style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color(0xFF00B4D8)),
                            onPressed: _create,
                          ),
                        ],
                      ),
                    )
                  : isWide
                      ? _buildTable()
                      : _buildCardList(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF00B4D8),
        onPressed: _create,
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
    );
  }

  Widget _buildTable() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        // Header
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Row(
            children: [
              Expanded(flex: 2, child: Text('Name', style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold))),
              Expanded(flex: 2, child: Text('Terminal / Station', style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold))),
              Expanded(flex: 1, child: Text('Phone', style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold))),
              Expanded(flex: 1, child: Text('Status', style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold))),
              SizedBox(width: 50, child: Text('', style: TextStyle(color: Colors.white54))),
            ],
          ),
        ),
        const Gap(4),
        ..._storekeepers.map(_buildTableRow),
      ],
    );
  }

  Widget _buildTableRow(Map<String, dynamic> sk) {
    final isActive = sk['status'] == 'active';
    final terminal = sk['terminal'] ?? sk['station'] ?? '—';
    final phone = sk['phone'] ?? '—';
    final name = sk['name'] ?? '—';

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2838),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w500)),
                if (sk['email'] != null)
                  Text(sk['email'],
                      style: const TextStyle(
                          color: Colors.white38, fontSize: 11)),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(terminal,
                style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ),
          Expanded(
            flex: 1,
            child: Text(phone,
                style: const TextStyle(color: Colors.white54, fontSize: 12)),
          ),
          Expanded(
            flex: 1,
            child: Switch(
              value: isActive,
              activeColor: const Color(0xFF00B4D8),
              onChanged: (_) => _toggleStatus(sk),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardList() {
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: _storekeepers.length,
      separatorBuilder: (_, __) => const Gap(6),
      itemBuilder: (_, i) => _buildCard(_storekeepers[i]),
    );
  }

  Widget _buildCard(Map<String, dynamic> sk) {
    final isActive = sk['status'] == 'active';

    return Card(
      color: const Color(0xFF1B2838),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(sk['name'] ?? '—',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14)),
                ),
                Switch(
                  value: isActive,
                  activeColor: const Color(0xFF00B4D8),
                  onChanged: (_) => _toggleStatus(sk),
                ),
              ],
            ),
            if (sk['email'] != null) ...[
              const Gap(2),
              Text(sk['email'],
                  style:
                      const TextStyle(color: Colors.white38, fontSize: 12)),
            ],
            const Gap(4),
            Row(
              children: [
                const Icon(Icons.location_on,
                    size: 12, color: Colors.white38),
                const Gap(4),
                Text(sk['terminal'] ?? sk['station'] ?? 'No terminal',
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 12)),
              ],
            ),
            const Gap(2),
            Row(
              children: [
                const Icon(Icons.phone, size: 12, color: Colors.white38),
                const Gap(4),
                Text(sk['phone'] ?? '—',
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Dialog for creating a new storekeeper.
class _CreateStorekeeperDialog extends StatefulWidget {
  const _CreateStorekeeperDialog();

  @override
  State<_CreateStorekeeperDialog> createState() =>
      _CreateStorekeeperDialogState();
}

class _CreateStorekeeperDialogState extends State<_CreateStorekeeperDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _terminalCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _terminalCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(context, {
      'name': _nameCtrl.text.trim(),
      'phone': _phoneCtrl.text.trim(),
      'terminal': _terminalCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
      'password': _passCtrl.text,
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1B2838),
      title: const Text('Register Storekeeper',
          style: TextStyle(color: Colors.white, fontSize: 16)),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _field('Full Name *', _nameCtrl,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Required'
                      : null),
              const Gap(10),
              _field('Phone Number *', _phoneCtrl,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Required'
                      : null),
              const Gap(10),
              _field('Assigned Terminal / Station', _terminalCtrl),
              const Gap(10),
              _field('Email *', _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) =>
                      (v == null || !v.contains('@')) ? 'Valid email required' : null),
              const Gap(10),
              _field('Secure Password *', _passCtrl,
                  obscure: true,
                  validator: (v) => (v == null || v.length < 8)
                      ? 'Min 8 characters'
                      : null),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.white54))),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00B4D8)),
          onPressed: _loading ? null : _submit,
          child: const Text('Create',
              style: TextStyle(fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _field(String label, TextEditingController ctrl,
      {TextInputType? keyboardType,
      bool obscure = false,
      String? Function(String?)? validator}) {
    return TextFormField(
      controller: ctrl,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white, fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            const TextStyle(color: Colors.white54, fontSize: 12),
        filled: true,
        fillColor: const Color(0xFF0D1B2A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        isDense: true,
      ),
      validator: validator,
    );
  }
}
