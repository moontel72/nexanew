import 'dart:async';
import 'package:flutter/material.dart' hide SearchBar;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nexatrace_system/core/errors/error_handler.dart';
import 'package:nexatrace_system/shared/theme/colors.dart';
import 'package:nexatrace_system/shared/widgets/app_bars/custom_app_bar.dart';
import 'package:nexatrace_system/shared/widgets/buttons/primary_button.dart';
import 'package:nexatrace_system/shared/widgets/cards/plan_card.dart';
import 'package:nexatrace_system/shared/widgets/empty_states/empty_state_widget.dart';
import 'package:nexatrace_system/shared/widgets/loading/loading_indicator.dart';
import 'package:nexatrace_system/shared/widgets/search/search_bar.dart'
    as custom;
import 'package:nexatrace_system/shared/models/subscription/plan_model.dart';
import 'package:nexatrace_system/shared/models/subscription/plan_feature_model.dart';
import 'package:nexatrace_system/shared/models/subscription/plan_type.dart';
import 'package:nexatrace_system/features/nexa_admin/presentation/bloc/plans/plan_management_bloc.dart';
import 'package:nexatrace_system/shared/widgets/cards/kpi_card.dart';
import 'package:nexatrace_system/features/nexa_admin/presentation/widgets/plans/plan_filter_sheet.dart';
import 'package:nexatrace_system/routes/app_router.dart';
import 'package:nexatrace_system/shared/utils/extensions.dart';

/// Plans List Screen - Displays all subscription plans with filtering and actions
class PlansListScreen extends StatefulWidget {
  final bool inShell;

  const PlansListScreen({super.key, this.inShell = false});

  @override
  State<PlansListScreen> createState() => _PlansListScreenState();
}

