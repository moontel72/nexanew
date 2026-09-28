import 'package:flutter/material.dart';
import 'package:trace_odd/shared/models/subscription/plan_limit_model.dart';
import 'package:trace_odd/shared/theme/colors.dart';
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
  @override
  Widget build(BuildContext context) {
    const limits = PlanLimitModel(
      canContactDriversDirectly: true,
      canContactOwnersDirectly: true,
      canUseGoodsCompanies: true,
      maxLoadsPerMonth: 5,
    );
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
      _buildOverviewTab(),
      _buildProductsTab(),
      _buildBillingTab(),
    ];

    if (canAccessTransport) {
      views.add(_buildTransportTab(limits));
    } else {
      views.add(_buildUpgradePrompt());
    }

    return views;
  }

  bool _canAccessTransport(PlanLimitModel limits) {
    return limits.canContactDriversDirectly || limits.canUseGoodsCompanies;
  }

  Widget _buildOverviewTab() {
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
                      _buildActionButton(
                        'Manage Products',
                        Icons.inventory,
                        () {
                          // Navigate to products management
                          _showSnackbar('Navigate to products management');
                        },
                      ),
                      _buildActionButton('Generate Codes', Icons.qr_code, () {
                        // Navigate to code generation
                        _showSnackbar('Navigate to code generation');
                      }),
                      _buildActionButton('View Reports', Icons.analytics, () {
                        // Navigate to reports
                        _showSnackbar('Navigate to reports');
                      }),
                      _buildActionButton('Settings', Icons.settings, () {
                        // Navigate to settings
                        _showSnackbar('Navigate to settings');
                      }),
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
                          // Add new product
                          _showSnackbar('Add new product');
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
