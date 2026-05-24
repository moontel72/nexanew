// Company Detail Screen for NexaTrace System
// Displays detailed information about a company

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nexatrace_system/shared/theme/colors.dart';
import 'package:nexatrace_system/shared/utils/extensions.dart';
import 'package:nexatrace_system/features/nexa_admin/presentation/bloc/companies/company_detail_bloc.dart';
import 'package:nexatrace_system/features/nexa_admin/data/repositories/company_management_repository.dart';
import 'package:nexatrace_system/features/nexa_admin/domain/entities/subscription_plan.dart';
import 'package:nexatrace_system/core/services/api_service.dart';
import 'package:nexatrace_system/shared/widgets/app_bars/custom_app_bar.dart';
import 'package:nexatrace_system/shared/widgets/empty_states/empty_state_widget.dart';
import 'package:nexatrace_system/shared/widgets/loading/loading_indicator.dart';
import 'package:nexatrace_system/shared/widgets/buttons/primary_button.dart';

class CompanyDetailScreen extends StatefulWidget {
  final String companyId;
  final bool inShell;

  const CompanyDetailScreen({
    super.key,
    required this.companyId,
    this.inShell = false,
  });

  @override
  State<CompanyDetailScreen> createState() => _CompanyDetailScreenState();
}

class _CompanyDetailScreenState extends State<CompanyDetailScreen> {
  late CompanyDetailBloc _companyDetailBloc;
  Map<String, dynamic>? _companyCache;

  @override
  void initState() {
    super.initState();
    _companyDetailBloc = CompanyDetailBloc(
      companyRepository: CompanyManagementRepository(apiService: ApiService()),
    )..add(LoadCompanyDetail(companyId: widget.companyId));
  }