class _PlansListScreenState extends State<PlansListScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounceTimer;
  String _currentSearch = '';
  String? _currentType;
  String? _currentStatus;
  String _currentSortBy = 'created_at';
  String _currentSortOrder = 'desc';

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchDebounceTimer?.cancel();
    super.dispose();
  }

  void _loadPlans() {
    context.read<PlanManagementBloc>().add(
          PlanManagementEvent.loadPlans(
            page: 1,
            search: _currentSearch,
            type: _currentType,
            status: _currentStatus,
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
        _loadPlans();
      }
    });
  }

  void _onFilterApplied({
    String? type,
    String? status,
    String? sortBy,
    String? sortOrder,
  }) {
    setState(() {
      _currentType = type;
      _currentStatus = status;
      _currentSortBy = sortBy ?? _currentSortBy;
      _currentSortOrder = sortOrder ?? _currentSortOrder;
    });
    _loadPlans();
  }

  void _onPlanTap(Plan plan) {
    // TODO: Navigate to plan detail screen
    /*
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlanDetailScreen(planId: plan.id),
      ),
    );
    */
  }

  void _onEditPlan(Plan plan) {
    _showEditPlanDialog(plan);
  }

  void _showEditPlanDialog(Plan plan) {
    final currentState = context.read<PlanManagementBloc>().state;
    final availableFeatures = currentState.maybeMap(
      loaded: (s) => s.availableFeatures,
      orElse: () => <String, List<PlanFeature>>{},
    );

    final selectedFeatureIds = plan.features.map((f) => f.id).toSet();

    final nameCtrl = TextEditingController(text: plan.name);
    final descriptionCtrl = TextEditingController(text: plan.description);

    String type = plan.type.name;
    String billingCycle = plan.billingCycle;
    String currency = plan.currency;
    String status = plan.status.name;

    final initialPrice =
        billingCycle.toLowerCase() == 'yearly' ? plan.yearlyPrice : plan.monthlyPrice;
    final priceCtrl =
        TextEditingController(text: initialPrice.toStringAsFixed(2));

    bool isFeatured = plan.isFeatured;
    bool isPopular = plan.isPopular;
    final sortOrderCtrl = TextEditingController(text: plan.sortOrder.toString());

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setLocalState) {
            return AlertDialog(
              title: const Text('Edit Plan'),
              content: SizedBox(
                width: 640,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Plan Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: descriptionCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                        minLines: 2,
                        maxLines: 4,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: type,
                              decoration: const InputDecoration(
                                labelText: 'Type',
                                border: OutlineInputBorder(),
                              ),
                              items: const [
                                DropdownMenuItem(value: 'free', child: Text('Free')),
                                DropdownMenuItem(value: 'basic', child: Text('Basic')),
                                DropdownMenuItem(value: 'standard', child: Text('Standard')),
                                DropdownMenuItem(value: 'premium', child: Text('Premium')),
                                DropdownMenuItem(value: 'custom', child: Text('Custom')),
                              ],
                              onChanged: (v) {
                                if (v == null) return;
                                setLocalState(() {
                                  type = v;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: status,
                              decoration: const InputDecoration(
                                labelText: 'Status',
                                border: OutlineInputBorder(),
                              ),
                              items: const [
                                DropdownMenuItem(
                                    value: 'active', child: Text('Active')),
                                DropdownMenuItem(
                                    value: 'inactive', child: Text('Inactive')),
                                DropdownMenuItem(
                                    value: 'archived', child: Text('Archived')),
                              ],
                              onChanged: (v) {
                                if (v == null) return;
                                setLocalState(() {
                                  status = v;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: priceCtrl,
                              keyboardType:
                                  const TextInputType.numberWithOptions(decimal: true),
                              decoration: InputDecoration(
                                labelText: 'Price ($currency)',
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: billingCycle,
                              decoration: const InputDecoration(
                                labelText: 'Billing Cycle',
                                border: OutlineInputBorder(),
                              ),
                              items: const [
                                DropdownMenuItem(
                                    value: 'monthly', child: Text('Monthly')),
                                DropdownMenuItem(
                                    value: 'quarterly', child: Text('Quarterly')),
                                DropdownMenuItem(
                                    value: 'yearly', child: Text('Yearly')),
                                DropdownMenuItem(
                                    value: 'one_time', child: Text('One Time')),
                              ],
                              onChanged: (v) {
                                if (v == null) return;
                                setLocalState(() {
                                  billingCycle = v;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: currency,
                              decoration: const InputDecoration(
                                labelText: 'Currency',
                                border: OutlineInputBorder(),
                              ),
                              items: const [
                                DropdownMenuItem(value: 'USD', child: Text('USD')),
                                DropdownMenuItem(value: 'EUR', child: Text('EUR')),
                                DropdownMenuItem(value: 'GBP', child: Text('GBP')),
                                DropdownMenuItem(value: 'INR', child: Text('INR')),
                                DropdownMenuItem(value: 'AED', child: Text('AED')),
                              ],
                              onChanged: (v) {
                                if (v == null) return;
                                setLocalState(() {
                                  currency = v;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: sortOrderCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Sort Order',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile(
                        value: isFeatured,
                        onChanged: (v) {
                          setLocalState(() {
                            isFeatured = v;
                          });
                        },
                        title: const Text('Featured'),
                        contentPadding: EdgeInsets.zero,
                      ),
                      SwitchListTile(
                        value: isPopular,
                        onChanged: (v) {
                          setLocalState(() {
                            isPopular = v;
                          });
                        },
                        title: const Text('Popular'),
                        contentPadding: EdgeInsets.zero,
                      ),
                      if (availableFeatures.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Features',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...availableFeatures.entries.map((entry) {
                          final title = entry.key.capitalizeFirst;
                          final features = entry.value;
                          return ExpansionTile(
                            tilePadding: EdgeInsets.zero,
                            title: Text(title),
                            children: features
                                .map(
                                  (feature) => CheckboxListTile(
                                    value:
                                        selectedFeatureIds.contains(feature.id),
                                    onChanged: (checked) {
                                      setLocalState(() {
                                        if (checked == true) {
                                          selectedFeatureIds.add(feature.id);
                                        } else {
                                          selectedFeatureIds.remove(feature.id);
                                        }
                                      });
                                    },
                                    dense: true,
                                    title: Text(feature.name),
                                    subtitle: feature.description.isNotEmpty
                                        ? Text(feature.description)
                                        : null,
                                    controlAffinity:
                                        ListTileControlAffinity.leading,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                )
                                .toList(),
                          );
                        }),
                      ],
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
                  onPressed: () {
                    final parsedPrice =
                        double.tryParse(priceCtrl.text.trim()) ?? 0.0;
                    final parsedSortOrder =
                        int.tryParse(sortOrderCtrl.text.trim());

                    Navigator.pop(context);
                    context.read<PlanManagementBloc>().add(
                          PlanManagementEvent.updatePlan(
                            id: plan.id,
                            name: nameCtrl.text.trim(),
                            type: type,
                            description: descriptionCtrl.text.trim(),
                            price: parsedPrice,
                            billingCycle: billingCycle,
                            currency: currency,
                            status: status,
                            isFeatured: isFeatured,
                            isPopular: isPopular,
                            sortOrder: parsedSortOrder,
                            features: selectedFeatureIds
                                .map((id) => PlanFeatureInput(id: id))
                                .toList(),
                          ),
                        );
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _onDeletePlan(Plan plan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Plan'),
        content: const Text(
          'Are you sure you want to delete this plan? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<PlanManagementBloc>().add(
                    PlanManagementEvent.deletePlan(plan.id),
                  );
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _onTogglePlanStatus(Plan plan) {
    final newStatus = plan.status == PlanStatus.active
        ? PlanStatus.inactive
        : PlanStatus.active;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          newStatus == PlanStatus.active ? 'Activate Plan' : 'Deactivate Plan',
        ),
        content: Text(
          newStatus == PlanStatus.active
              ? 'Are you sure you want to activate this plan?'
              : 'Are you sure you want to deactivate this plan?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<PlanManagementBloc>().add(
                    PlanManagementEvent.updatePlanStatus(
                      planId: plan.id,
                      status: newStatus,
                    ),
                  );
            },
            child: Text(
                newStatus == PlanStatus.active ? 'Activate' : 'Deactivate'),
          ),
        ],
      ),
    );
  }

  void _onCreatePlan() {
    context.read<AppRouter>().goToCreatePlan(context);
  }

  void _onExportPlans() {
    context.read<PlanManagementBloc>().add(
          PlanManagementEvent.exportPlans(
            search: _currentSearch,
            type: _currentType,
            status: _currentStatus,
          ),
        );
  }

  void _onRefresh() {
    _loadPlans();
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
                    'Subscription Plans',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.filter_list),
                        onPressed: _openFilterSheet,
                        tooltip: 'Filter',
                      ),
                      IconButton(
                        icon: const Icon(Icons.download),
                        onPressed: _onExportPlans,
                        tooltip: 'Export Plans',
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

                final search = custom.SearchBar(
                  onSearchChanged: _onSearchChanged,
                  hintText: 'Search plans...',
                );

                final create = PrimaryButton(
                  onPressed: _onCreatePlan,
                  text: 'Create Plan',
                  icon: Icons.add,
                );

                if (isNarrow) {
                  return Column(
                    children: [
                      search,
                      SizedBox(height: 12.h),
                      SizedBox(width: double.infinity, child: create),
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: search),
                    SizedBox(width: 12.w),
                    create,
                  ],
                );
              },
            ),
          ),
          BlocBuilder<PlanManagementBloc, PlanManagementState>(
            builder: (context, state) {
              return state.maybeMap(
                loaded: (loadedState) {
                  if (loadedState.statistics == null) {
                    return const SizedBox.shrink();
                  }
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    child: Row(
                      children: [
                        KPICard(
                          title: 'Total Plans',
                          value: loadedState.statistics!.totalPlans.toString(),
                          icon: Icons.list_alt,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 12.w),
                        KPICard(
                          title: 'Active Plans',
                          value: loadedState.statistics!.activePlans.toString(),
                          icon: Icons.check_circle,
                          color: AppColors.success,
                        ),
                      ],
                    ),
                  );
                },
                orElse: () => const SizedBox.shrink(),
              );
            },
          ),
          Expanded(
            child: BlocConsumer<PlanManagementBloc, PlanManagementState>(
              listener: (context, state) {
                state.maybeMap(
                  error: (s) {
                    ErrorHandler.showPersistentError(
                      context,
                      title: 'Plans Error',
                      message: s.message,
                      copyText: 'Plans Error\n\n${s.message}',
                    );
                  },
                  planUpdated: (s) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(s.message),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                  planDeleted: (s) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(s.message),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                  planStatusUpdated: (s) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(s.message),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                  exported: (s) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(s.message),
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
        title: 'Subscription Plans',
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _openFilterSheet,
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _onExportPlans,
            tooltip: 'Export Plans',
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
      builder: (context) => PlanFilterSheet(
        currentType: _currentType,
        currentStatus: _currentStatus,
        currentSortBy: _currentSortBy,
        currentSortOrder: _currentSortOrder,
        onApply: _onFilterApplied,
      ),
    );
  }

  Widget _buildContent(PlanManagementState state) {
    return state.maybeMap(
      loading: (loadingState) => const Center(child: LoadingIndicator()),
      error: (errorState) => EmptyState(
        icon: Icons.error_outline,
        title: 'Error Loading Plans',
        description: errorState.message,
        actionButton: PrimaryButton(
          text: 'Retry',
          onPressed: _loadPlans,
        ),
      ),
      loaded: (loadedState) {
        if (loadedState.plans.isEmpty) {
          return EmptyState(
            icon: Icons.list_alt,
            title: 'No Plans Found',
            description: _currentSearch.isNotEmpty
                ? 'No plans match your search criteria'
                : 'Create your first subscription plan to get started',
            actionButton: PrimaryButton(
              text: 'Create Plan',
              onPressed: _onCreatePlan,
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          itemCount: loadedState.plans.length +
              (loadedState.page < loadedState.totalPages ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == loadedState.plans.length) {
              return _buildLoadMoreIndicator(loadedState);
            }

            final plan = loadedState.plans[index];
            return PlanCard(
              plan: plan,
              onTap: () => _onPlanTap(plan),
              onEdit: () => _onEditPlan(plan),
              onDelete: () => _onDeletePlan(plan),
              onToggleStatus: () => _onTogglePlanStatus(plan),
            );
          },
        );
      },
      orElse: () => const Center(child: LoadingIndicator()),
    );
  }

  Widget _buildLoadMoreIndicator(dynamic state) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Center(
        child: ElevatedButton(
          onPressed: () {
            final bloc = context.read<PlanManagementBloc>();
            bloc.add(PlanManagementEvent.loadPlans(
              page: state.page + 1,
              search: _currentSearch,
              type: _currentType,
              status: _currentStatus,
              sortBy: _currentSortBy,
              sortOrder: _currentSortOrder,
            ));
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary.withAlpha(25),
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
