//lib/features/nexa_admin/presentation/screens/super_admin/companies/companies_list_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:trace_odd/shared/theme/colors.dart';
import 'package:trace_odd/shared/widgets/app_bars/custom_app_bar.dart';
import 'package:trace_odd/shared/widgets/buttons/primary_button.dart';
import 'package:trace_odd/shared/widgets/cards/company_card.dart';
import 'package:trace_odd/shared/widgets/empty_states/empty_state_widget.dart';
import 'package:trace_odd/shared/widgets/error_state/error_state_widget.dart';
import 'package:trace_odd/shared/widgets/loading/loading_state_widget.dart';
import 'package:trace_odd/shared/widgets/search/search_bar.dart'
    as custom_search;
import 'package:trace_odd/shared/models/company/company_model.dart';
import 'package:trace_odd/features/nexa_admin/presentation/bloc/companies/company_management_bloc.dart';
import 'package:trace_odd/features/nexa_admin/presentation/widgets/companies/company_filter_sheet.dart';
import 'package:trace_odd/routes/app_router.dart';

/// Companies List Screen - Displays all companies with filtering and actions
class CompaniesListScreen extends StatefulWidget {
  final bool inShell;

  const CompaniesListScreen({super.key, this.inShell = false});

  @override
  State<CompaniesListScreen> createState() => _CompaniesListScreenState();
}

