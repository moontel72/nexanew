// Sub-Admin Dashboard Screen — BLoC-driven
//
// Post-login workspace for a vertical sub-admin.
// Shows KPIs, bus company management, and profile info.
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:trace_odd/features/nexa_admin/presentation/bloc/sub_admin/sub_admin_bloc.dart';
import 'package:trace_odd/features/nexa_admin/presentation/bloc/sub_admin/sub_admin_event.dart';
import 'package:trace_odd/features/nexa_admin/presentation/bloc/sub_admin/sub_admin_state.dart';
import 'package:trace_odd/shared/theme/colors.dart';
import 'package:trace_odd/features/bus_operations/presentation/widgets/missile_3d_button.dart';
import 'package:trace_odd/core/services/api_service.dart';
import 'package:trace_odd/shared/widgets/layout_designer/absolute_layout_designer_screen.dart';
import 'package:trace_odd/shared/bloc/layout_designer/layout_validation_bloc.dart';
import 'package:trace_odd/shared/bloc/layout_designer/layout_validation_event.dart';
import 'package:trace_odd/shared/models/transport/bus_dimensions.dart';
import 'package:trace_odd/shared/models/transport/component_registry.dart';
import 'package:trace_odd/shared/models/transport/feet_inches.dart';
import 'package:trace_odd/shared/widgets/layout_designer/bus_config_setup_screen.dart';

