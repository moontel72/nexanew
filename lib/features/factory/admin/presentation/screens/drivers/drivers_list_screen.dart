import 'package:flutter/material.dart' hide SearchBar;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:trace_odd/features/factory/admin/presentation/bloc/drivers/drivers_bloc.dart';
import 'package:trace_odd/shared/theme/colors.dart';
import 'package:trace_odd/shared/widgets/app_bars/custom_app_bar.dart';
import 'package:trace_odd/shared/widgets/buttons/primary_button.dart';
import 'package:trace_odd/shared/widgets/empty_states/empty_state_widget.dart';
import 'package:trace_odd/shared/widgets/loading/loading_indicator.dart';

class DriversListScreen extends StatefulWidget {
  const DriversListScreen({super.key});
  @override
  State<DriversListScreen> createState() => _DriversListScreenState();
}

class _DriversListScreenState extends State<DriversListScreen> {
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
    context.read<DriversBloc>().add(
      LoadDrivers(
        search: _searchController.text.trim().isEmpty
            ? null
            : _searchController.text.trim(),
        statusFilter: _statusFilter,
      ),
    );
  }

  void _goToCreate() => context.go('/factory/drivers/create');

  Future<void> _confirmDelete(Driver driver) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Driver'),
        content: Text('Delete "${driver.name}"? This cannot be undone.'),
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
      context.read<DriversBloc>().add(DeleteDriver(id: driver.id));
    }
  }

  Future<void> _confirmToggleStatus(Driver driver) async {
    final current = driver.status.toLowerCase();
    final options = <String>[];
    if (current != 'active') options.add('active');
    if (current != 'inactive') options.add('inactive');
    if (current != 'suspended') options.add('suspended');

    final chosen = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text('Change status for ${driver.name}'),
        children: options.map((s) {
          final icon = s == 'active'
              ? Icons.check_circle_outline
              : s == 'suspended'
              ? Icons.block
              : Icons.pause_circle_outline;
          final color = s == 'active'
              ? AppColors.success
              : s == 'suspended'
              ? AppColors.warning
              : AppColors.error;
          return SimpleDialogOption(
            onPressed: () => Navigator.of(ctx).pop(s),
            child: Row(
              children: [
                Icon(icon, color: color, size: 20),
                SizedBox(width: 12.w),
                Text(s[0].toUpperCase() + s.substring(1)),
              ],
            ),
          );
        }).toList(),
      ),
    );
    if (chosen != null && mounted) {
      context.read<DriversBloc>().add(
        ToggleDriverStatus(id: driver.id, newStatus: chosen),
      );
    }
  }

  void _showEditDialog(Driver driver) {
    final nameC = TextEditingController(text: driver.name);
    final phoneC = TextEditingController(text: driver.phone ?? '');
    final emailC = TextEditingController(text: driver.email);
    final licenseC = TextEditingController(text: driver.licenseNumber ?? '');
    final plateC = TextEditingController(text: driver.vehiclePlateNumber ?? '');
    String? vehicleType = driver.vehicleType;
    String? st = driver.status;
    String? licenseExpiryStr = driver.licenseExpiry?.toIso8601String();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => BlocProvider.value(
        value: context.read<DriversBloc>(),
        child: BlocConsumer<DriversBloc, DriversState>(
          listenWhen: (prev, curr) =>
              curr.status == DriversStatus.updated ||
              curr.status == DriversStatus.error,
          listener: (context, state) {
            if (state.status == DriversStatus.updated) {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(
                this.context,
              ).showSnackBar(const SnackBar(content: Text('Updated')));
            }
            if (state.status == DriversStatus.error &&
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
            final busy = state.status == DriversStatus.updating;
            return AlertDialog(
              title: const Text('Edit Driver'),
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
                        controller: phoneC,
                        decoration: const InputDecoration(labelText: 'Phone'),
                        keyboardType: TextInputType.phone,
                      ),
                      SizedBox(height: 12.h),
                      TextFormField(
                        controller: licenseC,
                        decoration: const InputDecoration(
                          labelText: 'License Number',
                        ),
                      ),
                      SizedBox(height: 12.h),
                      TextFormField(
                        controller: plateC,
                        decoration: const InputDecoration(
                          labelText: 'Vehicle Plate Number',
                        ),
                      ),
                      SizedBox(height: 12.h),
                      DropdownButtonFormField<String>(
                        initialValue: vehicleType,
                        decoration: const InputDecoration(
                          labelText: 'Vehicle Type',
                        ),
                        items: const [
                          DropdownMenuItem(value: null, child: Text('None')),
                          DropdownMenuItem(
                            value: 'Motorcycle',
                            child: Text('Motorcycle'),
                          ),
                          DropdownMenuItem(value: 'Car', child: Text('Car')),
                          DropdownMenuItem(value: 'Van', child: Text('Van')),
                          DropdownMenuItem(
                            value: 'Truck',
                            child: Text('Truck'),
                          ),
                          DropdownMenuItem(
                            value: 'Other',
                            child: Text('Other'),
                          ),
                        ],
                        onChanged: (v) => vehicleType = v,
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
                          DropdownMenuItem(
                            value: 'suspended',
                            child: Text('Suspended'),
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
                  backgroundColor: AppColors.primary,
                  textColor: Colors.white,
                  onPressed: () {
                    if (!(formKey.currentState?.validate() ?? false)) return;
                    context.read<DriversBloc>().add(
                      UpdateDriver(
                        id: driver.id,
                        name: nameC.text.trim(),
                        email: emailC.text.trim(),
                        phone: phoneC.text.trim().isEmpty
                            ? null
                            : phoneC.text.trim(),
                        licenseNumber: licenseC.text.trim().isEmpty
                            ? null
                            : licenseC.text.trim(),
                        licenseExpiry: licenseExpiryStr,
                        vehiclePlateNumber: plateC.text.trim().isEmpty
                            ? null
                            : plateC.text.trim(),
                        vehicleType: vehicleType,
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

  void _showAudit(String driverId, String name) {
    context.read<DriversBloc>().add(LoadDriverAuditTrail(id: driverId));
    showDialog(
      context: context,
      builder: (ctx) => BlocProvider.value(
        value: context.read<DriversBloc>(),
        child: BlocBuilder<DriversBloc, DriversState>(
          builder: (context, state) => AlertDialog(
            title: Text('Audit - $name'),
            content: SizedBox(
              width: double.maxFinite,
              child: state.status == DriversStatus.auditLoading
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
        title: 'Drivers',
        showBackButton: false,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: PrimaryButton(
              onPressed: _goToCreate,
              text: 'Create',
              icon: Icons.add,
              backgroundColor: AppColors.primary,
              textColor: Colors.white,
              height: 38,
            ),
          ),
        ],
      ),
      body: BlocConsumer<DriversBloc, DriversState>(
        listenWhen: (prev, curr) =>
            curr.status == DriversStatus.deleted ||
            curr.status == DriversStatus.error,
        listener: (context, state) {
          if (state.status == DriversStatus.deleted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Deleted')));
          }
          if (state.status == DriversStatus.error &&
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
              state.status == DriversStatus.loading ||
              state.status == DriversStatus.deleting;
          return Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText:
                        'Search by name, email, phone, or plate number...',
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
                    SizedBox(width: 8.w),
                    _chip(
                      'Suspended',
                      _statusFilter == 'suspended',
                      AppColors.warning,
                      () {
                        setState(
                          () => _statusFilter = _statusFilter == 'suspended'
                              ? null
                              : 'suspended',
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
                    : state.drivers.isEmpty
                    ? SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.all(16.w),
                          child: EmptyState(
                            title: 'No drivers',
                            description: 'Add a driver to manage deliveries.',
                            icon: Icons.local_shipping_outlined,
                            iconColor: AppColors.primary,
                            actionButton: PrimaryButton(
                              text: 'Add Driver',
                              icon: Icons.add,
                              backgroundColor: AppColors.primary,
                              textColor: Colors.white,
                              onPressed: _goToCreate,
                            ),
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: EdgeInsets.all(16.w),
                        itemCount: state.drivers.length,
                        separatorBuilder: (_, _) => SizedBox(height: 12.h),
                        itemBuilder: (_, i) => _buildCard(state.drivers[i]),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCard(Driver d) {
    final statusLower = d.status.toLowerCase();
    final badgeColor = statusLower == 'active'
        ? AppColors.success
        : statusLower == 'suspended'
        ? AppColors.warning
        : AppColors.error;

    final tierColor = d.tier == 'gold'
        ? const Color(0xFFFFD700)
        : d.tier == 'silver'
        ? const Color(0xFFC0C0C0)
        : d.tier == 'bronze'
        ? const Color(0xFFCD7F32)
        : null;

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
                    d.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (d.tier != null && tierColor != null)
                  Container(
                    margin: EdgeInsets.only(right: 8.w),
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: tierColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: tierColor),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, size: 14, color: tierColor),
                        SizedBox(width: 4.w),
                        Text(
                          d.tier!.toUpperCase(),
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: tierColor,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
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
                    d.status.toUpperCase(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: badgeColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            _row(Icons.email_outlined, 'Email', d.email),
            if (d.phone?.isNotEmpty == true)
              _row(Icons.phone_outlined, 'Phone', d.phone!),
            if (d.vehiclePlateNumber?.isNotEmpty == true)
              _row(
                Icons.directions_car_outlined,
                'Plate',
                d.vehiclePlateNumber!,
              ),
            if (d.licenseNumber?.isNotEmpty == true)
              _row(Icons.badge_outlined, 'License', d.licenseNumber!),
            if (d.vehicleType?.isNotEmpty == true)
              _row(Icons.local_shipping_outlined, 'Vehicle', d.vehicleType!),
            if (d.rating != null)
              _row(
                Icons.star_half_outlined,
                'Rating',
                '${d.rating!.toStringAsFixed(1)} ⭐',
              ),
            _row(
              Icons.repeat_outlined,
              'Trips',
              '${d.completedTrips}/${d.totalTrips} completed',
            ),
            SizedBox(height: 6.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                IconButton(
                  onPressed: () => _showAudit(d.id, d.name),
                  icon: const Icon(Icons.history),
                  tooltip: 'Audit',
                  iconSize: 20,
                  color: AppColors.info,
                ),
                IconButton(
                  onPressed: () => _confirmToggleStatus(d),
                  icon: const Icon(Icons.swap_horiz),
                  tooltip: 'Change Status',
                  iconSize: 20,
                  color: AppColors.accent,
                ),
                IconButton(
                  onPressed: () => _showEditDialog(d),
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Edit',
                  iconSize: 20,
                  color: AppColors.primary,
                ),
                IconButton(
                  onPressed: () => _confirmDelete(d),
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
