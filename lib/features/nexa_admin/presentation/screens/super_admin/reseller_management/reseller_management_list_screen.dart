import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nexatrace_system/features/nexa_admin/presentation/bloc/reseller_management/reseller_management_bloc.dart';
import 'package:nexatrace_system/shared/theme/colors.dart';
import 'package:nexatrace_system/shared/widgets/app_bars/custom_app_bar.dart';
import 'package:nexatrace_system/shared/widgets/buttons/primary_button.dart';
import 'package:nexatrace_system/shared/widgets/empty_states/empty_state_widget.dart';
import 'package:nexatrace_system/shared/widgets/error_state/error_state_widget.dart';
import 'package:nexatrace_system/shared/widgets/inputs/search_field.dart';
import 'package:nexatrace_system/shared/widgets/loading/loading_indicator.dart';

class ResellerManagementListScreen extends StatefulWidget {
  final bool inShell;
  const ResellerManagementListScreen({super.key, this.inShell = false});

  @override
  State<ResellerManagementListScreen> createState() =>
      _ResellerManagementListScreenState();
}

class _ResellerManagementListScreenState
    extends State<ResellerManagementListScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  String _search = '';
  String? _statusFilter;
  String? _cityFilter;
  bool _initialised = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _load({int page = 1}) {
    final bloc = context.read<ResellerManagementBloc>();
    // Skip if already loading the same page (prevents duplicate API calls)
    if (bloc.state.status == ResellerLoadStatus.loading &&
        page == bloc.state.page) {
      return;
    }
    bloc.add(
      LoadResellers(
        search: _search,
        status: _statusFilter,
        city: _cityFilter,
        page: page,
      ),
    );
    _initialised = true;
  }

  void _onSearch(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (_search != v) {
        _search = v;
        _load();
      }
    });
  }

  Color _statusColor(String status) {
    return switch (status.toLowerCase()) {
      'active' => AppColors.success,
      'inactive' => AppColors.gray500,
      'suspended' => AppColors.warning,
      _ => AppColors.gray500,
    };
  }

  String _statusLabel(String status) {
    return switch (status.toLowerCase()) {
      'active' => 'Active',
      'inactive' => 'Inactive',
      'suspended' => 'Suspended',
      _ => status,
    };
  }

  // ── Quick Actions — center-aligned dialog ───────────────────────
  void _showProofDialog(String id, String name, Map<String, dynamic> r) {
    final url = r['business_proof_url']?.toString() ?? '';
    final title = r['business_proof_title']?.toString() ?? 'No title';
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Proof: $name'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Title: $title',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8.h),
            if (url.isNotEmpty)
              Text(
                'Document available at:\n$url',
                style: TextStyle(fontSize: 11.sp, color: AppColors.gray500),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showQuickActions(Map<String, dynamic> reseller) {
    final id = reseller['id']?.toString() ?? '';
    final name = reseller['name']?.toString() ?? 'Reseller';
    final status = reseller['status']?.toString() ?? 'active';
    final purchaseApproved =
        reseller['purchase_approved'] == true ||
        reseller['purchase_approved'] == '1';
    final hasProof =
        (reseller['business_proof_url']?.toString() ?? '').isNotEmpty;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.r),
        ),
        titlePadding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 0),
        contentPadding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 8.h),
        title: Column(
          children: [
            Text(
              name,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 2.h),
            Text(
              'ID: $id',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.gray500),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Purchase Approval (always show if not approved) ──
            if (!purchaseApproved)
              _actionTile(
                icon: Icons.check_circle_outline,
                color: AppColors.success,
                label: 'Approve Purchase Access',
                onTap: () {
                  Navigator.pop(ctx);
                  _confirmAction(
                    title: 'Approve $name?',
                    message:
                        'This allows the reseller to place orders on the marketplace.',
                    onConfirm: () {
                      context.read<ResellerManagementBloc>().add(
                        ApproveResellerPurchase(id),
                      );
                    },
                  );
                },
              ),
            if (purchaseApproved)
              _actionTile(
                icon: Icons.cancel_outlined,
                color: AppColors.warning,
                label: 'Revoke Purchase Access',
                onTap: () {
                  Navigator.pop(ctx);
                  _confirmAction(
                    title: 'Revoke purchase access for $name?',
                    message:
                        'The reseller will no longer be able to place orders.',
                    onConfirm: () {
                      context.read<ResellerManagementBloc>().add(
                        RejectResellerPurchase(id),
                      );
                    },
                  );
                },
              ),
            // ── View Proof (only if uploaded) ──────────────
            if (hasProof)
              _actionTile(
                icon: Icons.description_outlined,
                color: AppColors.info,
                label: 'View Business Proof',
                onTap: () {
                  Navigator.pop(ctx);
                  _showProofDialog(id, name, reseller);
                },
              ),
            // Existing actions
            _actionTile(
              icon: status == 'active'
                  ? Icons.toggle_off_outlined
                  : Icons.toggle_on_outlined,
              color: AppColors.primary,
              label: status == 'active' ? 'Deactivate' : 'Activate',
              onTap: () {
                Navigator.pop(ctx);
                _confirmAction(
                  title: status == 'active'
                      ? 'Deactivate $name?'
                      : 'Activate $name?',
                  message: status == 'active'
                      ? 'The reseller will lose access to place new orders.'
                      : 'The reseller will regain full marketplace access.',
                  onConfirm: () {
                    context.read<ResellerManagementBloc>().add(
                      UpdateResellerStatus(
                        id: id,
                        status: status == 'active' ? 'inactive' : 'active',
                      ),
                    );
                  },
                );
              },
            ),
            _actionTile(
              icon: status == 'suspended'
                  ? Icons.play_circle_outline
                  : Icons.pause_circle_outline,
              color: AppColors.warning,
              label: status == 'suspended' ? 'Reinstate' : 'Suspend',
              onTap: () {
                Navigator.pop(ctx);
                _confirmAction(
                  title: status == 'suspended'
                      ? 'Reinstate $name?'
                      : 'Suspend $name?',
                  message: status == 'suspended'
                      ? 'The reseller will be able to place orders again.'
                      : 'The reseller will be restricted to viewing history only.',
                  isDestructive: status != 'suspended',
                  onConfirm: () {
                    context.read<ResellerManagementBloc>().add(
                      ToggleSuspendReseller(
                        id: id,
                        suspend: status != 'suspended',
                      ),
                    );
                  },
                );
              },
            ),
            _actionTile(
              icon: Icons.edit_outlined,
              color: AppColors.info,
              label: 'Edit Reseller',
              onTap: () {
                Navigator.pop(ctx);
                _showEditDialog(reseller);
              },
            ),
            _actionTile(
              icon: Icons.delete_outline,
              color: AppColors.error,
              label: 'Delete Reseller',
              textColor: AppColors.error,
              onTap: () {
                Navigator.pop(ctx);
                _confirmAction(
                  title: 'Delete $name?',
                  message:
                      'This will soft-delete the reseller. They will no longer appear in the active list.',
                  isDestructive: true,
                  onConfirm: () {
                    context.read<ResellerManagementBloc>().add(
                      DeleteReseller(id),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionTile({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return ListTile(
      dense: true,
      visualDensity: VisualDensity.compact,
      contentPadding: EdgeInsets.symmetric(horizontal: 4.w),
      leading: Icon(icon, color: color, size: 22.sp),
      title: Text(
        label,
        style: TextStyle(fontSize: 14.sp, color: textColor),
      ),
      onTap: onTap,
    );
  }

  void _confirmAction({
    required String title,
    required String message,
    required VoidCallback onConfirm,
    bool isDestructive = false,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.r),
        ),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          PrimaryButton(
            text: 'Confirm',
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm();
            },
          ),
        ],
      ),
    );
  }

  void _showEditDialog(Map<String, dynamic> reseller) {
    final id = reseller['id']?.toString() ?? '';
    final nameCtl = TextEditingController(
      text: reseller['name']?.toString() ?? '',
    );
    final bizCtl = TextEditingController(
      text: reseller['business_name']?.toString() ?? '',
    );
    final regCtl = TextEditingController(
      text: reseller['registration_no']?.toString() ?? '',
    );
    final emailCtl = TextEditingController(
      text: reseller['email']?.toString() ?? '',
    );
    final phoneCtl = TextEditingController(
      text: reseller['phone']?.toString() ?? '',
    );
    final cityCtl = TextEditingController(
      text: reseller['city']?.toString() ?? '',
    );
    final addrCtl = TextEditingController(
      text: reseller['address']?.toString() ?? '',
    );
    final planCtl = TextEditingController(
      text: reseller['plan_id']?.toString() ?? '',
    );
    var purchaseApproved =
        reseller['purchase_approved'] == true ||
        reseller['purchase_approved'] == '1';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (_, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
          title: const Text('Edit Reseller'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _field('Name *', nameCtl),
                SizedBox(height: 10.h),
                _field('Business Name *', bizCtl),
                SizedBox(height: 10.h),
                _field('Registration No', regCtl),
                SizedBox(height: 10.h),
                _field('Email *', emailCtl),
                SizedBox(height: 10.h),
                _field('Phone *', phoneCtl),
                SizedBox(height: 10.h),
                _field('City', cityCtl),
                SizedBox(height: 10.h),
                _field('Address', addrCtl),
                SizedBox(height: 10.h),
                _field('Plan ID', planCtl),
                SizedBox(height: 12.h),
                // Purchase approval toggle
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Purchase Approved',
                    style: TextStyle(fontSize: 13.sp),
                  ),
                  value: purchaseApproved,
                  onChanged: (v) => setDialogState(() => purchaseApproved = v),
                  activeColor: AppColors.success,
                  dense: true,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            PrimaryButton(
              text: 'Save',
              onPressed: () {
                Navigator.pop(ctx);
                context.read<ResellerManagementBloc>().add(
                  UpdateReseller(
                    id: id,
                    name: nameCtl.text,
                    businessName: bizCtl.text,
                    registrationNo: regCtl.text,
                    email: emailCtl.text,
                    phone: phoneCtl.text,
                    city: cityCtl.text,
                    address: addrCtl.text,
                    planId: planCtl.text,
                    purchaseApproved: purchaseApproved,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctl) {
    return TextField(
      controller: ctl,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      ),
    );
  }

  void _copyEcomLink(String id) {
    const link = 'http://135.181.46.27/reseller/login';
    Clipboard.setData(const ClipboardData(text: link));
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text('Copied: $link'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Reseller Management',
        showBackButton: !widget.inShell,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            tooltip: 'Add Reseller',
            onPressed: () => context.go('/resellers/add'),
          ),
        ],
      ),
      body: BlocListener<ResellerManagementBloc, ResellerManagementState>(
        listener: (_, state) {
          // ── Success feedback ──────────────────────────────────
          if (state.status == ResellerLoadStatus.actionSuccess) {
            if (state.message != null) {
              ScaffoldMessenger.of(context)
                ..clearSnackBars()
                ..showSnackBar(
                  SnackBar(
                    content: Text(state.message!),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                  ),
                );
              context.read<ResellerManagementBloc>().add(
                ClearResellerMessage(),
              );
            }
          }

          // ── Error feedback ───────────────────────────────────
          if (state.status == ResellerLoadStatus.error &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(context)
              ..clearSnackBars()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 4),
                ),
              );
          }
        },
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 0),
                  child: SearchField(
                    controller: _searchController,
                    hintText: 'Search by name, email, or city...',
                    onChanged: _onSearch,
                  ),
                ),
                SizedBox(height: 8.h),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                    children: [
                      _filterChip('All', null, _statusFilter),
                      _filterChip('Active', 'active', _statusFilter),
                      _filterChip('Inactive', 'inactive', _statusFilter),
                      _filterChip('Suspended', 'suspended', _statusFilter),
                    ],
                  ),
                ),
                SizedBox(height: 4.h),
                const Divider(),
                SizedBox(height: 4.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                    children: [
                      Text(
                        'Total: ',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.gray500,
                        ),
                      ),
                      BlocBuilder<
                        ResellerManagementBloc,
                        ResellerManagementState
                      >(
                        builder: (_, s) => Text(
                          '${s.total} resellers',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child:
                      BlocBuilder<
                        ResellerManagementBloc,
                        ResellerManagementState
                      >(
                        builder: (context, state) {
                          // ── First load — full-screen spinner ────────
                          if (!_initialised &&
                              state.status == ResellerLoadStatus.loading &&
                              state.resellers.isEmpty) {
                            return const Center(child: LoadingIndicator());
                          }

                          // ── Error with no data ─────────────────────
                          if (state.status == ResellerLoadStatus.error &&
                              state.resellers.isEmpty) {
                            return ErrorState(
                              title: 'Error',
                              message: state.errorMessage ?? 'Failed to load',
                              onRetry: () => _load(),
                            );
                          }

                          // ── Empty (only when truly no data, not during loading) ──
                          if (_initialised &&
                              state.resellers.isEmpty &&
                              state.status != ResellerLoadStatus.loading) {
                            return const EmptyState(
                              title: 'No Resellers',
                              description: 'No resellers match your filters.',
                              icon: Icons.people_outline,
                            );
                          }

                          // ── Data present ──────────────────────────
                          return Column(
                            children: [
                              if (state.status == ResellerLoadStatus.loading)
                                const LinearProgressIndicator(minHeight: 2),
                              Expanded(
                                child: ListView.separated(
                                  padding: EdgeInsets.fromLTRB(
                                    16.w,
                                    6.h,
                                    16.w,
                                    80.h,
                                  ),
                                  itemCount: state.resellers.length,
                                  separatorBuilder: (_, __) =>
                                      SizedBox(height: 6.h),
                                  itemBuilder: (_, i) =>
                                      _resellerCard(state.resellers[i]),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                ),
              ],
            ),

            // ── Loading overlay during action ────────────────────
            BlocBuilder<ResellerManagementBloc, ResellerManagementState>(
              builder: (_, state) {
                final showOverlay =
                    _initialised &&
                    state.resellers.isNotEmpty &&
                    (state.status == ResellerLoadStatus.loading ||
                        state.status == ResellerLoadStatus.actionSuccess);
                if (!showOverlay) return const SizedBox.shrink();
                return Container(
                  color: Colors.black.withValues(alpha: 0.35),
                  child: const Center(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Processing…'),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _resellerCard(Map<String, dynamic> r) {
    final name = r['name']?.toString() ?? '—';
    final bizName = r['business_name']?.toString() ?? '—';
    final city = r['city']?.toString() ?? '—';
    final email = r['email']?.toString() ?? '—';
    final phone = r['phone']?.toString() ?? '—';
    final status = r['status']?.toString() ?? 'active';
    final plan = r['plan_name']?.toString();
    final color = _statusColor(status);
    final purchaseApproved =
        r['purchase_approved'] == true || r['purchase_approved'] == '1';
    final hasProof = (r['business_proof_url']?.toString() ?? '').isNotEmpty;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
      child: InkWell(
        onTap: () => _showQuickActions(r),
        borderRadius: BorderRadius.circular(10.r),
        child: Padding(
          padding: EdgeInsets.all(14.w),
          child: Row(
            children: [
              Container(
                width: 10.w,
                height: 10.h,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      bizName,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: AppColors.gray600),
                    ),
                    SizedBox(height: 2.h),
                    Wrap(
                      spacing: 12.w,
                      runSpacing: 2.h,
                      children: [
                        _meta(Icons.location_on_outlined, city),
                        _meta(Icons.email_outlined, email),
                        _meta(Icons.phone_outlined, phone),
                        if (plan != null) _meta(Icons.card_membership, plan),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 3.h,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      _statusLabel(status),
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ),
                  if (hasProof)
                    Padding(
                      padding: EdgeInsets.only(top: 4.h),
                      child: Icon(
                        purchaseApproved ? Icons.verified : Icons.pending,
                        size: 16.sp,
                        color: purchaseApproved
                            ? AppColors.success
                            : AppColors.warning,
                      ),
                    ),
                  SizedBox(height: 6.h),
                  IconButton(
                    icon: Icon(Icons.link, size: 18.sp, color: AppColors.info),
                    tooltip: 'Copy E-commerce link',
                    onPressed: () => _copyEcomLink(r['id']?.toString() ?? ''),
                    constraints: BoxConstraints(
                      minWidth: 28.w,
                      minHeight: 28.h,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _meta(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12.sp, color: AppColors.gray400),
        SizedBox(width: 3.w),
        Text(
          text,
          style: TextStyle(fontSize: 10.sp, color: AppColors.gray500),
        ),
      ],
    );
  }

  Widget _filterChip(String label, String? value, String? current) {
    final selected = current == value;
    return Padding(
      padding: EdgeInsets.only(right: 6.w),
      child: ChoiceChip(
        label: Text(label, style: TextStyle(fontSize: 11.sp)),
        selected: selected,
        onSelected: (_) {
          setState(() => _statusFilter = value);
          _load();
        },
      ),
    );
  }
}
