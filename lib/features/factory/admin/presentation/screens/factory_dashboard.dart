import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trace_odd/shared/models/subscription/plan_limit_model.dart';
import 'package:trace_odd/shared/theme/colors.dart';
import 'package:trace_odd/shared/widgets/feedback/sticky_error_banner.dart';
import 'package:trace_odd/shared/widgets/loading/loading_indicator.dart';
import 'package:trace_odd/features/factory/admin/data/repositories/subscription_repository.dart';
import 'package:trace_odd/features/factory/admin/presentation/screens/billing/billing_dashboard_screen.dart';

class FactoryDashboard extends StatefulWidget {
  final String factoryId;
  final String userId;

  const FactoryDashboard({
    super.key,
    required this.factoryId,
    required this.userId,
  });

  @override
  State<FactoryDashboard> createState() => _FactoryDashboardState();
}

class _FactoryDashboardState extends State<FactoryDashboard> {
  final SubscriptionRepository _subscriptionRepository =
      SubscriptionRepository();

  /// The factory's real plan limits. Null while the first fetch is in flight (or
  /// after it failed), because the plan decides the dashboard's shape now.
  PlanLimitModel? _limits;
  bool _loadingLimits = true;
  String? _limitsError;
  String? _limitsErrorStack;

  @override
  void initState() {
    super.initState();
    _loadLimits();
  }

  /// Fetch the plan limits that gate this dashboard (MASTER-TASK-LIST.md item 9).
  ///
  /// This replaces a hardcoded `const PlanLimitModel(... maxLoadsPerMonth: 5 ...)`
  /// that made every factory look identically entitled.
  Future<void> _loadLimits() async {
    try {
      final limits = await _subscriptionRepository.getPlanLimits();
      if (!mounted) return;
      setState(() {
        _limits = limits;
        _loadingLimits = false;
      });
    } catch (e, stack) {
      if (!mounted) return;
      setState(() {
        _loadingLimits = false;
        _limitsError = e.toString();
        _limitsErrorStack = stack.toString();
      });
    }
  }

  void _retryLoadLimits() {
    setState(() {
      _loadingLimits = true;
      _limitsError = null;
      _limitsErrorStack = null;
    });
    _loadLimits();
  }

  @override
  Widget build(BuildContext context) {
    final limits = _limits;

    // Wait for the real limits before drawing tabs: the subscription decides how
    // many there are, so guessing first would draw the wrong shape — and (before
    // this change) crash on a tab/view count mismatch for a plan without transport.
    if (limits == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Factory Dashboard')),
        body: _buildLimitsGate(),
      );
    }

    final canAccessTransport = _canAccessTransport(limits);

