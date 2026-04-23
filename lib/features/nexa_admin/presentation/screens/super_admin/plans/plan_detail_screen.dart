import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nexatrace_system/features/nexa_admin/presentation/bloc/plans/plan_management_bloc.dart';
import 'package:nexatrace_system/shared/models/subscription/plan_feature_model.dart';
import 'package:nexatrace_system/shared/models/subscription/plan_model.dart';
import 'package:nexatrace_system/shared/theme/colors.dart';

class PlanDetailScreen extends StatefulWidget {
  final String planId;

  const PlanDetailScreen({super.key, required this.planId});

  @override
  State<PlanDetailScreen> createState() => _PlanDetailScreenState();
}

class _PlanDetailScreenState extends State<PlanDetailScreen> {
  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    context.read<PlanManagementBloc>().add(
          PlanManagementEvent.loadPlan(widget.planId),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PlanManagementBloc, PlanManagementState>(
      listener: (context, state) {
        state.maybeMap(
          planUpdated: (s) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(s.message),
                backgroundColor: AppColors.success,
              ),
            );
            context.read<PlanManagementBloc>().add(
                  PlanManagementEvent.loadPlan(widget.planId),
                );
          },
          error: (s) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(s.message),
                backgroundColor: AppColors.error,
              ),
            );
          },
          orElse: () {},
        );
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Plan Details'),
            actions: [
              state.maybeMap(
                planDetailLoaded: (s) => TextButton(
                  onPressed: () => _showEditPlanDialog(s.plan),
                  child: const Text('Edit'),
                ),
                orElse: () => const SizedBox.shrink(),
              ),
            ],
          ),
          body: state.maybeMap(
            loading: (_) => const Center(child: CircularProgressIndicator()),
            planDetailLoaded: (s) => _buildDetail(context, s.plan),
            planUpdated: (s) => _buildDetail(context, s.plan),
            error: (s) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(s.message),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: _load,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        );
      },
    );
  }

  Widget _buildDetail(BuildContext context, Plan plan) {
    final limits = plan.limits;
    final metadata = plan.metadata ?? const <String, dynamic>{};
    final publishRatesRaw = metadata['publish_rates'];
    final publishRates = publishRatesRaw is Map
        ? Map<String, dynamic>.from(publishRatesRaw.cast<String, dynamic>())
        : const <String, dynamic>{};
    final freeQuotaRaw = metadata['free_quota'];
    final freeQuota = freeQuotaRaw is Map
        ? Map<String, dynamic>.from(freeQuotaRaw.cast<String, dynamic>())
        : const <String, dynamic>{};

    final otherMeta = <String, dynamic>{...metadata};
    otherMeta.remove('publish_rates');
    otherMeta.remove('free_quota');
    otherMeta.remove('is_featured');
    otherMeta.remove('is_popular');
    otherMeta.remove('sort_order');
    otherMeta.remove('billing_cycle');
    otherMeta.remove('transport_connections_per_month');
    otherMeta.remove('max_loads_per_month');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(context, plan.name),
          const SizedBox(height: 8),
          _infoTable(context, <List<String>>[
            ['Plan ID', _v(plan.id)],
            ['Type', _v(plan.type.name)],
            ['Status', _v(plan.status.name)],
            ['Billing Cycle', _v(plan.billingCycle)],
            ['Currency', _v(plan.currency)],
            ['Monthly Price', plan.monthlyPrice.toStringAsFixed(2)],
            ['Yearly Price', plan.yearlyPrice.toStringAsFixed(2)],
            ['Featured', plan.isFeatured ? 'Yes' : 'No'],
            ['Popular', plan.isPopular ? 'Yes' : 'No'],
            ['Sort Order', _v(plan.sortOrder)],
          ]),
          const SizedBox(height: 20),
          _sectionTitle(context, 'Limits'),
          const SizedBox(height: 8),
          _infoTable(context, <List<String>>[
            ['Monthly Unit Codes', _v(limits['monthly_unit_codes'])],
            ['Monthly Packet Codes', _v(limits['monthly_packet_codes'])],
            ['Monthly Carton Codes', _v(limits['monthly_carton_codes'])],
            ['Monthly Bundle Codes', _v(limits['monthly_bundle_codes'])],
            ['Max Stores', _v(limits['max_stores'] ?? limits['stores'])],
            ['Max Drivers', _v(limits['max_drivers'] ?? limits['drivers'])],
            ['Max Users', _v(limits['max_users'])],
            [
              'Transport Connections / Month',
              _v(limits['transport_connections_per_month']),
            ],
            ['Loads / Month', _v(limits['max_loads_per_month'])],
          ]),
          const SizedBox(height: 20),
          _sectionTitle(context, 'Publish Rates'),
          const SizedBox(height: 8),
          _infoTable(context, <List<String>>[
            ['Unit', _v(publishRates['unit'])],
            ['Packet', _v(publishRates['packet'])],
            ['Carton', _v(publishRates['carton'])],
            ['Bundle', _v(publishRates['bundle'])],
          ]),
          const SizedBox(height: 20),
          _sectionTitle(context, 'Free Quota'),
          const SizedBox(height: 8),
          _infoTable(context, <List<String>>[
            ['Unit', _v(freeQuota['unit'])],
            ['Packet', _v(freeQuota['packet'])],
            ['Carton', _v(freeQuota['carton'])],
            ['Bundle', _v(freeQuota['bundle'])],
          ]),
          const SizedBox(height: 20),
          _sectionTitle(context, 'Features'),
          const SizedBox(height: 8),
          if (plan.features.isEmpty)
            const Text('-')
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: plan.features
                  .map((f) => Chip(label: Text(f.name)))
                  .toList(),
            ),
          const SizedBox(height: 20),
          _sectionTitle(context, 'Metadata (Other)'),
          const SizedBox(height: 8),
          if (otherMeta.isEmpty)
            const Text('-')
          else
            _infoTable(
              context,
              otherMeta.entries
                  .map((e) => <String>[e.key, _v(e.value)])
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context)
          .textTheme
          .titleMedium
          ?.copyWith(fontWeight: FontWeight.w800),
    );
  }

  Widget _infoTable(BuildContext context, List<List<String>> rows) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Table(
        columnWidths: const {
          0: FixedColumnWidth(260),
          1: FlexColumnWidth(),
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: rows.map((r) {
          return TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 12,
                ),
                child: Text(
                  r[0],
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 12,
                ),
                child: Text(
                  r[1],
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  String _v(dynamic value) {
    final s = value?.toString().trim() ?? '';
    return s.isEmpty ? '-' : s;
  }

  void _showEditPlanDialog(Plan plan) {
    final currentState = context.read<PlanManagementBloc>().state;
    final availableFeatures = currentState.maybeMap(
      loaded: (s) => s.availableFeatures,
      planDetailLoaded: (s) => s.availableFeatures,
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
    final priceCtrl = TextEditingController(text: initialPrice.toStringAsFixed(2));

    final currentPublishRates = plan.metadata?['publish_rates'];
    final currentUnitRate = currentPublishRates is Map
        ? (currentPublishRates['unit'] as num?)?.toDouble()
        : null;
    final unitCodePriceCtrl = TextEditingController(
      text: currentUnitRate == null ? '' : currentUnitRate.toString(),
    );

    bool isFeatured = plan.isFeatured;
    bool isPopular = plan.isPopular;
    final sortOrderCtrl = TextEditingController(text: plan.sortOrder.toString());

    final limits = plan.limits;
    String intText(dynamic value) {
      final v = value;
      if (v == null) return '';
      if (v is num) return v.toInt().toString();
      return v.toString().trim();
    }

    final monthlyUnitCodesCtrl = TextEditingController(
      text: intText(limits['monthly_unit_codes']),
    );
    final monthlyPacketCodesCtrl = TextEditingController(
      text: intText(limits['monthly_packet_codes']),
    );
    final monthlyCartonCodesCtrl = TextEditingController(
      text: intText(limits['monthly_carton_codes']),
    );
    final monthlyBundleCodesCtrl = TextEditingController(
      text: intText(limits['monthly_bundle_codes']),
    );
    final maxStoresCtrl = TextEditingController(
      text: intText(limits['max_stores'] ?? limits['stores']),
    );
    final maxDriversCtrl = TextEditingController(
      text: intText(limits['max_drivers'] ?? limits['drivers']),
    );
    final maxUsersCtrl = TextEditingController(
      text: intText(limits['max_users']),
    );
    final transportConnectionsCtrl = TextEditingController(
      text: intText(limits['transport_connections_per_month']),
    );
    final loadsPerMonthCtrl = TextEditingController(
      text: intText(limits['max_loads_per_month']),
    );

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setLocalState) {
            return AlertDialog(
              title: const Text('Edit Plan'),
              content: SizedBox(
                width: 720,
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
                                DropdownMenuItem(value: 'active', child: Text('Active')),
                                DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                                DropdownMenuItem(value: 'archived', child: Text('Archived')),
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
                                DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                                DropdownMenuItem(value: 'quarterly', child: Text('Quarterly')),
                                DropdownMenuItem(value: 'yearly', child: Text('Yearly')),
                                DropdownMenuItem(value: 'one_time', child: Text('One Time')),
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
                      TextField(
                        controller: unitCodePriceCtrl,
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Unit Code Price (per code)',
                          border: OutlineInputBorder(),
                        ),
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
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Limits',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: monthlyUnitCodesCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Monthly Unit Codes',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: monthlyPacketCodesCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Monthly Packet Codes',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: monthlyCartonCodesCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Monthly Carton Codes',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: monthlyBundleCodesCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Monthly Bundle Codes',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: maxStoresCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Max Stores',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: maxDriversCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Max Drivers',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: maxUsersCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Max Users',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: transportConnectionsCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Transport Connections / Month',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: loadsPerMonthCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Loads / Month',
                          border: OutlineInputBorder(),
                        ),
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
                          final features = entry.value;
                          return ExpansionTile(
                            tilePadding: EdgeInsets.zero,
                            title: Text(entry.key),
                            children: features
                                .map(
                                  (feature) => CheckboxListTile(
                                    value: selectedFeatureIds.contains(feature.id),
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
                                    controlAffinity: ListTileControlAffinity.leading,
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
                    final unitCodePriceText = unitCodePriceCtrl.text.trim();
                    final parsedUnitCodePrice = unitCodePriceText.isEmpty
                        ? null
                        : double.tryParse(unitCodePriceText);

                    final metadata = <String, dynamic>{...?(plan.metadata)};
                    if (parsedUnitCodePrice != null) {
                      metadata['publish_rates'] = <String, dynamic>{
                        'unit': parsedUnitCodePrice,
                        'packet': parsedUnitCodePrice * 3,
                        'carton': parsedUnitCodePrice * 5,
                        'bundle': parsedUnitCodePrice * 10,
                      };
                    }

                    final limitsUpdate = <String, dynamic>{};
                    final mu = int.tryParse(monthlyUnitCodesCtrl.text.trim());
                    if (mu != null) limitsUpdate['monthly_unit_codes'] = mu;
                    final mp = int.tryParse(monthlyPacketCodesCtrl.text.trim());
                    if (mp != null) limitsUpdate['monthly_packet_codes'] = mp;
                    final mc = int.tryParse(monthlyCartonCodesCtrl.text.trim());
                    if (mc != null) limitsUpdate['monthly_carton_codes'] = mc;
                    final mb = int.tryParse(monthlyBundleCodesCtrl.text.trim());
                    if (mb != null) limitsUpdate['monthly_bundle_codes'] = mb;
                    final ms = int.tryParse(maxStoresCtrl.text.trim());
                    if (ms != null) limitsUpdate['max_stores'] = ms;
                    final md = int.tryParse(maxDriversCtrl.text.trim());
                    if (md != null) limitsUpdate['max_drivers'] = md;
                    final mu2 = int.tryParse(maxUsersCtrl.text.trim());
                    if (mu2 != null) limitsUpdate['max_users'] = mu2;
                    final tc =
                        int.tryParse(transportConnectionsCtrl.text.trim());
                    if (tc != null) {
                      limitsUpdate['transport_connections_per_month'] = tc;
                    }
                    final lm = int.tryParse(loadsPerMonthCtrl.text.trim());
                    if (lm != null) limitsUpdate['max_loads_per_month'] = lm;

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
                            limits: limitsUpdate.isEmpty ? null : limitsUpdate,
                            features: selectedFeatureIds
                                .map((id) => PlanFeatureInput(id: id))
                                .toList(),
                            metadata: metadata.isEmpty ? null : metadata,
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
}
