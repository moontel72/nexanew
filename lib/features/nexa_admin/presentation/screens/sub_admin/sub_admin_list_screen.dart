// Sub-Admin List Screen — View and manage all sub-admins
//
// Accessible from: Super Admin Shell → Sub Admins section
// Shows the four verticals: Bus Transit, Goods & Logistics,
// Commercial Marketplace, and Financial Auditor.

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:trace_odd/core/config/api_config.dart';
import 'package:trace_odd/core/services/api_client.dart';
import 'package:trace_odd/shared/theme/colors.dart';

class SubAdminListScreen extends StatefulWidget {
  final bool inShell;
  const SubAdminListScreen({super.key, this.inShell = false});

  @override
  State<SubAdminListScreen> createState() => _SubAdminListScreenState();
}

class _SubAdminListScreenState extends State<SubAdminListScreen> {
  List<Map<String, dynamic>> _subAdmins = [];
  bool _isLoading = true;
  String? _error;

  // ── Vertical color scheme (matching Bus Owner pencil palette)
  static const _verticalColors = {
    'bus_transit': Color(0xFF7C3AED),        // Purple
    'goods_logistics': Color(0xFFDB2777),     // Pink
    'commercial_marketplace': Color(0xFF2563EB), // Blue
    'financial_auditor': Color(0xFFD97706),   // Gold/Bronze
  };

  static const _verticalLabels = {
    'bus_transit': 'Bus Transit Manager',
    'goods_logistics': 'Goods & Logistics Manager',
    'commercial_marketplace': 'Commercial Marketplace Manager',
    'financial_auditor': 'Financial & Subscription Auditor',
  };

  static const _verticalIcons = {
    'bus_transit': Icons.directions_bus_rounded,
    'goods_logistics': Icons.local_shipping_rounded,
    'commercial_marketplace': Icons.storefront_rounded,
    'financial_auditor': Icons.account_balance_rounded,
  };

  @override
  void initState() {
    super.initState();
    _fetchSubAdmins();
  }

  Future<void> _fetchSubAdmins() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final api = ApiClient();
      final res = await api.get('${ApiConfig.apiBaseUrl}/admin/sub-admins');
      final data = res['data'];
      if (data is List) {
        setState(() {
          _subAdmins = data.cast<Map<String, dynamic>>();
          _isLoading = false;
        });
      } else {
        setState(() { _subAdmins = []; _isLoading = false; });
      }
    } catch (e) {
      // Fallback: use mock data until backend endpoint is ready
      setState(() {
        _subAdmins = _mockSubAdmins();
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _mockSubAdmins() {
    return [
      {
        'id': 'sa-001',
        'name': 'Ahmed Khan',
        'email': 'ahmed.khan@nexatrace.com',
        'vertical': 'bus_transit',
        'status': 'active',
        'appointed_at': '2026-05-15T10:30:00Z',
      },
      {
        'id': 'sa-002',
        'name': 'Fatima Noor',
        'email': 'fatima.noor@nexatrace.com',
        'vertical': 'goods_logistics',
        'status': 'active',
        'appointed_at': '2026-05-20T14:00:00Z',
      },
      {
        'id': 'sa-003',
        'name': 'Bilal Mahmood',
        'email': 'bilal.mahmood@nexatrace.com',
        'vertical': 'commercial_marketplace',
        'status': 'active',
        'appointed_at': '2026-06-01T09:15:00Z',
      },
      {
        'id': 'sa-004',
        'name': 'Zainab Ali',
        'email': 'zainab.ali@nexatrace.com',
        'vertical': 'financial_auditor',
        'status': 'suspended',
        'appointed_at': '2026-05-10T08:00:00Z',
      },
    ];
  }

  Color _verticalColor(String? code) =>
      _verticalColors[code] ?? AppColors.gray500;

  String _verticalLabel(String? code) =>
      _verticalLabels[code] ?? code ?? 'Unknown';

  IconData _verticalIcon(String? code) =>
      _verticalIcons[code] ?? Icons.admin_panel_settings;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.adminContentBackground,
      appBar: widget.inShell
          ? null
          : AppBar(
              title: const Text('Sub-Admin Management'),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError()
              : _buildContent(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/sub-admins/add'),
        icon: const Icon(Icons.person_add_alt_rounded),
        label: const Text('Add Sub-Admin'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const Gap(12),
          Text(_error!, style: const TextStyle(color: AppColors.textSecondary)),
          const Gap(12),
          ElevatedButton(onPressed: _fetchSubAdmins, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_subAdmins.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: AppColors.gray300),
            const Gap(16),
            const Text(
              'No Sub-Admins yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const Gap(8),
            const Text(
              'Create the first Sub-Admin to delegate\ntransit ecosystem management.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textTertiary),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchSubAdmins,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Header ──────────────────────────────────────
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Quad Sub-Admin Hierarchy',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Text(
                '${_subAdmins.length} assigned',
                style: const TextStyle(color: AppColors.textTertiary),
              ),
            ],
          ),
          const Gap(4),
          const Text(
            'Four verticals: Bus Transit · Goods & Logistics · '
            'Commercial Marketplace · Financial Auditor',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const Gap(20),
          // ── Card Grid ───────────────────────────────────
          for (final sa in _subAdmins) _buildSubAdminCard(sa),
        ],
      ),
    );
  }

  Widget _buildSubAdminCard(Map<String, dynamic> sa) {
    final vertical = sa['vertical'] as String?;
    final color = _verticalColor(vertical);
    final isActive = sa['status'] == 'active';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          // TODO: Navigate to sub-admin detail/feature-management screen
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Vertical color indicator
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_verticalIcon(vertical), color: color, size: 24),
              ),
              const Gap(14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sa['name'] as String? ?? '—',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Gap(2),
                    Text(
                      sa['email'] as String? ?? '',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Gap(4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _verticalLabel(vertical),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: color,
                            ),
                          ),
                        ),
                        const Gap(8),
                        _statusChip(isActive),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.gray400),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusChip(bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: active
            ? AppColors.success.withValues(alpha: 0.1)
            : AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        active ? 'ACTIVE' : 'SUSPENDED',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          color: active ? AppColors.success : AppColors.warning,
        ),
      ),
    );
  }
}