    return DefaultTabController(
      length: canAccessTransport ? 4 : 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Factory Dashboard'),
          bottom: TabBar(tabs: _buildTabs(canAccessTransport)),
        ),
        body: TabBarView(children: _buildTabViews(canAccessTransport, limits)),
      ),
    );
  }

  /// Loading / failure surface for the limits fetch. A failure must stay, be
  /// copyable and be closable (owner's rule), hence StickyErrorBanner.
  Widget _buildLimitsGate() {
    if (_loadingLimits) {
      return const Center(child: LoadingIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_limitsError != null)
            StickyErrorBanner(
              message: _limitsError!,
              source:
                  'Factory · Dashboard · GET /api/v1/factory/subscription/limits',
              stack: _limitsErrorStack,
              onDismiss: () => setState(() => _limitsError = null),
            ),
          const SizedBox(height: 12),
          Center(
            child: ElevatedButton.icon(
              onPressed: _retryLoadLimits,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ),
        ],
      ),
    );
  }

  List<Tab> _buildTabs(bool canAccessTransport) {
    final tabs = [
      const Tab(text: 'Overview'),
      const Tab(text: 'Products'),
      const Tab(text: 'Billing'),
    ];

    if (canAccessTransport) {
      tabs.add(const Tab(text: 'Transport'));
    }

    return tabs;
  }

  List<Widget> _buildTabViews(bool canAccessTransport, PlanLimitModel limits) {
    final views = [
      _buildOverviewTab(canAccessTransport: canAccessTransport),
      _buildProductsTab(),
      _buildBillingTab(),
    ];

    if (canAccessTransport) {
      views.add(_buildTransportTab(limits));
    }

    return views;
  }

  /// Item 9 — the Transport tab is gated by the REAL subscription, so the tab
  /// count and the view count always agree (they did not before: a plan without
  /// transport produced 3 tabs but 4 views).
  bool _canAccessTransport(PlanLimitModel limits) {
    return limits.hasTransportAccess;
  }

  Widget _buildOverviewTab({required bool canAccessTransport}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // No transport in the plan → no Transport tab, so the upgrade path
          // lives here rather than vanishing with the tab.
          if (!canAccessTransport) ...[
            _buildUpgradePrompt(),
            const SizedBox(height: 20),
          ],
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Factory Overview',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildStatItem(
                    'Factory ID',
                    widget.factoryId,
                    Icons.business,
                  ),
                  const SizedBox(height: 12),
                  _buildStatItem('User ID', widget.userId, Icons.person),
                  const SizedBox(height: 12),
                  _buildStatItem('Status', 'Active', Icons.check_circle),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quick Actions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildActionButton('Manage Products', Icons.inventory, () {
                        // Real route (was a dead `_showSnackbar` placeholder).
                        context.go('/factory/products');
                      }),
                      _buildActionButton('Generate Codes', Icons.qr_code, () {
                        // Unit (auth) codes are the base of the code hierarchy; the
                        // sidebar offers every other type. Was a dead placeholder.
                        context.go('/factory/codes/unit/generate');
                      }),
                      // 'View Reports' and 'Settings' were removed (owner, 2026-09-29):
                      // no such route exists in this panel, so they were dead buttons.
                      // Re-add them when there is a real destination.
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Product Management',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Real route (was a dead `_showSnackbar` placeholder).
                          context.go('/factory/products/create');
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add Product'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Manage your factory products, generate QR codes, and track inventory.',
                    style: TextStyle(color: AppColors.gray600),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recent Products',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  // The three rows that used to sit here - 'Product A / SKU: PROD-001 • 500 units',
                  // then B and C - were hardcoded demo data from the repository's first commit, and each
                  // one only fired a snackbar ('View Product A details'). They were never the factory's
                  // real products. The live list is on the Products screen, reachable from the sidebar
                  // again since deb1d661, so this block now says where to look instead of inventing rows.
                  const ListTile(
                    leading: Icon(Icons.inventory, color: AppColors.primary),
                    title: Text('Open Products'),
                    subtitle: Text('The live product list for this factory'),
                    trailing: Icon(Icons.arrow_forward),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransportTab(PlanLimitModel limits) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Transport Features',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Manage transportation and logistics for your factory products.',
                    style: TextStyle(color: AppColors.gray600),
                  ),
                  const SizedBox(height: 16),
                  if (limits.canContactDriversDirectly)
                    _buildTransportFeatureCard(
                      'Direct Driver Contact',
                      'Find and bid directly with drivers',
                      Icons.person,
                      AppColors.success,
                      () => _initiateDriverContact(context),
                    ),
                  if (limits.canContactOwnersDirectly)
                    _buildTransportFeatureCard(
                      'Contact Truck Owners',
                      'Work directly with fleet owners',
                      Icons.business,
                      AppColors.primary,
                      () => _initiateOwnerContact(context),
                    ),
                  if (limits.canUseGoodsCompanies)
                    _buildTransportFeatureCard(
                      'Goods Transport Companies',
                      'Use professional transport services',
                      Icons.apartment,
                      AppColors.warning,
                      () => _showGoodsCompaniesDialog(context),
                    ),
                  if (limits.maxLoadsPerMonth > 0)
                    _buildTransportFeatureCard(
                      'Post New Load',
                      '${limits.maxLoadsPerMonth} loads/month available',
                      Icons.local_shipping,
                      AppColors.secondary,
                      () => _postNewLoad(context),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildTransportStatistics(),
        ],
      ),
    );
  }

  Widget _buildTransportFeatureCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward),
        onTap: onTap,
      ),
    );
  }

  /// Transport Statistics.
  ///
  /// This card used to render four HARDCODED demo figures — 'Active Loads 3', 'Active Bids 2',
  /// 'In Transit 1', 'Budget ₹45,000' — which came from the repository's very first commit and were never
  /// wired to anything (`git log -S "45,000"` -> 82f3ef9a). The owner asked for them to be removed rather
  /// than wired: fake numbers on a live panel are worse than no numbers. Kept as an empty widget so any
  /// caller still compiles; replacing it with real transport figures is a separate, deliberate step that
  /// needs the dashboard wired to the transport endpoints.
  Widget _buildTransportStatistics() {
    return const SizedBox.shrink();
  }

  Widget _buildStatItem(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          title,
          style: const TextStyle(fontSize: 12, color: AppColors.gray500),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildUpgradePrompt() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.local_shipping, size: 64, color: AppColors.gray500),
          const SizedBox(height: 16),
          const Text(
            'Transport Features Not Available',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Upgrade to Standard or Premium plan for transport access',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _showUpgradeDialog(context),
            child: const Text('Upgrade Plan'),
          ),
        ],
      ),
    );
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  void _showUpgradeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upgrade Plan'),
        content: const Text('Upgrade to access transport features'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Navigate to upgrade screen
              Navigator.pop(context);
              _showSnackbar('Navigate to upgrade screen');
            },
            child: const Text('Upgrade'),
          ),
        ],
      ),
    );
  }

  void _initiateDriverContact(BuildContext context) {
    _showSnackbar('Driver contact flow not wired yet');
  }

  Widget _buildBillingTab() {
    return const BillingDashboardScreen();
  }

  void _initiateOwnerContact(BuildContext context) {
    _showSnackbar('Truck owner contact flow not wired yet');
  }

  void _showGoodsCompaniesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Goods Transport Companies'),
        content: const Text(
          'List of goods transport companies will appear here',
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

  void _postNewLoad(BuildContext context) {
    _showSnackbar('Load posting flow not wired yet');
  }
}