  @override
  void dispose() {
    _companyDetailBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _companyDetailBloc,
      child: BlocConsumer<CompanyDetailBloc, CompanyDetailState>(
        listener: (context, state) {
          if (state is CompanyDetailLoaded) {
            setState(() {
              _companyCache = state.company;
            });
          }

          if (state is CompanyDetailUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
              ),
            );
          }

          if (state is CompanyStatusUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
              ),
            );
          }

          if (state is CompanyVerificationUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
              ),
            );
          }

          if (state is CompanyDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
              ),
            );
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          final company = state is CompanyDetailLoaded
              ? state.company
              : _companyCache;
          final isLoading = state is CompanyDetailLoading;

          Widget page;
          if (state is CompanyDetailError && company == null) {
            page = EmptyState(
              icon: Icons.error_outline,
              title: 'Failed to Load',
              description: state.message,
              actionButton: PrimaryButton(
                text: 'Retry',
                onPressed: () {
                  _companyDetailBloc.add(
                    LoadCompanyDetail(companyId: widget.companyId),
                  );
                },
              ),
            );
          } else if (company == null) {
            page = const Center(child: LoadingIndicator());
          } else {
            final name = (company['name'] ?? '').toString();
            page = Column(
              children: [
                if (widget.inShell)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back),
                          tooltip: 'Back',
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            name.isNotEmpty ? name : 'Company Details',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w800),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          onPressed: () => _showEditCompanyDialog(company),
                          icon: const Icon(Icons.edit),
                          tooltip: 'Edit',
                        ),
                        IconButton(
                          onPressed: () => _showDeleteConfirmation(company),
                          icon: const Icon(Icons.delete_outline),
                          tooltip: 'Delete',
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: Stack(
                    children: [
                      _buildCompanyDetail(company),
                      if (isLoading)
                        Container(
                          color: Colors.black.withAlpha(20),
                          child: const Center(child: LoadingIndicator()),
                        ),
                    ],
                  ),
                ),
              ],
            );
          }

          if (widget.inShell) return page;

          return Scaffold(
            appBar: CustomAppBar(
              title: 'Company Details',
              showBackButton: true,
              actions: [
                if (company != null)
                  IconButton(
                    onPressed: () => _showEditCompanyDialog(company),
                    icon: const Icon(Icons.edit),
                    tooltip: 'Edit',
                  ),
                if (company != null)
                  IconButton(
                    onPressed: () => _showDeleteConfirmation(company),
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Delete',
                  ),
              ],
            ),
            body: page,
          );
        },
      ),
    );
  }

  Widget _buildCompanyDetail(Map<String, dynamic> company) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Company Header
          _buildCompanyHeader(company),
          const SizedBox(height: 24),

          // Company Information
          _buildCompanyInfo(company),
          const SizedBox(height: 24),

          // Contact Information
          _buildContactInfo(company),
          const SizedBox(height: 24),

          _buildVerificationInfo(company),
          const SizedBox(height: 24),

          // Statistics
          _buildStatistics(company),
          const SizedBox(height: 24),

          // Subscription Information
          _buildSubscriptionInfo(company),
          const SizedBox(height: 24),

          // Actions
          _buildActionButtons(company),
        ],
      ),
    );
  }

  Widget _buildCompanyHeader(Map<String, dynamic> company) {
    final name = (company['name'] ?? '').toString();
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Company Logo
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
                image: company['logo_url'] != null
                    ? DecorationImage(
                        image: NetworkImage(company['logo_url']),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: company['logo_url'] == null
                  ? Center(
                      child: Text(
                        name.isNotEmpty
                            ? name.substring(0, 1).toUpperCase()
                            : '?',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name.isNotEmpty ? name : 'Unknown Company',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildStatusChip(company['status'] ?? 'unknown'),
                      _buildVerificationChip(
                        company['verification_status'] ?? 'notSubmitted',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if ((company['notes'] ?? '').toString().isNotEmpty)
                    _buildNotesSection(company['notes'].toString()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Parse notes field — if it's valid JSON with bus fleet data, show structured
  /// info cards; otherwise display as plain text.
  Widget _buildNotesSection(String rawNotes) {
    // Try to parse as JSON
    Map<String, dynamic>? meta;
    try {
      final decoded = jsonDecode(rawNotes);
      if (decoded is Map<String, dynamic>) meta = decoded;
    } catch (_) {}

    // If not JSON or no recognized fields, show plain text
    if (meta == null || meta.isEmpty) {
      return Text(
        rawNotes,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
    }

    final isBusFleet = meta['company_type_tag'] == 'bus_fleet';
    if (!isBusFleet) {
      return Text(
        rawNotes,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
    }

    // Bus fleet metadata — show compact info chips
    final fleetSize = meta['fleet_size'] as int? ?? 0;
    final activeRoutes = meta['active_routes'] as int? ?? 0;
    final ownerName = meta['owner_name']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.directions_bus, size: 16, color: AppColors.info),
              const SizedBox(width: 6),
              Text(
                'Bus Fleet Details',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.info,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _metaChip(Icons.confirmation_number, '$fleetSize buses'),
              _metaChip(Icons.alt_route, '$activeRoutes routes'),
              if (ownerName.isNotEmpty) _metaChip(Icons.person, ownerName),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metaChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textTertiary),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color statusColor;
    IconData statusIcon;

    final normalized = status.toLowerCase() == 'suspended' ? 'blocked' : status;

    switch (normalized.toLowerCase()) {
      case 'active':
        statusColor = AppColors.success;
        statusIcon = Icons.check_circle;
        break;
      case 'inactive':
        statusColor = AppColors.error;
        statusIcon = Icons.cancel;
        break;
      case 'pending':
        statusColor = AppColors.warning;
        statusIcon = Icons.pending;
        break;
      case 'blocked':
        statusColor = AppColors.error;
        statusIcon = Icons.block;
        break;
      default:
        statusColor = AppColors.info;
        statusIcon = Icons.info;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withAlpha(26),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withAlpha(77)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, size: 16, color: statusColor),
          const SizedBox(width: 6),
          Text(
            normalized.toLowerCase() == 'blocked'
                ? 'Blocked'
                : normalized.capitalizeFirst,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: statusColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationChip(dynamic verificationStatus) {
    final value = (verificationStatus ?? '').toString();
    final normalized = value.isEmpty ? 'notSubmitted' : value;
    final isVerified = normalized.toLowerCase() == 'verified';

    final color = isVerified ? AppColors.success : AppColors.warning;
    final icon = isVerified ? Icons.verified : Icons.verified_outlined;
    final label = isVerified ? 'Verified' : 'Not Verified';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(77)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyInfo(Map<String, dynamic> company) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Company Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              icon: Icons.badge,
              label: 'Registration #',
              value:
                  (company['registration_number'] ?? '').toString().isNotEmpty
                  ? company['registration_number'].toString()
                  : 'Not specified',
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.category,
              label: 'Company Type',
              value: (company['type'] ?? '').toString().isNotEmpty
                  ? company['type'].toString().capitalizeFirst
                  : 'Not specified',
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.business,
              label: 'Industry',
              value: (company['industry'] ?? '').toString().isNotEmpty
                  ? company['industry'].toString().capitalizeFirst
                  : 'Not specified',
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.web,
              label: 'Website',
              value: (company['website'] ?? '').toString().isNotEmpty
                  ? company['website'].toString()
                  : 'Not specified',
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.location_on,
              label: 'Location',
              value:
                  '${(company['city'] ?? '').toString()}, ${(company['country'] ?? '').toString()}'
                          .trim() ==
                      ','
                  ? 'Not specified'
                  : '${(company['city'] ?? '').toString()}, ${(company['country'] ?? '').toString()}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfo(Map<String, dynamic> company) {
    final contact = (company['contact_person'] is Map)
        ? (company['contact_person'] as Map).cast<String, dynamic>()
        : <String, dynamic>{};

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contact Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              icon: Icons.email,
              label: 'Email',
              value: (company['email'] ?? '').toString().isNotEmpty
                  ? company['email'].toString()
                  : 'Not specified',
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.phone,
              label: 'Phone',
              value: (company['phone'] ?? '').toString().isNotEmpty
                  ? company['phone'].toString()
                  : 'Not specified',
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.location_city,
              label: 'Address',
              value: (company['address'] ?? '').toString().isNotEmpty
                  ? company['address'].toString()
                  : 'Not specified',
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.person,
              label: 'Contact Person',
              value:
                  (contact['name'] ?? contact['full_name'] ?? '')
                      .toString()
                      .isNotEmpty
                  ? (contact['name'] ?? contact['full_name']).toString()
                  : 'Not specified',
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.phone_android,
              label: 'Contact Phone',
              value: (contact['phone'] ?? '').toString().isNotEmpty
                  ? contact['phone'].toString()
                  : 'Not specified',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    bool isUrl = false,
    bool isEmail = false,
    bool isPhone = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.textTertiary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textTertiary),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color:
                      (isUrl || isEmail || isPhone) && value != 'Not specified'
                      ? AppColors.primary
                      : AppColors.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatistics(Map<String, dynamic> company) {
    final usage = (company['usage_stats'] is Map)
        ? (company['usage_stats'] as Map).cast<String, dynamic>()
        : <String, dynamic>{};
    final docs = (company['documents'] is List)
        ? (company['documents'] as List)
        : const [];
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statistics',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.5,
              children: [
                _buildStatItem(
                  label: 'Active Users',
                  value: usage['active_users_count']?.toString() ?? '0',
                  icon: Icons.people,
                  color: AppColors.primary,
                ),
                _buildStatItem(
                  label: 'Total Codes',
                  value: usage['total_codes_generated']?.toString() ?? '0',
                  icon: Icons.qr_code,
                  color: AppColors.secondary,
                ),
                _buildStatItem(
                  label: 'Documents',
                  value: docs.length.toString(),
                  icon: Icons.description,
                  color: AppColors.info,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(13),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(26)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withAlpha(26),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textTertiary,
                    fontSize: 10,
                  ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionInfo(Map<String, dynamic> company) {
    final plan = (company['subscription_plan'] is Map)
        ? (company['subscription_plan'] as Map).cast<String, dynamic>()
        : <String, dynamic>{};
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Subscription Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              icon: Icons.subscriptions,
              label: 'Plan',
              value: (plan['name'] ?? '').toString().isNotEmpty
                  ? plan['name'].toString()
                  : 'No active subscription',
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.calendar_today,
              label: 'Start Date',
              value:
                  (company['subscription_start_date'] ?? '')
                      .toString()
                      .isNotEmpty
                  ? company['subscription_start_date']
                        .toString()
                        .split('T')
                        .first
                  : 'Not specified',
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.calendar_today,
              label: 'End Date',
              value:
                  (company['subscription_end_date'] ?? '').toString().isNotEmpty
                  ? company['subscription_end_date'].toString().split('T').first
                  : 'Not specified',
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.payment,
              label: 'Billing Cycle',
              value: (company['billing_cycle'] ?? '').toString().isNotEmpty
                  ? company['billing_cycle'].toString().capitalizeFirst
                  : 'Not specified',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationInfo(Map<String, dynamic> company) {
    final verificationStatus =
        (company['verification_status'] ?? 'notSubmitted').toString();
    final notes = (company['verification_notes'] ?? '').toString();
    final isVerified = verificationStatus.toLowerCase() == 'verified';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Verification',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Switch(
                  value: isVerified,
                  onChanged: (value) {
                    _onToggleVerified(company, value);
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              icon: Icons.verified,
              label: 'Status',
              value: isVerified
                  ? 'Verified'
                  : verificationStatus.capitalizeFirst,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.description_outlined,
              label: 'Notes',
              value: notes.isNotEmpty ? notes : 'Not specified',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(Map<String, dynamic> company) {
    return Column(
      children: [
        // Status Management Buttons
        _buildStatusManagementButtons(company),
        const SizedBox(height: 16),

        // Main Action Buttons
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  _showEditCompanyDialog(company);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.edit, size: 20),
                    SizedBox(width: 8),
                    Text('Edit Company'),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  _showActionMenu(company);
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.more_vert, size: 20),
                    SizedBox(width: 8),
                    Text('More Actions'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusManagementButtons(Map<String, dynamic> company) {
    final currentStatus =
        company['status']?.toString().toLowerCase() ?? 'pending';
    final normalized = currentStatus == 'suspended' ? 'blocked' : currentStatus;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Status Management',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildStatusButton(
                  company: company,
                  status: 'active',
                  label: 'Active',
                  icon: Icons.check_circle,
                  color: AppColors.success,
                  isCurrent: normalized == 'active',
                ),
                _buildStatusButton(
                  company: company,
                  status: 'pending',
                  label: 'Pending',
                  icon: Icons.pending,
                  color: AppColors.warning,
                  isCurrent: normalized == 'pending',
                ),
                _buildStatusButton(
                  company: company,
                  status: 'suspended',
                  label: 'Blocked',
                  icon: Icons.block,
                  color: AppColors.error,
                  isCurrent: normalized == 'blocked',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusButton({
    required Map<String, dynamic> company,
    required String status,
    required String label,
    required IconData icon,
    required Color color,
    required bool isCurrent,
  }) {
    return ElevatedButton(
      onPressed: isCurrent
          ? null
          : () {
              _updateCompanyStatus(company, status);
            },
      style: ElevatedButton.styleFrom(
        backgroundColor: isCurrent ? color : color.withAlpha(26),
        foregroundColor: isCurrent ? Colors.white : color,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: isCurrent ? color : color.withAlpha(77),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(icon, size: 18), const SizedBox(width: 6), Text(label)],
      ),
    );
  }

  void _showActionMenu(Map<String, dynamic> company) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Company'),
                onTap: () {
                  Navigator.pop(context);
                  _showEditCompanyDialog(company);
                },
              ),
              ListTile(
                leading: const Icon(Icons.refresh),
                title: const Text('Refresh Data'),
                onTap: () {
                  Navigator.pop(context);
                  _companyDetailBloc.add(
                    LoadCompanyDetail(companyId: widget.companyId),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.verified, color: AppColors.info),
                title: const Text('Mark as Verified'),
                onTap: () {
                  Navigator.pop(context);
                  _onToggleVerified(company, true);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.block,
                  color: company['status'] == 'active'
                      ? AppColors.error
                      : AppColors.textTertiary,
                ),
                title: Text(
                  company['status'] == 'active'
                      ? 'Suspend Company'
                      : 'Activate Company',
                  style: TextStyle(
                    color: company['status'] == 'active'
                        ? AppColors.error
                        : AppColors.textPrimary,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _toggleCompanyStatus(company);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: AppColors.error),
                title: const Text(
                  'Delete Company',
                  style: TextStyle(color: AppColors.error),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmation(company);
                },
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _updateCompanyStatus(Map<String, dynamic> company, String newStatus) {
    final label = newStatus.toLowerCase() == 'suspended'
        ? 'Blocked'
        : newStatus.capitalizeFirst;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Status to $label'),
        content: Text(
          'Are you sure you want to change the company status to "$label"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _companyDetailBloc.add(
                UpdateCompanyStatus(
                  companyId: widget.companyId,
                  status: newStatus,
                  reason: 'Status changed via admin panel',
                ),
              );
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _toggleCompanyStatus(Map<String, dynamic> company) {
    final currentStatus =
        company['status']?.toString().toLowerCase() ?? 'pending';
    final newStatus = currentStatus == 'active' ? 'suspended' : 'active';

    _updateCompanyStatus(company, newStatus);
  }

  void _showDeleteConfirmation(Map<String, dynamic> company) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Company'),
        content: const Text(
          'Are you sure you want to delete this company? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _companyDetailBloc.add(
                DeleteCompany(companyId: widget.companyId),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _onToggleVerified(
    Map<String, dynamic> company,
    bool value,
  ) async {
    if (!value) {
      final ok = await _confirm(
        title: 'Unverify Company?',
        message:
            'This will set the verification status back to Submitted. Continue?',
        confirmText: 'Unverify',
        destructive: true,
      );
      if (ok != true) return;

      _companyDetailBloc.add(
        UpdateCompanyVerificationStatus(
          companyId: widget.companyId,
          verificationStatus: 'submitted',
        ),
      );
      return;
    }

    final notes = await _promptText(
      title: 'Mark as Verified',
      message: 'Add verification notes (CBR/legal office reference).',
      hintText: 'e.g., CBR report #12345',
      initialValue: (company['verification_notes'] ?? '').toString(),
      confirmText: 'Verify',
    );

    if (notes == null) return;

    _companyDetailBloc.add(
      UpdateCompanyVerificationStatus(
        companyId: widget.companyId,
        verificationStatus: 'verified',
        verificationNotes: notes.trim().isEmpty ? null : notes.trim(),
      ),
    );
  }

  Future<bool?> _confirm({
    required String title,
    required String message,
    required String confirmText,
    bool destructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: destructive
                ? TextButton.styleFrom(foregroundColor: AppColors.error)
                : null,
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  Future<String?> _promptText({
    required String title,
    required String message,
    required String hintText,
    required String initialValue,
    required String confirmText,
  }) {
    final controller = TextEditingController(text: initialValue);
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hintText,
                border: const OutlineInputBorder(),
              ),
              minLines: 2,
              maxLines: 4,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  void _showEditCompanyDialog(Map<String, dynamic> company) {
    final contact = (company['contact_person'] is Map)
        ? (company['contact_person'] as Map).cast<String, dynamic>()
        : <String, dynamic>{};

    final subscriptionPlan = (company['subscription_plan'] is Map)
        ? (company['subscription_plan'] as Map).cast<String, dynamic>()
        : <String, dynamic>{};
    final currentPlanId = (subscriptionPlan['id'] ?? company['plan_id'] ?? '')
        .toString()
        .trim();

    final nameCtrl = TextEditingController(
      text: (company['name'] ?? '').toString(),
    );
    final regCtrl = TextEditingController(
      text: (company['registration_number'] ?? '').toString(),
    );
    final taxCtrl = TextEditingController(
      text: (company['tax_id'] ?? '').toString(),
    );
    final typeCtrl = TextEditingController(
      text: (company['type'] ?? '').toString(),
    );
    final industryCtrl = TextEditingController(
      text: (company['industry'] ?? '').toString(),
    );
    final emailCtrl = TextEditingController(
      text: (company['email'] ?? '').toString(),
    );
    final phoneCtrl = TextEditingController(
      text: (company['phone'] ?? '').toString(),
    );
    final websiteCtrl = TextEditingController(
      text: (company['website'] ?? '').toString(),
    );
    final countryCtrl = TextEditingController(
      text: (company['country'] ?? '').toString(),
    );
    final cityCtrl = TextEditingController(
      text: (company['city'] ?? '').toString(),
    );
    final addressCtrl = TextEditingController(
      text: (company['address'] ?? '').toString(),
    );
    final postalCtrl = TextEditingController(
      text: (company['postal_code'] ?? '').toString(),
    );
    final notesCtrl = TextEditingController(
      text: (company['notes'] ?? '').toString(),
    );

    final cpNameCtrl = TextEditingController(
      text: (contact['name'] ?? contact['full_name'] ?? '').toString(),
    );
    final cpEmailCtrl = TextEditingController(
      text: (contact['email'] ?? '').toString(),
    );
    final cpPhoneCtrl = TextEditingController(
      text: (contact['phone'] ?? '').toString(),
    );
    final cpPosCtrl = TextEditingController(
      text: (contact['position'] ?? '').toString(),
    );

    showDialog(
      context: context,
      builder: (context) {
        final repo = CompanyManagementRepository(apiService: ApiService());
        var plansFuture = repo.getAvailablePlans();
        String selectedPlanId = currentPlanId.isEmpty ? '' : currentPlanId;

        return StatefulBuilder(
          builder: (context, setModalState) => AlertDialog(
            title: const Text('Edit Company'),
            content: SizedBox(
              width: 560,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Company Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: regCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Registration Number',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: taxCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Tax ID',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: typeCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Company Type',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: industryCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Industry',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: countryCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Country',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: cityCtrl,
                            decoration: const InputDecoration(
                              labelText: 'City',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: addressCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Address',
                        border: OutlineInputBorder(),
                      ),
                      minLines: 2,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: postalCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Postal Code',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: emailCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: phoneCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Phone',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: websiteCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Website',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    FutureBuilder<List<SubscriptionPlan>>(
                      future: plansFuture,
                      builder: (context, snapshot) {
                        final plans =
                            (snapshot.data ?? const <SubscriptionPlan>[])
                                .where((p) => p.id.trim().isNotEmpty)
                                .toList();
                        final effectiveSelectedId =
                            plans.any((p) => p.id == selectedPlanId)
                            ? selectedPlanId
                            : (plans.isEmpty ? '' : plans.first.id);

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const SizedBox(
                            height: 52,
                            child: Center(child: LoadingIndicator()),
                          );
                        }

                        if (snapshot.hasError) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      enabled: false,
                                      decoration: const InputDecoration(
                                        labelText: 'Update Subscription Plan',
                                        hintText: 'Failed to load plans',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  OutlinedButton.icon(
                                    onPressed: () {
                                      setModalState(() {
                                        plansFuture = repo.getAvailablePlans();
                                      });
                                    },
                                    icon: const Icon(Icons.refresh),
                                    label: const Text('Retry'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                snapshot.error.toString(),
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: AppColors.error),
                              ),
                            ],
                          );
                        }

                        if (plans.isEmpty) {
                          return Row(
                            children: [
                              const Expanded(
                                child: TextField(
                                  enabled: false,
                                  decoration: InputDecoration(
                                    labelText: 'Update Subscription Plan',
                                    hintText: 'No active plans found',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              OutlinedButton.icon(
                                onPressed: () {
                                  setModalState(() {
                                    plansFuture = repo.getAvailablePlans();
                                  });
                                },
                                icon: const Icon(Icons.refresh),
                                label: const Text('Retry'),
                              ),
                            ],
                          );
                        }

                        if (selectedPlanId.trim().isEmpty &&
                            effectiveSelectedId.trim().isNotEmpty &&
                            selectedPlanId != effectiveSelectedId) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (!mounted) return;
                            setModalState(() {
                              selectedPlanId = effectiveSelectedId;
                            });
                          });
                        }

                        return DropdownButtonFormField<String>(
                          isExpanded: true,
                          key: ValueKey('plan_$effectiveSelectedId'),
                          initialValue: effectiveSelectedId.isEmpty
                              ? null
                              : effectiveSelectedId,
                          items: plans
                              .map(
                                (p) => DropdownMenuItem<String>(
                                  value: p.id,
                                  child: Text(
                                    p.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: false,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (v) {
                            setModalState(() {
                              selectedPlanId = (v ?? '').toString();
                            });
                          },
                          decoration: const InputDecoration(
                            labelText: 'Update Subscription Plan',
                            border: OutlineInputBorder(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Contact Person',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: cpNameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: cpEmailCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: cpPhoneCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Phone',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: cpPosCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Position',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: notesCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Admin Notes',
                        border: OutlineInputBorder(),
                      ),
                      minLines: 2,
                      maxLines: 4,
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  final newPlanId = selectedPlanId.trim();
                  final planChanged =
                      newPlanId.isNotEmpty && newPlanId != currentPlanId;

                  if (planChanged) {
                    final confirmed = await _confirm(
                      title: 'Change Subscription Plan?',
                      message:
                          "Are you sure you want to change this company's plan? This may affect billing.",
                      confirmText: 'Change Plan',
                    );
                    if (confirmed != true) return;
                  }

                  Navigator.pop(context);

                  final updateData = <String, dynamic>{
                    'name': nameCtrl.text.trim(),
                    'business_registration_number': regCtrl.text.trim(),
                    'tax_id': taxCtrl.text.trim().isEmpty
                        ? null
                        : taxCtrl.text.trim(),
                    'company_type': typeCtrl.text.trim(),
                    'industry_type': industryCtrl.text.trim(),
                    'email': emailCtrl.text.trim(),
                    'phone': phoneCtrl.text.trim().isEmpty
                        ? null
                        : phoneCtrl.text.trim(),
                    'website': websiteCtrl.text.trim().isEmpty
                        ? null
                        : websiteCtrl.text.trim(),
                    'country': countryCtrl.text.trim(),
                    'city': cityCtrl.text.trim(),
                    'address': addressCtrl.text.trim().isEmpty
                        ? null
                        : addressCtrl.text.trim(),
                    'postal_code': postalCtrl.text.trim().isEmpty
                        ? null
                        : postalCtrl.text.trim(),
                    'contact_person_name': cpNameCtrl.text.trim(),
                    'contact_person_email': cpEmailCtrl.text.trim(),
                    'contact_person_phone': cpPhoneCtrl.text.trim(),
                    'contact_person_position': cpPosCtrl.text.trim().isEmpty
                        ? null
                        : cpPosCtrl.text.trim(),
                    'admin_notes': notesCtrl.text.trim().isEmpty
                        ? null
                        : notesCtrl.text.trim(),
                  };

                  updateData.removeWhere((key, value) => value == null);

                  _companyDetailBloc.add(
                    UpdateCompanyDetail(
                      companyId: widget.companyId,
                      companyData: updateData,
                    ),
                  );

                  if (planChanged) {
                    try {
                      final plans = await plansFuture;
                      final plan = plans.firstWhere(
                        (p) => p.id == newPlanId,
                        orElse: () => plans.first,
                      );
                      await repo.assignPlan(
                        companyId: widget.companyId,
                        planId: newPlanId,
                        billingCycle: plan.billingCycle,
                      );
                      _companyDetailBloc.add(
                        LoadCompanyDetail(companyId: widget.companyId),
                      );
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Subscription plan updated'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Failed to update plan: ${e.toString()}',
                            ),
                            backgroundColor: AppColors.error,
                          ),
                        );
                      }
                    }
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
        );
      },
    );
  }
}