class _CompaniesListScreenState extends State<CompaniesListScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounceTimer;
  String _currentSearch = '';
  String? _currentStatus;
  String? _currentVerificationStatus;
  String? _currentCountry;
  String? _currentPlanType;
  String _currentSortBy = 'created_at';
  String _currentSortOrder = 'desc';

  @override
  void initState() {
    super.initState();
    _loadCompanies();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchDebounceTimer?.cancel();
    super.dispose();
  }

  void _loadCompanies() {
    context.read<CompanyManagementBloc>().add(
      CompanyManagementEvent.loadCompanies(
        search: _currentSearch,
        status: _currentStatus,
        verificationStatus: _currentVerificationStatus,
        country: _currentCountry,
        planType: _currentPlanType,
        companyType: 'manufacturing',
        sortBy: _currentSortBy,
        sortOrder: _currentSortOrder,
      ),
    );
  }

  void _onSearchChanged(String value) {
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (_currentSearch != value) {
        _currentSearch = value;
        _loadCompanies();
      }
    });
  }

  void _onFilterApplied(Map<String, dynamic> filters) {
    _currentStatus = (filters['status'] as String?)?.trim().isEmpty == true
        ? null
        : filters['status'] as String?;
    _currentVerificationStatus =
        (filters['verification_status'] as String?)?.trim().isEmpty == true
        ? null
        : filters['verification_status'] as String?;
    _currentCountry = (filters['country'] as String?)?.trim().isEmpty == true
        ? null
        : filters['country'] as String?;
    _currentPlanType = (filters['plan_type'] as String?)?.trim().isEmpty == true
        ? null
        : filters['plan_type'] as String?;

    final sort = filters['sort']?.toString();
    if (sort != null && sort.isNotEmpty) {
      if (sort.endsWith('_asc')) {
        _currentSortOrder = 'asc';
        _currentSortBy = sort.replaceAll('_asc', '');
      } else if (sort.endsWith('_desc')) {
        _currentSortOrder = 'desc';
        _currentSortBy = sort.replaceAll('_desc', '');
      }
    }

    _loadCompanies();
  }

  void _onClearFilters() {
    _currentStatus = null;
    _currentVerificationStatus = null;
    _currentCountry = null;
    _currentPlanType = null;
    _currentSortBy = 'created_at';
    _currentSortOrder = 'desc';
    _loadCompanies();
  }

  void _onCompanyTap(Company company) {
    context.read<AppRouter>().goToCompanyDetail(context, company.id);
  }

  void _onRegisterCompany() {
    context.read<AppRouter>().goToRegisterCompany(context);
  }

  void _onExportCompanies() {
    context.read<CompanyManagementBloc>().add(
      CompanyManagementEvent.exportCompanies(
        search: _currentSearch,
        status: _currentStatus,
        verificationStatus: _currentVerificationStatus,
        country: _currentCountry,
        planType: _currentPlanType,
      ),
    );
  }

  void _onRefresh() {
    _loadCompanies();
  }

  @override
  Widget build(BuildContext context) {
    final content = Container(
      color: widget.inShell ? AppColors.surface : AppColors.background,
      child: Column(
        children: [
          if (widget.inShell)
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 4.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Companies',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.filter_list),
                        tooltip: 'Filter',
                        onPressed: _openFilterSheet,
                      ),
                      IconButton(
                        icon: const Icon(Icons.download),
                        onPressed: _onExportCompanies,
                        tooltip: 'Export Companies',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 520;

                final search = custom_search.SearchBar(
                  controller: _searchController,
                  hintText: 'Search companies...',
                  onSearchChanged: _onSearchChanged,
                );

                final register = PrimaryButton(
                  onPressed: _onRegisterCompany,
                  text: 'Register',
                  icon: Icons.add_business,
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                );

                if (isNarrow) {
                  return Column(
                    children: [
                      search,
                      Gap(12.h),
                      SizedBox(width: double.infinity, child: register),
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: search),
                    Gap(12.w),
                    register,
                  ],
                );
              },
            ),
          ),
          BlocBuilder<CompanyManagementBloc, CompanyManagementState>(
            builder: (context, state) {
              return state.maybeWhen(
                loaded:
                    (
                      companies,
                      total,
                      page,
                      perPage,
                      totalPages,
                      search,
                      status,
                      verificationStatus,
                      country,
                      planType,
                      sortBy,
                      sortOrder,
                      statistics,
                      filterOptions,
                    ) {
                      if (statistics != null) {
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 8.h,
                          ),
                          child: Row(
                            children: [
                              DashboardStatisticsCard(
                                title: 'Total Companies',
                                value: int.parse(
                                  statistics.totalCompanies.toString(),
                                ),
                                icon: Icons.business,
                                color: AppColors.primary,
                              ),
                              Gap(12.w),
                              DashboardStatisticsCard(
                                title: 'Active',
                                value: int.parse(
                                  statistics.activeCompanies.toString(),
                                ),
                                icon: Icons.check_circle,
                                color: AppColors.success,
                              ),
                              Gap(12.w),
                              DashboardStatisticsCard(
                                title: 'Pending',
                                value: int.parse(
                                  statistics.pendingCompanies.toString(),
                                ),
                                icon: Icons.pending,
                                color: AppColors.warning,
                              ),
                              Gap(12.w),
                              DashboardStatisticsCard(
                                title: 'Verified',
                                value: int.parse(
                                  statistics.verifiedCompanies.toString(),
                                ),
                                icon: Icons.verified,
                                color: AppColors.info,
                              ),
                            ],
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                orElse: () => const SizedBox.shrink(),
              );
            },
          ),
          Expanded(
            child: BlocConsumer<CompanyManagementBloc, CompanyManagementState>(
              listener: (context, state) {
                state.maybeWhen(
                  error: (message, _, _, _, _) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(message),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  },
                  exported: (filePath, message) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(message),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                  companyCreated: (company, message) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(message),
                        backgroundColor: AppColors.success,
                      ),
                    );
                    context.read<AppRouter>().goToCompanyDetail(
                      context,
                      company.id,
                    );
                  },
                  companyUpdated: (company, message) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(message),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                  companyDeleted: (companyId, message) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(message),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                  companyStatusUpdated: (companyId, status, message) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(message),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                  verificationStatusUpdated:
                      (companyId, verificationStatus, message) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(message),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      },
                  welcomeEmailSent: (companyId, message) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(message),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                  passwordReset: (companyId, message) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(message),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                  orElse: () {},
                );
              },
              builder: (context, state) {
                return RefreshIndicator(
                  onRefresh: () async => _onRefresh(),
                  child: _buildContent(state),
                );
              },
            ),
          ),
        ],
      ),
    );

    if (widget.inShell) return content;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Companies',
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _openFilterSheet,
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _onExportCompanies,
            tooltip: 'Export Companies',
          ),
        ],
      ),
      body: content,
    );
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CompanyFilterSheet(
        currentFilters: {
          'search': _currentSearch,
          'status': _currentStatus,
          'verification_status': _currentVerificationStatus,
          'country': _currentCountry,
          'plan_type': _currentPlanType,
          'sort': '${_currentSortBy}_$_currentSortOrder',
        },
        onApplyFilters: (filters) {
          Navigator.of(context).pop();
          _onFilterApplied(filters);
        },
        onClearFilters: () {
          Navigator.of(context).pop();
          _onClearFilters();
        },
      ),
    );
  }

  Widget _buildContent(CompanyManagementState state) {
    return state.maybeWhen(
      loading: () => const LoadingState(message: 'Loading companies...'),
      exporting: () => const LoadingState(message: 'Exporting companies...'),
      error: (message, _, _, _, _) =>
          ErrorState(title: 'Error', message: message, onRetry: _loadCompanies),
      loaded:
          (
            companies,
            total,
            page,
            perPage,
            totalPages,
            search,
            status,
            verificationStatus,
            country,
            planType,
            sortBy,
            sortOrder,
            statistics,
            filterOptions,
          ) {
            if (companies.isEmpty) {
              return EmptyState(
                icon: Icons.business,
                title: 'No Companies Found',
                description: _currentSearch.isNotEmpty
                    ? 'No companies match your search criteria'
                    : 'Register your first company to get started',
                actionButton: PrimaryButton(
                  text: 'Register Company',
                  onPressed: _onRegisterCompany,
                  width: 220,
                ),
              );
            }

            final hasMorePages = page < totalPages;

            return ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              itemCount: companies.length + (hasMorePages ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == companies.length) {
                  return _buildLoadMoreIndicator(page);
                }

                final company = companies[index];
                return CompanyCard(
                  id: company.id,
                  name: company.name,
                  description: company.notes,
                  status: company.status.name,
                  verificationStatus: company.verificationStatus.name,
                  industry: company.industry.name,
                  employeeCount: company.employeeCount,
                  location: '${company.city}, ${company.country}',
                  createdAt: company.registeredAt,
                  updatedAt: company.updatedAt,
                  onTap: () => _onCompanyTap(company),
                  showActions: false,
                );
              },
            );
          },
      orElse: () => const LoadingState(message: 'Loading...'),
    );
  }

  Widget _buildLoadMoreIndicator(int currentPage) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Center(
        child: ElevatedButton(
          onPressed: () {
            context.read<CompanyManagementBloc>().add(
              CompanyManagementEvent.loadCompanies(
                search: _currentSearch,
                status: _currentStatus,
                verificationStatus: _currentVerificationStatus,
                country: _currentCountry,
                planType: _currentPlanType,
                companyType: 'manufacturing',
                sortBy: _currentSortBy,
                sortOrder: _currentSortOrder,
                page: currentPage + 1,
                perPage: 20,
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary.withOpacity(0.1),
            foregroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
          ),
          child: const Text('Load More'),
        ),
      ),
    );
  }
}
