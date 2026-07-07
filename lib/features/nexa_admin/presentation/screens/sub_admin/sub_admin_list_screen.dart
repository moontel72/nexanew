// Sub-Admin List Screen — BLoC-driven
//
// Accessible from: Super Admin Shell → Sub Admins section
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:trace_odd/features/nexa_admin/presentation/bloc/sub_admin/sub_admin_bloc.dart';
import 'package:trace_odd/features/nexa_admin/presentation/bloc/sub_admin/sub_admin_event.dart';
import 'package:trace_odd/features/nexa_admin/presentation/bloc/sub_admin/sub_admin_state.dart';
import 'package:trace_odd/shared/theme/colors.dart';

class SubAdminListScreen extends StatelessWidget {
  final bool inShell;
  const SubAdminListScreen({super.key, this.inShell = false});

  static const _verticalColors = {
    'bus_transit': Color(0xFF7C3AED),
    'goods_logistics': Color(0xFFDB2777),
    'commercial_marketplace': Color(0xFF2563EB),
    'financial_auditor': Color(0xFFD97706),
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

  Color _color(String? v) => _verticalColors[v] ?? AppColors.gray500;
  String _label(String? v) => _verticalLabels[v] ?? v ?? 'Unknown';
  IconData _icon(String? v) => _verticalIcons[v] ?? Icons.admin_panel_settings;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SubAdminBloc()..add(const FetchSubAdmins()),
      child: BlocConsumer<SubAdminBloc, SubAdminState>(
        listener: (ctx, state) {
          if (state.actionSuccess != null) {
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(content: Text(state.actionSuccess!), backgroundColor: AppColors.success),
            );
            ctx.read<SubAdminBloc>().add(const ClearSubAdminError());
          }
          if (state.actionError != null) {
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(content: Text(state.actionError!), backgroundColor: AppColors.error),
            );
            ctx.read<SubAdminBloc>().add(const ClearSubAdminError());
          }
        },
        builder: (ctx, state) {
          final bloc = ctx.read<SubAdminBloc>();
          return Scaffold(
            backgroundColor: AppColors.adminContentBackground,
            appBar: inShell ? null : AppBar(
              title: const Text('Sub-Admin Management'),
              backgroundColor: AppColors.primary, foregroundColor: Colors.white,
            ),
            body: state.subAdminListLoading
                ? const Center(child: CircularProgressIndicator())
                : state.subAdminListError != null
                    ? _errorView(state.subAdminListError!, () => bloc.add(const FetchSubAdmins()))
                    : state.subAdmins.isEmpty
                        ? Center(
                            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                              Icon(Icons.people_outline, size: 64, color: AppColors.gray300),
                              const Gap(16),
                              const Text('No Sub-Admins yet', style: TextStyle(fontSize: 18,
                                  fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                              const Gap(8),
                              const Text('Create the first Sub-Admin to delegate\ntransit ecosystem management.',
                                  textAlign: TextAlign.center, style: TextStyle(color: AppColors.textTertiary)),
                            ]),
                          )
                        : RefreshIndicator(
                            onRefresh: () async => bloc.add(const FetchSubAdmins()),
                            child: ListView(padding: const EdgeInsets.all(16), children: [
                              Row(children: [
                                const Expanded(child: Text('Quad Sub-Admin Hierarchy',
                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary))),
                                Text('${state.subAdmins.length} assigned',
                                    style: const TextStyle(color: AppColors.textTertiary)),
                              ]),
                              const Gap(4),
                              const Text('Four verticals: Bus Transit · Goods & Logistics · '
                                  'Commercial Marketplace · Financial Auditor',
                                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                              const Gap(20),
                              for (final sa in state.subAdmins) _card(ctx, sa, bloc),
                            ]),
                          ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () => context.go('/sub-admins/add'),
              icon: const Icon(Icons.person_add_alt_rounded),
              label: const Text('Add Sub-Admin'),
              backgroundColor: AppColors.primary, foregroundColor: Colors.white,
            ),
          );
        },
      ),
    );
  }

  Widget _errorView(String msg, VoidCallback retry) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.error_outline, size: 48, color: AppColors.error),
      const Gap(12), Text(msg, style: const TextStyle(color: AppColors.textSecondary)),
      const Gap(12), ElevatedButton(onPressed: retry, child: const Text('Retry')),
    ]),
  );

  Widget _card(BuildContext ctx, Map<String, dynamic> sa, SubAdminBloc bloc) {
    final vertical = sa['vertical'] as String?;
    final color = _color(vertical);
    final isActive = sa['status'] == 'active';

    return Card(
      margin: const EdgeInsets.only(bottom: 12), elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(children: [
          Container(width: 48, height: 48,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
            child: Icon(_icon(vertical), color: color, size: 24)),
          const Gap(14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(sa['name'] as String? ?? '—', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const Gap(2),
            Text(sa['email'] as String? ?? '', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            const Gap(4),
            Row(children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                child: Text(_label(vertical), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color))),
              const Gap(8), _statusChip(sa['status'] as String? ?? 'active'),
            ]),
          ])),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.gray500),
            onSelected: (action) => _handleAction(ctx, action, sa, bloc),
            itemBuilder: (_) {
              final items = <PopupMenuEntry<String>>[];
              if (isActive) {
                items.addAll([
                  _menuItem('edit', 'Edit', Icons.edit),
                  _menuItem('toggle_status', 'Suspend', Icons.block, AppColors.warning),
                  _menuItem('change_vertical', 'Change Vertical', Icons.swap_horiz),
                  _menuItem('reset_password', 'Reset Password', Icons.lock_reset),
                  _menuItem('delete', 'Delete', Icons.delete, AppColors.error),
                ]);
              } else if (sa['status'] == 'suspended') {
                items.addAll([
                  _menuItem('toggle_status', 'Activate', Icons.check_circle, AppColors.success),
                  _menuItem('delete', 'Delete', Icons.delete, AppColors.error),
                ]);
              } else if (sa['status'] == 'deleted') {
                items.addAll([_menuItem('restore', 'Restore', Icons.restore, AppColors.success)]);
              }
              return items;
            },
          ),
        ]),
      ),
    );
  }

  PopupMenuItem<String> _menuItem(String value, String title, IconData icon, [Color? color]) =>
      PopupMenuItem(value: value, child: ListTile(
        leading: Icon(icon, color: color), title: Text(title, style: color != null ? TextStyle(color: color) : null), dense: true));

  Widget _statusChip(String status) {
    final c = status == 'deleted' ? AppColors.error : status == 'suspended' ? AppColors.warning : AppColors.success;
    final l = status == 'deleted' ? 'DELETED' : status == 'suspended' ? 'SUSPENDED' : 'ACTIVE';
    return Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: c.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(l, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: c)));
  }

  void _handleAction(BuildContext ctx, String action, Map<String, dynamic> sa, SubAdminBloc bloc) {
    final id = sa['id'] as String;
    switch (action) {
      case 'edit': _showEditDialog(ctx, sa, bloc); break;
      case 'toggle_status': bloc.add(ToggleSubAdminStatus(id)); break;
      case 'change_vertical': _showChangeVerticalDialog(ctx, sa, bloc); break;
      case 'reset_password': _showResetPasswordDialog(ctx, sa, bloc); break;
      case 'delete':
        showDialog(context: ctx, builder: (dctx) => AlertDialog(
          title: const Text('Delete Sub-Admin?'),
          content: Text('This will revoke all access for ${sa['name']}.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
              onPressed: () { Navigator.pop(dctx); bloc.add(DeleteSubAdmin(id)); },
              child: const Text('Delete')),
          ]));
        break;
      case 'restore': bloc.add(RestoreSubAdmin(id)); break;
    }
  }

  void _showEditDialog(BuildContext ctx, Map<String, dynamic> sa, SubAdminBloc bloc) {
    final nameCtrl = TextEditingController(text: sa['name']);
    final emailCtrl = TextEditingController(text: sa['email']);
    showDialog(context: ctx, builder: (dctx) => AlertDialog(
      title: const Text('Edit Sub-Admin'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
        const Gap(12),
        TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dctx), child: const Text('Cancel')),
        ElevatedButton(onPressed: () {
          Navigator.pop(dctx);
          bloc.add(EditSubAdmin(adminId: sa['id'] as String, data: {'name': nameCtrl.text.trim(), 'email': emailCtrl.text.trim()}));
        }, child: const Text('Save')),
      ],
    ));
  }

  void _showChangeVerticalDialog(BuildContext ctx, Map<String, dynamic> sa, SubAdminBloc bloc) {
    String selected = sa['vertical'] ?? 'bus_transit';
    showDialog(context: ctx, builder: (dctx) => StatefulBuilder(builder: (_, setDs) => AlertDialog(
      title: const Text('Change Vertical'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        for (final v in [{'code': 'bus_transit', 'label': 'Bus Transit'},
          {'code': 'goods_logistics', 'label': 'Goods & Logistics'},
          {'code': 'commercial_marketplace', 'label': 'Commercial Marketplace'},
          {'code': 'financial_auditor', 'label': 'Financial Auditor'}])
          RadioListTile<String>(title: Text(v['label'] as String), value: v['code'] as String,
            groupValue: selected, onChanged: (v) => setDs(() => selected = v!)),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dctx), child: const Text('Cancel')),
        ElevatedButton(onPressed: () {
          Navigator.pop(dctx);
          bloc.add(ChangeSubAdminVertical(adminId: sa['id'] as String, newVertical: selected));
        }, child: const Text('Change')),
      ],
    )));
  }

  void _showResetPasswordDialog(BuildContext ctx, Map<String, dynamic> sa, SubAdminBloc bloc) {
    final passCtrl = TextEditingController();
    showDialog(context: ctx, builder: (dctx) => AlertDialog(
      title: const Text('Reset Password'),
      content: TextField(controller: passCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'New Password (min 8 chars)')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dctx), child: const Text('Cancel')),
        ElevatedButton(onPressed: () {
          final pass = passCtrl.text.trim();
          if (pass.length < 8) {
            ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Minimum 8 characters')));
            return;
          }
          Navigator.pop(dctx);
          bloc.add(ResetSubAdminPassword(adminId: sa['id'] as String, newPassword: pass));
        }, child: const Text('Reset')),
      ],
    ));
  }
}
