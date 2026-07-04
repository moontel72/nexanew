/// Bundle Management — BULK BUNDLE with Smart Codes (#CHIPS)
library;

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:trace_odd/core/services/api_service.dart';

class BundleManagementScreen extends StatefulWidget {
  const BundleManagementScreen({super.key});

  @override
  State<BundleManagementScreen> createState() => _BundleManagementScreenState();
}

class _BundleManagementScreenState extends State<BundleManagementScreen> {
  final _api = ApiService();
  static const _prefix = '/api/v1/bus-fleet/storekeeper';

  List<Map<String, dynamic>> _bundles = [];
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
      final r = await _api.get('$_prefix/bundles');
      final list = (r['data'] as List<dynamic>?) ?? [];
      if (mounted)
        setState(() {
          _bundles = list.cast<Map<String, dynamic>>();
          _loading = false;
        });
    } catch (e) {
      if (mounted)
        setState(() {
          _error = e.toString();
          _loading = false;
        });
    }
  }

  Future<void> _createBundle() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const _CreateBundlePage()),
    );
    if (result == true) _load();
  }

  Future<void> _deleteBundle(String id) async {
    try {
      await _api.delete('$_prefix/bundles/$id');
      _load();
    } catch (e) {
      _showError(e.toString());
    }
  }

  void _showError(String m) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(m), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B2838),
        title: const Text(
          'Bundle & Smart Codes',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: Color(0xFF00B4D8)),
            tooltip: 'New Bundle',
            onPressed: _createBundle,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Text(
                'Error: $_error',
                style: const TextStyle(color: Colors.redAccent),
              ),
            )
          : _bundles.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.inventory_2,
                    size: 48,
                    color: Colors.white24,
                  ),
                  const Gap(12),
                  const Text(
                    'No bundles yet',
                    style: TextStyle(color: Colors.white54),
                  ),
                  const Gap(12),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Create First Bundle'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00B4D8),
                    ),
                    onPressed: _createBundle,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _bundles.length,
              itemBuilder: (_, i) => _buildBundleCard(_bundles[i]),
            ),
    );
  }

  Widget _buildBundleCard(Map<String, dynamic> b) {
    final packets = (b['packets'] as List<dynamic>?) ?? [];
    final isExpanded = _expandedBundleId == b['id'];

    return Card(
      color: const Color(0xFF1B2838),
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(
              () => _expandedBundleId = isExpanded ? null : b['id']?.toString(),
            ),
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00B4D8).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.inventory_2,
                      color: Color(0xFF00B4D8),
                      size: 20,
                    ),
                  ),
                  const Gap(10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          b['name'] ?? '—',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const Gap(2),
                        Text(
                          '${packets.length} packets',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      size: 18,
                      color: Colors.redAccent,
                    ),
                    onPressed: () => _deleteBundle(b['id']),
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded && packets.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF0F1F30),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(10),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: packets.map<Widget>((p) {
                  final code = p['smart_code']?.toString() ?? '—';
                  final name = p['name']?.toString() ?? '—';
                  final remaining = p['units_remaining']?.toString() ?? '0';
                  final total = p['total_units']?.toString() ?? '0';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00B4D8).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            code,
                            style: const TextStyle(
                              color: Color(0xFF00B4D8),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                        const Gap(8),
                        Expanded(
                          child: Text(
                            name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Text(
                          '$remaining/$total',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  String? _expandedBundleId;
}

// ─── Create Bundle Page ─────────────────────────────────────

class _CreateBundlePage extends StatefulWidget {
  const _CreateBundlePage();

  @override
  State<_CreateBundlePage> createState() => _CreateBundlePageState();
}

class _CreateBundlePageState extends State<_CreateBundlePage> {
  final _api = ApiService();
  static const _prefix = '/api/v1/bus-fleet/storekeeper';
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final List<_PacketEntry> _packets = [];
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _addPacket() {
    setState(() => _packets.add(_PacketEntry()));
  }

  void _removePacket(int i) {
    setState(() => _packets.removeAt(i));
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) {
      _showError('Bundle name is required.');
      return;
    }
    if (_packets.isEmpty) {
      _showError('Add at least one packet.');
      return;
    }
    setState(() => _saving = true);
    try {
      await _api.post(
        '$_prefix/bundles',
        body: {
          'name': _nameCtrl.text.trim(),
          'description': _descCtrl.text.trim(),
          'packets': _packets
              .map(
                (p) => {
                  'name': p.nameCtrl.text.trim(),
                  'total_units': int.tryParse(p.unitsCtrl.text) ?? 1,
                },
              )
              .toList(),
        },
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showError(String m) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(m), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B2838),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('New Bundle', style: TextStyle(color: Colors.white)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextFormField(
            controller: _nameCtrl,
            style: const TextStyle(color: Colors.white),
            decoration: _dec(
              'Bundle / Lot Name (e.g. Morning Fleet Catering Batch A)',
            ),
          ),
          const Gap(12),
          TextFormField(
            controller: _descCtrl,
            style: const TextStyle(color: Colors.white),
            decoration: _dec('Description (optional)'),
            maxLines: 2,
          ),
          const Gap(20),
          Row(
            children: [
              const Text(
                'Packets',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Packet'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF00B4D8),
                ),
                onPressed: _addPacket,
              ),
            ],
          ),
          if (_packets.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Tap "+ Add Packet" to add items to this bundle.',
                style: TextStyle(color: Colors.white38, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ),
          ...List.generate(_packets.length, (i) {
            final p = _packets[i];
            return Card(
              color: const Color(0xFF1B2838),
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Auto-generated smart code preview
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00B4D8).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '#${_fmtCode(i)}',
                            style: const TextStyle(
                              color: Color(0xFF00B4D8),
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.redAccent,
                          ),
                          onPressed: () => _removePacket(i),
                          constraints: const BoxConstraints(
                            minWidth: 28,
                            minHeight: 28,
                          ),
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                    const Gap(8),
                    TextFormField(
                      controller: p.nameCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: _dec('Item Name (e.g. Coca Cola 300ml)'),
                    ),
                    const Gap(8),
                    TextFormField(
                      controller: p.unitsCtrl,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: _dec('Total Units Volume'),
                    ),
                  ],
                ),
              ),
            );
          }),
          const Gap(20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00B4D8),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Save Bundle',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
          ),
        ],
      ),
    );
  }

  String _fmtCode(int i) {
    final r = Random(i * 31 + 7);
    return r.nextInt(99999).toString().padLeft(5, '0');
  }

  InputDecoration _dec(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Colors.white38),
    filled: true,
    fillColor: const Color(0xFF1B2838),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    ),
  );
}

class _PacketEntry {
  final nameCtrl = TextEditingController();
  final unitsCtrl = TextEditingController(text: '1');
}