class SubAdminDashboardScreen extends StatelessWidget {
  const SubAdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LayoutValidationBloc(),
      child: BlocProvider(
        create: (_) => SubAdminBloc()..add(const BootstrapDashboard()),
        child: const _DashboardView(),
      ),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubAdminBloc, SubAdminState>(
      builder: (ctx, state) {
        if (state.dashStatus == SubAdminViewStatus.loading) {
          return const Scaffold(
            backgroundColor: Color(0xFF0C1D2C),
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF1F5E6B)),
            ),
          );
        }
        final bloc = ctx.read<SubAdminBloc>();
        final wide = MediaQuery.of(ctx).size.width > 900;
        return Scaffold(
          backgroundColor: const Color(0xFF0C1D2C),
          body: Row(
            children: [
              if (wide) _Sidebar(bloc: bloc, state: state),
              Expanded(child: _content(ctx, bloc, state, wide)),
            ],
          ),
        );
      },
    );
  }

  Widget _content(
    BuildContext ctx,
    SubAdminBloc bloc,
    SubAdminState state,
    bool wide,
  ) {
    return Column(
      children: [
        _topBar(state, wide),
        Expanded(
          child: state.busListLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFF1F5E6B)),
                )
              : Builder(
                  builder: (_) {
                    // Determine which sub-page to show (managed inside bloc via events or local index)
                    // For simplicity, we'll keep the dashboard + bus company list as the main view
                    // since the BLoC already loads bus companies on bootstrap.
                    return _mainView(ctx, bloc, state);
                  },
                ),
        ),
      ],
    );
  }

  // ── Top Bar ──
  Widget _topBar(SubAdminState state, bool wide) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF0F2936),
        border: Border(bottom: BorderSide(color: Color(0x20FFFFFF))),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFF1F5E6B),
            child: Text(
              state.subAdminName.isNotEmpty
                  ? state.subAdminName[0].toUpperCase()
                  : 'S',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const Gap(12),
          Text(
            state.subAdminName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            '${state.tenantCount} tenants · ${state.activeFeatures.length} features',
            style: const TextStyle(color: Color(0xFFBDD8DB), fontSize: 12),
          ),
        ],
      ),
    );
  }

  // ── Main Dashboard View ──
  Widget _mainView(BuildContext ctx, SubAdminBloc bloc, SubAdminState state) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // KPI Cards
        Row(
          children: [
            _kpiCard(
              'Tenants',
              '${state.tenantCount}',
              Icons.business,
              const Color(0xFF7C3AED),
            ),
            const Gap(12),
            _kpiCard(
              'Features',
              '${state.activeFeatures.length}',
              Icons.grid_view,
              const Color(0xFF2563EB),
            ),
            const Gap(12),
            _kpiCard(
              'Revenue',
              '\$${state.monthlyRevenue.toStringAsFixed(0)}',
              Icons.trending_up,
              const Color(0xFF059669),
            ),
          ],
        ),
        const Gap(24),

        // Quick Actions
        const Text(
          'Quick Actions',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Gap(12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _actionBtn(
              Icons.add_business,
              'Add Bus Company',
              () => _showAddBusCompanySheet(ctx, bloc),
            ),
            _actionBtn(Icons.list_alt, 'View Companies', () {}),
            _actionBtn(
              Icons.airline_seat_recline_normal,
              'View Layout Presets',
              () => _openPresetsList(ctx),
            ),
            _actionBtn(Icons.receipt_long, 'Reports', () {}),
          ],
        ),
        const Gap(24),

        // Bus Companies Section
        Row(
          children: [
            const Expanded(
              child: Text(
                'Registered Bus Companies',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: () => bloc.add(const FetchBusCompanies()),
              icon: const Icon(
                Icons.refresh,
                size: 16,
                color: Color(0xFFBDD8DB),
              ),
              label: const Text(
                'Refresh',
                style: TextStyle(color: Color(0xFFBDD8DB)),
              ),
            ),
          ],
        ),
        const Gap(8),
        if (state.busCompanies.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFF1B3A4B),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'No bus companies registered yet.',
                style: TextStyle(color: Colors.white54),
              ),
            ),
          )
        else
          ...state.busCompanies.map((c) => _busCompanyCard(ctx, bloc, c)),
      ],
    );
  }

  // ── KPI Card ──
  Widget _kpiCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1B3A4B),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 18),
                const Spacer(),
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const Gap(4),
            Text(
              label,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  // ── Action Button ──
  Widget _actionBtn(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1B3A4B),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFF1F5E6B), size: 18),
            const Gap(8),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  // ── Bus Company Card ──
  Widget _busCompanyCard(
    BuildContext ctx,
    SubAdminBloc bloc,
    Map<String, dynamic> c,
  ) {
    final name =
        c['account_name']?.toString() ?? c['name']?.toString() ?? 'Unknown';
    final email = c['email']?.toString() ?? '';
    final status = c['status']?.toString() ?? 'pending';
    final id = c['id']?.toString() ?? '';
    final statusColor = _statusColor(status);
    final statusLabel = _statusLabel(status);

    return Card(
      color: const Color(0xFF1B3A4B),
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: statusColor,
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        email,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.white54),
                  color: const Color(0xFF1B3A4B),
                  onSelected: (action) {
                    switch (action) {
                      case 'verified':
                        bloc.add(
                          UpdateBusCompanyStatus(
                            companyId: id,
                            newStatus: 'verified',
                          ),
                        );
                        break;
                      case 'active':
                        bloc.add(
                          UpdateBusCompanyStatus(
                            companyId: id,
                            newStatus: 'active',
                          ),
                        );
                        break;
                      case 'inactive':
                        bloc.add(
                          UpdateBusCompanyStatus(
                            companyId: id,
                            newStatus: 'inactive',
                          ),
                        );
                        break;
                      case 'suspended':
                        bloc.add(
                          UpdateBusCompanyStatus(
                            companyId: id,
                            newStatus: 'suspended',
                          ),
                        );
                        break;
                      case 'edit':
                        _showEditBusCompanySheet(ctx, bloc, c);
                        break;
                      case 'delete':
                        showDialog(
                          context: ctx,
                          builder: (dctx) => AlertDialog(
                            title: const Text('Delete Company?'),
                            content: Text('This will archive $name.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(dctx),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.error,
                                ),
                                onPressed: () {
                                  Navigator.pop(dctx);
                                  bloc.add(DeleteBusCompany(id));
                                },
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                        break;
                    }
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'verified',
                      child: ListTile(
                        leading: Icon(Icons.verified, color: Color(0xFF2563EB)),
                        title: Text('Verified'),
                        dense: true,
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'active',
                      child: ListTile(
                        leading: Icon(
                          Icons.check_circle,
                          color: Color(0xFF059669),
                        ),
                        title: Text('Active'),
                        dense: true,
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'inactive',
                      child: ListTile(
                        leading: Icon(
                          Icons.pause_circle,
                          color: Color(0xFFD97706),
                        ),
                        title: Text('Inactive'),
                        dense: true,
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'suspended',
                      child: ListTile(
                        leading: Icon(Icons.block, color: AppColors.warning),
                        title: Text('Suspend'),
                        dense: true,
                      ),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: 'edit',
                      child: ListTile(
                        leading: Icon(Icons.edit, color: Color(0xFF1F5E6B)),
                        title: Text('Update'),
                        dense: true,
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(Icons.delete, color: AppColors.error),
                        title: Text('Delete'),
                        dense: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'active':
        return const Color(0xFF059669);
      case 'verified':
        return const Color(0xFF2563EB);
      case 'pending':
        return const Color(0xFFD97706);
      case 'inactive':
        return Colors.grey;
      case 'suspended':
        return AppColors.warning;
      case 'deleted':
        return AppColors.error;
      default:
        return Colors.grey;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'active':
        return 'Active';
      case 'verified':
        return 'Verified';
      case 'pending':
        return 'Pending';
      case 'inactive':
        return 'Inactive';
      case 'suspended':
        return 'Suspended';
      case 'deleted':
        return 'Deleted';
      default:
        return status;
    }
  }

  // ── Add Bus Company Bottom Sheet ──
  void _showAddBusCompanySheet(BuildContext context, SubAdminBloc bloc) {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final regCtrl = TextEditingController();
    final fleetCtrl = TextEditingController();
    final licenseCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1B3A4B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => BlocProvider.value(
        value: bloc,
        child: BlocConsumer<SubAdminBloc, SubAdminState>(
          listener: (lctx, state) {
            if (state.busFormSuccess != null) {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.busFormSuccess!),
                  backgroundColor: AppColors.success,
                ),
              );
            }
          },
          builder: (lctx, state) => Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(lctx).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Add Bus Company',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Gap(16),
                _sheetField('Company Name', nameCtrl),
                const Gap(10),
                _sheetField('Email', emailCtrl, TextInputType.emailAddress),
                const Gap(10),
                _sheetField('Phone', phoneCtrl, TextInputType.phone),
                const Gap(10),
                _sheetField('Registration Code', regCtrl),
                const Gap(10),
                _sheetField('Fleet Size', fleetCtrl, TextInputType.number),
                const Gap(10),
                _sheetField('License Number', licenseCtrl),
                const Gap(10),
                _sheetField(
                  'Password',
                  passwordCtrl,
                  TextInputType.visiblePassword,
                ),
                if (state.busFormError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      state.busFormError!,
                      style: const TextStyle(
                        color: AppColors.error,
                        fontSize: 12,
                      ),
                    ),
                  ),
                const Gap(16),
                ElevatedButton(
                  onPressed: state.busFormLoading
                      ? null
                      : () {
                          bloc.add(
                            CreateBusCompany(
                              name: nameCtrl.text.trim(),
                              email: emailCtrl.text.trim(),
                              password: passwordCtrl.text,
                              phone: phoneCtrl.text.trim(),
                              regCode: regCtrl.text.trim(),
                              fleetSize: fleetCtrl.text.trim(),
                              license: licenseCtrl.text.trim(),
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F5E6B),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: state.busFormLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Create Company',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Edit Bus Company Bottom Sheet ──
  void _showEditBusCompanySheet(
    BuildContext context,
    SubAdminBloc bloc,
    Map<String, dynamic> company,
  ) {
    final id = company['id']?.toString() ?? '';
    final nameCtrl = TextEditingController(
      text:
          company['account_name']?.toString() ??
          company['name']?.toString() ??
          '',
    );
    final emailCtrl = TextEditingController(
      text: company['email']?.toString() ?? '',
    );
    final phoneCtrl = TextEditingController(
      text:
          company['phone_number']?.toString() ??
          company['phone']?.toString() ??
          '',
    );
    final passwordCtrl = TextEditingController();
    final metadata = company['metadata'] is Map
        ? Map<String, dynamic>.from(company['metadata'] as Map)
        : <String, dynamic>{};
    final regCtrl = TextEditingController(
      text: metadata['registration_code']?.toString() ?? '',
    );
    final fleetCtrl = TextEditingController(
      text: metadata['fleet_size']?.toString() ?? '',
    );
    final licenseCtrl = TextEditingController(
      text: metadata['transit_license']?.toString() ?? '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1B3A4B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => BlocProvider.value(
        value: bloc,
        child: BlocConsumer<SubAdminBloc, SubAdminState>(
          listener: (lctx, state) {
            if (state.actionSuccess != null) {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.actionSuccess!),
                  backgroundColor: AppColors.success,
                ),
              );
            }
          },
          builder: (lctx, state) => Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(lctx).viewInsets.bottom + 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Edit Bus Company',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Gap(16),
                  _sheetField('Company Name', nameCtrl),
                  const Gap(10),
                  _sheetField('Email', emailCtrl, TextInputType.emailAddress),
                  const Gap(10),
                  _sheetField('Phone', phoneCtrl, TextInputType.phone),
                  const Gap(10),
                  _sheetField('Registration Code', regCtrl),
                  const Gap(10),
                  _sheetField('Fleet Size', fleetCtrl, TextInputType.number),
                  const Gap(10),
                  _sheetField('License Number', licenseCtrl),
                  const Gap(10),
                  _sheetField(
                    'New Password (leave blank to keep existing)',
                    passwordCtrl,
                    TextInputType.visiblePassword,
                  ),
                  if (state.actionError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        state.actionError!,
                        style: const TextStyle(
                          color: AppColors.error,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  const Gap(16),
                  ElevatedButton(
                    onPressed: state.actionLoading
                        ? null
                        : () {
                            final data = <String, dynamic>{
                              'name': nameCtrl.text.trim(),
                              'email': emailCtrl.text.trim(),
                              'phone': phoneCtrl.text.trim(),
                              'registration_code': regCtrl.text.trim(),
                              'fleet_size': fleetCtrl.text.trim(),
                              'license': licenseCtrl.text.trim(),
                            };
                            final pwd = passwordCtrl.text;
                            if (pwd.isNotEmpty) {
                              data['password'] = pwd;
                            }
                            bloc.add(EditBusCompany(companyId: id, data: data));
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1F5E6B),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: state.actionLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Save Changes',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sheetField(
    String label,
    TextEditingController ctrl, [
    TextInputType type = TextInputType.text,
  ]) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0x30FFFFFF)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF1F5E6B)),
        ),
        filled: true,
        fillColor: const Color(0x10FFFFFF),
      ),
    );
  }

  void _openPresetsList(BuildContext ctx) {
    Navigator.push(
      ctx,
      MaterialPageRoute(builder: (_) => const _SubAdminPresetsListPage()),
    );
  }
}

// ── Presets List Page ──
class _SubAdminPresetsListPage extends StatefulWidget {
  const _SubAdminPresetsListPage();
  @override
  State<_SubAdminPresetsListPage> createState() =>
      _SubAdminPresetsListPageState();
}

class _SubAdminPresetsListPageState extends State<_SubAdminPresetsListPage> {
  List<Map<String, dynamic>> _presets = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final api = ApiService();
      final r = await api.get('/admin/absolute-layouts');
      final d = r?['data'];
      // Response wraps: { data: { data: [...], pagination: {...} } }
      final list = d is Map ? d['data'] : d;
      setState(() {
        _presets = list is List ? list.cast<Map<String, dynamic>>() : [];
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _delete(String id) async {
    try {
      final api = ApiService();
      await api.delete('/admin/absolute-layouts/$id');
      _load();
    } catch (_) {}
  }

  void _openPreset(Map<String, dynamic> p) {
    final id = p['id']?.toString();
    if (id == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AbsoluteLayoutDesignerScreen(
          companyId: '',
          companyName: p['display_name']?.toString() ?? 'Preset',
          apiPrefix: '/admin',
          layoutId: id,
        ),
      ),
    );
  }

  Future<void> _editPreset(Map<String, dynamic> p) async {
    final id = p['id']?.toString();
    if (id == null) return;

    // Pre-fetch the full preset data so the edit form is fully populated.
    BusDimensions? dims;
    ComponentRegistry? reg;
    String? name;
    int leftS = 0, rightS = 0, rows = 0;
    bool hasFront = false;
    int frontFt = 0, frontIn = 0;
    try {
      final api = ApiService();
      final r = await api.get('/admin/absolute-layouts/$id');
      final d = r?['data'];
      if (d is Map) {
        name = d['display_name']?.toString() ?? d['name']?.toString() ?? '';
        final snap = d['current_snapshot'];
        Map<String, dynamic>? snapMap;
        if (snap is Map) snapMap = Map<String, dynamic>.from(snap);
        final snapCanvas = snapMap?['canvas'];
        if (snapCanvas is Map) {
          final w = (snapCanvas['canvas_width'] as num?)?.toDouble();
          final h = (snapCanvas['canvas_height'] as num?)?.toDouble();
          if (w != null && h != null && w > 0 && h > 0) {
            final meta = snapMap?['metadata'];
            final hPx =
                snapMap?['bus_height_px'] ??
                (meta is Map ? meta['bus_height_px'] : null);
            FeetInches busH = hPx is num
                ? FeetInches.fromPixels(hPx.toDouble())
                : FeetInches.zero;
            dims = BusDimensions(
              length: FeetInches.fromPixels(h),
              width: FeetInches.fromPixels(w),
              height: busH,
            );
          }
        }
        // Registry
        dynamic regJson = snapMap?['registry'];
        if (regJson is String) {
          try {
            regJson = jsonDecode(regJson);
          } catch (_) {
            regJson = null;
          }
        }
        if (regJson is Map) {
          try {
            reg = ComponentRegistry.fromJson(
              Map<String, dynamic>.from(regJson),
            );
          } catch (_) {}
        }
        // Derive seat matrix from components
        final comps = snapMap?['components'];
        if (comps is List && comps.isNotEmpty) {
          final frontPxRaw =
              snapMap?['metadata']?['front_partition_px'] ??
              snapMap?['front_partition_px'];
          final double frontBoundary = frontPxRaw is num
              ? (frontPxRaw).toDouble().clamp(40.0, double.infinity)
              : 100.0;
          const structural = {
            'driverCabin',
            'exitDoor',
            'sideDoor',
            'slidingDoor',
            'frontDoor',
            'rearDoor',
            'aisle',
            'emergency',
            'lavatory',
            'restaurantTable',
            'empty',
          };
          final ySet = <int>{};
          final firstRowXs = <double>[];
          double? firstY;
          double minSeatY = double.infinity;
          for (final c in comps) {
            if (c is! Map) continue;
            if (structural.contains(c['type']?.toString() ?? '')) continue;
            final y = (c['y'] as num?)?.toDouble();
            final x = (c['x'] as num?)?.toDouble();
            if (y == null || x == null) continue;
            if (y < frontBoundary) continue;
            ySet.add(y.round());
            if (y < minSeatY) minSeatY = y;
            if (firstY == null) firstY = y;
            if ((y - firstY!).abs() < 5) firstRowXs.add(x);
          }
          int lC = 0, rC = 0;
          if (firstRowXs.isNotEmpty) {
            firstRowXs.sort();
            final merged = <double>[firstRowXs.first];
            for (int i = 1; i < firstRowXs.length; i++) {
              if (firstRowXs[i] - merged.last > 80) merged.add(firstRowXs[i]);
            }
            double maxGap = 0;
            int gapIdx = 0;
            for (int i = 1; i < merged.length; i++) {
              final gap = merged[i] - merged[i - 1];
              if (gap > maxGap) {
                maxGap = gap;
                gapIdx = i;
              }
            }
            if (maxGap > 30) {
              lC = gapIdx;
              rC = merged.length - gapIdx;
            } else {
              final cw = (snapCanvas is Map
                  ? ((snapCanvas['canvas_width'] as num?)?.toDouble() ?? 280)
                  : 280);
              for (final x in merged) {
                if (x < cw / 2)
                  lC++;
                else
                  rC++;
              }
            }
          }
          leftS = lC.clamp(0, 8);
          rightS = rC.clamp(0, 8);
          rows = ySet.length.clamp(1, 50);
          // Front partition
          final fpx =
              snapMap?['metadata']?['front_partition_px'] ??
              snapMap?['front_partition_px'];
          if (fpx is num && fpx.toDouble() > 0) {
            final ri = (fpx.toDouble() / 4.0).round();
            if (ri > 0) {
              hasFront = true;
              frontFt = ri ~/ 12;
              frontIn = ri % 12;
            }
          }
        }
      }
    } catch (_) {}

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider<LayoutValidationBloc>(
          create: (_) {
            final b = LayoutValidationBloc();
            if (dims != null) b.add(DimensionsChanged(dims));
            b.add(RegistryChanged(reg ?? const ComponentRegistry()));
            b.add(
              SeatMatrixChanged(
                rows: rows,
                leftSeats: leftS,
                rightSeats: rightS,
              ),
            );
            return b;
          },
          child: BusConfigSetupScreen(
            companyId: '',
            companyName: 'Template',
            apiPrefix: '/admin',
            isPreset: true,
            layoutId: id,
            initialDimensions: dims,
            initialRegistry: reg,
            initialPlate: name,
            initialLeftSeats: leftS,
            initialRightSeats: rightS,
            initialRowCount: rows,
            initialHasFrontPartition: hasFront,
            initialFrontPartitionFt: frontFt,
            initialFrontPartitionIn: frontIn,
          ),
        ),
      ),
    ).then((_) => _load());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A1628),
        title: const Text(
          'Layout Presets',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white54),
            onPressed: _load,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _presets.isEmpty
          ? const Center(
              child: Text(
                'No presets yet',
                style: TextStyle(color: Colors.white54),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _presets.length,
              itemBuilder: (_, i) {
                final p = _presets[i];
                return Card(
                  color: const Color(0xFF1A2A3A),
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    leading: const Icon(
                      Icons.airline_seat_recline_normal,
                      color: Color(0xFF7C3AED),
                    ),
                    title: Text(
                      p['display_name']?.toString() ?? '—',
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      '${p['total_components'] ?? '?'} components',
                      style: const TextStyle(
                        color: Color(0xFF8899AA),
                        fontSize: 11,
                      ),
                    ),
                    onTap: () => _openPreset(p),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.edit,
                            color: Color(0xFF00B4D8),
                            size: 20,
                          ),
                          onPressed: () => _editPreset(p),
                          tooltip: 'Edit',
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.redAccent,
                            size: 20,
                          ),
                          onPressed: () => _delete(p['id']?.toString() ?? ''),
                          tooltip: 'Delete',
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// ── Sidebar ──
class _Sidebar extends StatelessWidget {
  final SubAdminBloc bloc;
  final SubAdminState state;
  const _Sidebar({required this.bloc, required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      decoration: const BoxDecoration(
        color: Color(0xFF1A3A5C),
        border: Border(right: BorderSide(color: Color(0x20FFFFFF))),
      ),
      child: Column(
        children: [
          const Gap(20),
          // Profile header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1F5E6B), Color(0xFF0D3440)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1F5E6B).withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      state.subAdminName.isNotEmpty
                          ? state.subAdminName[0].toUpperCase()
                          : 'S',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const Gap(10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.subAdminName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1F5E6B).withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'SUB-ADMIN',
                          style: TextStyle(
                            color: Color(0xFFBDD8DB),
                            fontSize: 9,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Gap(16),
          const Divider(height: 1, color: Color(0x20FFFFFF)),
          const Gap(8),
          // Section label
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 4, 16, 4),
            child: Text(
              'NAVIGATION',
              style: TextStyle(
                color: Color(0xFFBDD8DB),
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
              ),
            ),
          ),
          // Pencil-shape navigation buttons
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 4),
              children: [
                Missile3DButton(
                  label: 'Dashboard',
                  icon: Icons.dashboard,
                  color: const Color(0xFF7C3AED),
                  height: 64,
                  onTap: () {},
                ),
                Missile3DButton(
                  label: 'Bus Companies',
                  icon: Icons.directions_bus,
                  color: const Color(0xFF16A34A),
                  height: 64,
                  onTap: () {},
                ),
                Missile3DButton(
                  label: 'Seat Templates & Presets',
                  icon: Icons.airline_seat_recline_normal,
                  color: const Color(0xFF00B4D8),
                  height: 64,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider<LayoutValidationBloc>(
                          create: (_) => LayoutValidationBloc(),
                          child: const BusConfigSetupScreen(
                            companyId: '',
                            companyName: 'Template',
                            apiPrefix: '/admin',
                            isPreset: true,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                Missile3DButton(
                  label: 'View All Preset Layouts',
                  icon: Icons.list_alt,
                  color: const Color(0xFF059669),
                  height: 56,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const _SubAdminPresetsListPage(),
                      ),
                    );
                  },
                ),
                Missile3DButton(
                  label: 'Refresh Data',
                  icon: Icons.refresh,
                  color: const Color(0xFF2563EB),
                  height: 56,
                  onTap: () => bloc.add(const BootstrapDashboard()),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0x20FFFFFF)),
          // Logout
          Padding(
            padding: const EdgeInsets.all(12),
            child: Missile3DButton(
              label: 'Logout',
              icon: Icons.logout,
              color: const Color(0xFFDC2626),
              height: 48,
              onTap: () async {
                bloc.add(const SubAdminLogout());
                if (context.mounted) context.go('/sub-admin/login');
              },
            ),
          ),
          const Gap(8),
        ],
      ),
    );
  }
}
