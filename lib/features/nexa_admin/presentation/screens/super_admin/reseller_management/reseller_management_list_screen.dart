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

  // ── Quick Actions — compact bottom sheet ────────────────────────
  void _showQuickActions(Map<String, dynamic> reseller) {
    final id = reseller['id']?.toString() ?? '';
    final name = reseller['name']?.toString() ?? 'Reseller';
    final status = reseller['status']?.toString() ?? 'active';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 16.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 36.w,
              height: 4.h,
              margin: EdgeInsets.only(bottom: 10.h),
              decoration: BoxDecoration(
                color: AppColors.gray300,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
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
            SizedBox(height: 10.h),

            _actionTile(
              icon: status == 'active'
                  ? Icons.toggle_off_outlined
                  : Icons.toggle_on_outlined,
              color: AppColors.primary,
              label: status == 'active' ? 'Deactivate' : 'Activate',
              onTap: () {
                Navigator.pop(context);
                _confirmAction(
                  title: status == 'active'
                      ? 'Deactivate $name?'
                      : 'Activate $name?',
                  message: status == 'active'
                      ? 'The reseller will lose access to place new orders.'
                      : 'The reseller will regain full marketplace access.',
                  onConfirm: () => context.read<ResellerManagementBloc>().add(
                    UpdateResellerStatus(
                      id: id,
                      status: status == 'active' ? 'inactive' : 'active',
                    ),
                  ),
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
                Navigator.pop(context);
                _confirmAction(
                  title: status == 'suspended'
                      ? 'Reinstate $name?'
                      : 'Suspend $name?',
                  message: status == 'suspended'
                      ? 'The reseller will be able to place orders again.'
                      : 'The reseller will be restricted to viewing history only.',
                  isDestructive: status != 'suspended',
                  onConfirm: () => context.read<ResellerManagementBloc>().add(
                    ToggleSuspendReseller(
                      id: id,
                      suspend: status != 'suspended',
                    ),
                  ),
                );
              },
            ),

            _actionTile(
              icon: Icons.edit_outlined,
              color: AppColors.info,
              label: 'Edit Reseller',
              onTap: () {
                Navigator.pop(context);
                _showEditDialog(reseller);
              },
            ),

            _actionTile(
              icon: Icons.delete_outline,
              color: AppColors.error,
              label: 'Delete Reseller',
              textColor: AppColors.error,
              onTap: () {
                Navigator.pop(context);
                _confirmAction(
                  title: 'Delete $name?',
                  message:
                      'This will soft-delete the reseller. They will no longer appear in the active list.',
                  isDestructive: true,
                  onConfirm: () => context.read<ResellerManagementBloc>().add(
                    DeleteReseller(id),
                  ),
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
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.r),
        ),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          PrimaryButton(
            text: 'Confirm',
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
          ),
        ],
      ),
    );
  }

  void _showEditDialog(Map<String, dynamic> reseller) {
    final nameCtl = TextEditingController(
      text: reseller['name']?.toString() ?? '',
    );
    final bizCtl = TextEditingController(
      text: reseller['business_name']?.toString() ?? '',
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
    final id = reseller['id']?.toString() ?? '';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.r),
        ),
        title: const Text('Edit Reseller'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _field('Name', nameCtl),
              SizedBox(height: 10.h),
              _field('Business Name', bizCtl),
              SizedBox(height: 10.h),
              _field('Email', emailCtl),
              SizedBox(height: 10.h),
              _field('Phone', phoneCtl),
              SizedBox(height: 10.h),
              _field('City', cityCtl),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          PrimaryButton(
            text: 'Save',
            onPressed: () {
              Navigator.pop(context);
              context.read<ResellerManagementBloc>().add(
                UpdateReseller(
                  id: id,
                  name: nameCtl.text,
                  businessName: bizCtl.text,
                  email: emailCtl.text,
                  phone: phoneCtl.text,
                  city: cityCtl.text,
                ),
              );
            },
          ),
        ],
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
          if (state.message != null) {
            ScaffoldMessenger.of(context)
              ..clearSnackBars()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.message!),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            context.read<ResellerManagementBloc>().add(ClearResellerMessage());
          }
          if (state.errorMessage != null &&
              state.status == ResellerLoadStatus.error) {
            ScaffoldMessenger.of(context)
              ..clearSnackBars()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
          }
        },
        child: Column(
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
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.gray500),
                  ),
                  BlocBuilder<ResellerManagementBloc, ResellerManagementState>(
                    builder: (_, s) => Text(
                      '${s.total} resellers',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<ResellerManagementBloc, ResellerManagementState>(
                builder: (context, state) {
                  // First load — show full spinner
                  if (!_initialised && state.resellers.isEmpty) {
                    return const Center(child: LoadingIndicator());
                  }

                  // Error on empty data
                  if (state.status == ResellerLoadStatus.error &&
                      state.resellers.isEmpty) {
                    return ErrorState(
                      title: 'Error',
                      message: state.errorMessage ?? 'Failed to load',
                      onRetry: () => _load(),
                    );
                  }

                  // Empty
                  if (state.resellers.isEmpty &&
                      state.status != ResellerLoadStatus.loading) {
                    return const EmptyState(
                      title: 'No Resellers',
                      description: 'No resellers match your filters.',
                      icon: Icons.people_outline,
                    );
                  }

                  return Column(
                    children: [
                      // Subtle loading bar when refreshing with existing data
                      if (state.status == ResellerLoadStatus.loading)
                        const LinearProgressIndicator(minHeight: 2),
                      Expanded(
                        child: ListView.separated(
                          padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 80.h),
                          itemCount: state.resellers.length,
                          separatorBuilder: (_, __) => SizedBox(height: 6.h),
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
