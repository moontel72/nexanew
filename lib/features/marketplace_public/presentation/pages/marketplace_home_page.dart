import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:trace_odd/features/marketplace_public/data/marketplace_public_repository.dart';
import 'package:trace_odd/features/marketplace_public/presentation/widgets/marketplace_product_card.dart';
import 'package:trace_odd/features/marketplace_public/theme/marketplace_theme.dart';

/// The public marketplace home — browse everything, no login (item #12).
class MarketplaceHomePage extends StatefulWidget {
  const MarketplaceHomePage({super.key});

  @override
  State<MarketplaceHomePage> createState() => _MarketplaceHomePageState();
}

class _MarketplaceHomePageState extends State<MarketplaceHomePage> {
  final _repo = MarketplacePublicRepository();
  final _searchController = TextEditingController();

  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _factories = [];
  bool _loading = true;
  String? _error;
  String? _category;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        _repo.products(search: _searchController.text.trim()),
        _repo.factories(),
      ]);
      _products = results[0];
      _factories = results[1];
    } catch (e) {
      _error = e.toString();
    }
    if (mounted) setState(() => _loading = false);
  }

  List<String> get _categories {
    final set = <String>{};
    for (final p in _products) {
      final c = p['category']?.toString() ?? '';
      if (c.trim().isNotEmpty) set.add(c.trim());
    }
    final list = set.toList()..sort();
    return list;
  }

  List<Map<String, dynamic>> get _visibleProducts {
    if (_category == null) return _products;
    return _products
        .where((p) => (p['category']?.toString() ?? '') == _category)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MpColors.bg,
      body: RefreshIndicator(
        color: MpColors.indigo,
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          children: [
            _TopBar(onRegister: _openRegister),
            _hero(context),
            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 80),
                child: Center(
                  child: CircularProgressIndicator(color: MpColors.indigo),
                ),
              )
            else if (_error != null)
              _errorState()
            else ...[
              _categoriesRow(),
              _productsSection(context),
              _factoriesSection(context),
            ],
            _footer(),
          ],
        ),
      ),
    );
  }

  Future<void> _openRegister() =>
      launchUrl(Uri.parse(kRegisterUrl), mode: LaunchMode.externalApplication);

  // ─── Sections ────────────────────────────────────────────────────

  Widget _hero(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: MpColors.heroGradient),
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 44),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  'VERIFIED FACTORIES  ·  WHOLESALE PRICES  ·  MOQ',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Wholesale, straight from\nthe factory floor.',
                style: TextStyle(
                  fontSize: 40,
                  height: 1.12,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Browse every published product with its wholesale price and '
                'minimum order — no login, no gate.',
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: Colors.white.withValues(alpha: 0.88),
                ),
              ),
              const SizedBox(height: 24),
              _heroSearch(),
              const SizedBox(height: 24),
              Row(
                children: [
                  _stat('${_factories.length}', 'Verified factories'),
                  const SizedBox(width: 28),
                  _stat('${_products.length}', 'Products listed'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stat(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _heroSearch() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Icon(Icons.search, color: MpColors.inkFaint),
          ),
          Expanded(
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _load(),
              decoration: const InputDecoration(
                hintText: 'Search products, brands or categories…',
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: MpColors.coral,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
            ),
            onPressed: _load,
            child: const Text(
              'Search',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoriesRow() {
    final cats = _categories;
    if (cats.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _categoryChip('All', null),
              ...cats.map((c) => _categoryChip(c.replaceAll('_', ' '), c)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _categoryChip(String label, String? value) {
    final selected = _category == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _category = value),
      showCheckmark: false,
      labelStyle: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: selected ? Colors.white : MpColors.inkSoft,
      ),
      selectedColor: MpColors.indigo,
      backgroundColor: MpColors.surface,
      side: BorderSide(color: selected ? MpColors.indigo : MpColors.border),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    );
  }

  Widget _productsSection(BuildContext context) {
    final products = _visibleProducts;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Expanded(
                    child: Text(
                      'Featured products',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: MpColors.ink,
                      ),
                    ),
                  ),
                  Text(
                    '${products.length} item${products.length == 1 ? '' : 's'}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: MpColors.inkFaint,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (products.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 48),
                  decoration: BoxDecoration(
                    color: MpColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: MpColors.border),
                  ),
                  child: const Column(
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 40,
                        color: MpColors.inkFaint,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'No products match this view yet.',
                        style: TextStyle(color: MpColors.inkSoft),
                      ),
                    ],
                  ),
                )
              else
                LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth >= 1080
                        ? 4
                        : constraints.maxWidth >= 760
                        ? 3
                        : constraints.maxWidth >= 480
                        ? 2
                        : 1;
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: products.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.72,
                      ),
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return MpProductCard(
                          product: product,
                          onTap: () => showMpProductDetails(context, product),
                        );
                      },
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _factoriesSection(BuildContext context) {
    if (_factories.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 36, 24, 0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Verified factories',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: MpColors.ink,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 150,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _factories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 14),
                  itemBuilder: (context, index) {
                    final f = _factories[index];
                    return _FactoryCard(
                      factory: f,
                      onTap: () =>
                          context.go('/store/${f['id']?.toString() ?? ''}'),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _errorState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 70, horizontal: 24),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.cloud_off, size: 44, color: MpColors.inkFaint),
            const SizedBox(height: 12),
            const Text(
              'Could not load the marketplace',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: MpColors.ink,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _error ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: MpColors.inkFaint),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _footer() {
    return Container(
      margin: const EdgeInsets.only(top: 48),
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
      color: MpColors.ink,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Trace Odd Marketplace',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              TextButton(
                onPressed: _openRegister,
                child: const Text(
                  'Sell on Trace Odd',
                  style: TextStyle(color: MpColors.teal),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onRegister});

  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.of(context).size.width < 640;
    return Container(
      color: MpColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Row(
            children: [
              InkWell(
                onTap: () => context.go('/'),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        gradient: MpColors.heroGradient,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.hub_outlined,
                        size: 19,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Trace Odd',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: MpColors.ink,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: MpColors.surfaceAlt,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'MARKETPLACE',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                          color: MpColors.indigo,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (!narrow)
                TextButton(
                  onPressed: onRegister,
                  child: const Text(
                    'Sign in / Register',
                    style: TextStyle(color: MpColors.inkSoft),
                  ),
                ),
              const SizedBox(width: 6),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: MpColors.indigo,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: onRegister,
                child: const Text(
                  'Sell on Trace Odd',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FactoryCard extends StatelessWidget {
  const _FactoryCard({required this.factory, required this.onTap});

  final Map<String, dynamic> factory;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final name = factory['name']?.toString() ?? 'Factory';
    final city = factory['city']?.toString() ?? '';
    final count = factory['product_count']?.toString() ?? '0';
    final logo = factory['logo_url']?.toString() ?? '';

    return Material(
      color: MpColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 230,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: MpColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(9),
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: logo.isNotEmpty
                          ? Image.network(
                              logo,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _placeholder(name),
                            )
                          : _placeholder(name),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Icon(Icons.verified, size: 15, color: MpColors.teal),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: MpColors.ink,
                ),
              ),
              const Spacer(),
              Text(
                city.isEmpty ? '$count products' : '$city · $count products',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: MpColors.inkSoft),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder(String name) {
    return Container(
      decoration: const BoxDecoration(gradient: MpColors.placeholderGradient),
      alignment: Alignment.center,
      child: Text(
        name.isEmpty ? '?' : name[0].toUpperCase(),
        style: const TextStyle(
          fontWeight: FontWeight.w800,
          color: MpColors.indigo,
        ),
      ),
    );
  }
}
