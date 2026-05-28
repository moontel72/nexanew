import 'package:flutter/material.dart' hide SearchBar;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:trace_odd/features/factory/admin/presentation/bloc/store_keepers/store_keepers_bloc.dart';
import 'package:trace_odd/shared/theme/colors.dart';
import 'package:trace_odd/shared/widgets/app_bars/custom_app_bar.dart';
import 'package:trace_odd/shared/widgets/buttons/primary_button.dart';
import 'package:trace_odd/shared/widgets/empty_states/empty_state_widget.dart';
import 'package:trace_odd/shared/widgets/loading/loading_indicator.dart';

class StoreKeepersListScreen extends StatefulWidget {
  const StoreKeepersListScreen({super.key});
  @override
  State<StoreKeepersListScreen> createState() => _StoreKeepersListScreenState();
}

class _StoreKeepersListScreenState extends State<StoreKeepersListScreen> {
  final _searchController = TextEditingController();
  String? _statusFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadData() {
    context.read<StoreKeepersBloc>().add(
      LoadStoreKeepers(
        search: _searchController.text.trim().isEmpty
            ? null
            : _searchController.text.trim(),
        statusFilter: _statusFilter,
      ),
    );
  }

  void _goToCreate() => context.go('/factory/store-keepers/create');

  Future<void> _confirmDelete(StoreKeeper keeper) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Store Keeper'),
        content: Text('Delete "${keeper.name}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      context.read<StoreKeepersBloc>().add(DeleteStoreKeeper(id: keeper.id));
    }
  }

  void _showEditDialog(StoreKeeper keeper) {
    final nameC = TextEditingController(text: keeper.name);
    final empC = TextEditingController(text: keeper.employeeId ?? '');
    final phoneC = TextEditingController(text: keeper.phone ?? '');
    final emailC = TextEditingController(text: keeper.email);
    String? shift = keeper.dutyShift;
    String? st = keeper.status;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => BlocProvider.value(
        value: context.read<StoreKeepersBloc>(),
        child: BlocConsumer<StoreKeepersBloc, StoreKeepersState>(
          listenWhen: (prev, curr) =>
              curr.status == StoreKeepersStatus.updated ||
              curr.status == StoreKeepersStatus.error,
          listener: (context, state) {
            if (state.status == StoreKeepersStatus.updated) {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(
                this.context,
              ).showSnackBar(const SnackBar(content: Text('Updated')));
            }
            if (state.status == StoreKeepersStatus.error &&
                state.errorMessage != null) {
              ScaffoldMessenger.of(this.context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          builder: (context, state) {
            final busy = state.status == StoreKeepersStatus.updating;
            return AlertDialog(
              title: const Text('Edit Store Keeper'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameC,
                        decoration: const InputDecoration(labelText: 'Name *'),
                        validator: (v) =>
                            (v ?? '').trim().isEmpty ? 'Required' : null,
                      ),
                      SizedBox(height: 12.h),
                      TextFormField(
                        controller: emailC,
                        decoration: const InputDecoration(labelText: 'Email *'),
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) => (v ?? '').trim().isEmpty
                            ? 'Required'
                            : (!RegExp(
                                    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                                  ).hasMatch(v!.trim())
                                  ? 'Invalid email'
                                  : null),
                      ),
                      SizedBox(height: 12.h),
                      TextFormField(
                        controller: empC,
                        decoration: const InputDecoration(
                          labelText: 'Employee ID',
                        ),
                      ),
                      SizedBox(height: 12.h),
                      TextFormField(
                        controller: phoneC,
                        decoration: const InputDecoration(labelText: 'Phone'),
                        keyboardType: TextInputType.phone,
                      ),
                      SizedBox(height: 12.h),
                      DropdownButtonFormField<String>(
                        initialValue: shift,
                        decoration: const InputDecoration(
                          labelText: 'Duty Shift',
                        ),
                        items: const [
                          DropdownMenuItem(value: null, child: Text('None')),
                          DropdownMenuItem(
                            value: 'Morning',
                            child: Text('Morning'),
                          ),
                          DropdownMenuItem(
                            value: 'Evening',
                            child: Text('Evening'),
                          ),
                          DropdownMenuItem(
                            value: 'Night',
                            child: Text('Night'),
                          ),
                          DropdownMenuItem(
                            value: 'General',
                            child: Text('General'),
                          ),
                        ],
                        onChanged: (v) => shift = v,
                      ),
                      SizedBox(height: 12.h),
                      DropdownButtonFormField<String>(
                        initialValue: st,
                        decoration: const InputDecoration(labelText: 'Status'),
                        items: const [
                          DropdownMenuItem(
                            value: 'active',
                            child: Text('Active'),
                          ),
                          DropdownMenuItem(
                            value: 'inactive',
                            child: Text('Inactive'),
                          ),
                        ],
                        onChanged: (v) => st = v,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: busy ? null : () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel'),
                ),
                PrimaryButton(
                  text: 'Save',
                  icon: Icons.save,
                  isLoading: busy,
                  backgroundColor: AppColors.secondary,
                  textColor: Colors.white,
                  onPressed: () {
                    if (!(formKey.currentState?.validate() ?? false)) return;
                    context.read<StoreKeepersBloc>().add(
                      UpdateStoreKeeper(
                        id: keeper.id,
                        name: nameC.text.trim(),
                        email: emailC.text.trim(),
                        employeeId: empC.text.trim().isEmpty
                            ? null
                            : empC.text.trim(),
                        phone: phoneC.text.trim().isEmpty
                            ? null
                            : phoneC.text.trim(),
                        dutyShift: shift,
                        status: st,
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showAudit(String storeKeeperId, String name) {
    context.read<StoreKeepersBloc>().add(
      LoadStoreKeeperAuditTrail(id: storeKeeperId),
    );
    showDialog(
      context: context,
      builder: (ctx) => BlocProvider.value(
        value: context.read<StoreKeepersBloc>(),
        child: BlocBuilder<StoreKeepersBloc, StoreKeepersState>(
          builder: (context, state) => AlertDialog(
            title: Text('Audit - $name'),
            content: SizedBox(
              width: double.maxFinite,
              child: state.status == StoreKeepersStatus.auditLoading
                  ? const Center(child: LoadingIndicator())
                  : state.auditEntries.isEmpty
                  ? const Text('No audit entries.')
                  : ListView.separated(
                      shrinkWrap: true,
                      itemCount: state.auditEntries.length,
                      separatorBuilder: (_, _) => const Divider(),
                      itemBuilder: (_, i) {
                        final e = state.auditEntries[i];
                        return ListTile(
                          dense: true,
                          title: Text(
                            e.action,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            '${e.type}: ${e.code}\n${e.timestamp ?? ''}',
                          ),
                        );
                      },
                    ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: CustomAppBar(
        title: 'Store Keepers',
        showBackButton: false,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: PrimaryButton(
              onPressed: _goToCreate,
              text: 'Create',
              icon: Icons.add,
              backgroundColor: AppColors.secondary,
              textColor: Colors.white,
              height: 38,
            ),
          ),
        ],
      ),
      body: BlocConsumer<StoreKeepersBloc, StoreKeepersState>(
        listenWhen: (prev, curr) =>
            curr.status == StoreKeepersStatus.deleted ||
            curr.status == StoreKeepersStatus.error,
        listener: (context, state) {
          if (state.status == StoreKeepersStatus.deleted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Deleted')));
          }
          if (state.status == StoreKeepersStatus.error &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final busy =
              state.status == StoreKeepersStatus.loading ||
              state.status == StoreKeepersStatus.deleting;
          return Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by name, email, or employee ID...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.trim().isEmpty
                        ? null
                        : IconButton(
                            onPressed: () {
                              _searchController.clear();
                              _loadData();
                              setState(() {});
                            },
                            icon: const Icon(Icons.clear),
                          ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                  onSubmitted: (_) => _loadData(),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  children: <Widget>[
                    _chip('All', _statusFilter == null, null, () {
                      setState(() => _statusFilter = null);
                      _loadData();
                    }),
                    SizedBox(width: 8.w),
                    _chip(
                      'Active',
                      _statusFilter == 'active',
                      AppColors.success,
                      () {
                        setState(
                          () => _statusFilter = _statusFilter == 'active'
                              ? null
                              : 'active',
                        );
                        _loadData();
                      },
                    ),
                    SizedBox(width: 8.w),
                    _chip(
                      'Inactive',
                      _statusFilter == 'inactive',
                      AppColors.error,
                      () {
                        setState(
                          () => _statusFilter = _statusFilter == 'inactive'
                              ? null
                              : 'inactive',
                        );
                        _loadData();
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8.h),
              Expanded(
                child: busy
                    ? const Center(child: LoadingIndicator())
                    : state.storeKeepers.isEmpty
                    ? SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.all(16.w),
                          child: EmptyState(
                            title: 'No store keepers',
                            description:
                                'Add a store keeper to manage inventory.',
                            icon: Icons.people_outline,
                            iconColor: AppColors.secondary,
                            actionButton: PrimaryButton(
                              text: 'Add Store Keeper',
                              icon: Icons.add,
                              backgroundColor: AppColors.secondary,
                              textColor: Colors.white,
                              onPressed: _goToCreate,
                            ),
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: EdgeInsets.all(16.w),
                        itemCount: state.storeKeepers.length,
                        separatorBuilder: (_, _) => SizedBox(height: 12.h),
                        itemBuilder: (_, i) =>
                            _buildCard(state.storeKeepers[i]),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCard(StoreKeeper k) {
    final active = k.status.toLowerCase() == 'active';
    final badgeColor = active ? AppColors.success : AppColors.error;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    k.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: badgeColor),
                  ),
                  child: Text(
                    k.status.toUpperCase(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: badgeColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            if (k.employeeId?.isNotEmpty == true)
              _row(Icons.badge_outlined, 'ID', k.employeeId!),
            _row(Icons.email_outlined, 'Email', k.email),
            if (k.phone?.isNotEmpty == true)
              _row(Icons.phone_outlined, 'Phone', k.phone!),
            if (k.dutyShift?.isNotEmpty == true)
              _row(Icons.schedule_outlined, 'Shift', k.dutyShift!),
            SizedBox(height: 6.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                IconButton(
                  onPressed: () => _showAudit(k.id, k.name),
                  icon: const Icon(Icons.history),
                  tooltip: 'Audit',
                  iconSize: 20,
                  color: AppColors.info,
                ),
                IconButton(
                  onPressed: () => _showEditDialog(k),
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Edit',
                  iconSize: 20,
                  color: AppColors.primary,
                ),
                IconButton(
                  onPressed: () => _confirmDelete(k),
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Delete',
                  iconSize: 20,
                  color: AppColors.error,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 16, color: AppColors.textSecondary),
          SizedBox(width: 6.w),
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, bool selected, Color? color, VoidCallback onTap) {
    final c = color ?? AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: selected ? c.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: selected ? c : AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? c : AppColors.textSecondary,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
