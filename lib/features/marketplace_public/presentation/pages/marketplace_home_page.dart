import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:trace_odd/features/marketplace_public/data/marketplace_cart.dart';
import 'package:trace_odd/features/marketplace_public/data/marketplace_public_repository.dart';
import 'package:trace_odd/features/marketplace_public/presentation/widgets/marketplace_product_card.dart';
import 'package:trace_odd/features/marketplace_public/theme/marketplace_theme.dart';

/// The public marketplace home — browse everything, no login (item #12).
///
/// Layout the owner asked for (2026-09-29):
///   * **Verified factories** in their own FIXED-HEIGHT box. The list scrolls
///     vertically inside that box (it never grows past it), and when there are
///     more factories than one page holds, horizontal page numbers appear at the
///     bottom of the box and page the list inside it.
///   * **Products** below, best-rated / most-viewed first, paged the same way —
///     page numbers at the bottom.
///
/// Both use the API's own paging for products (server-side `page`/`limit`) and a
/// client-side page window for factories, because `/reseller/factories` returns
/// the full list by design.
class MarketplaceHomePage extends StatefulWidget {
  const MarketplaceHomePage({super.key});

  @override
  State<MarketplaceHomePage> createState() => _MarketplaceHomePageState();
}

class _MarketplaceHomePageState extends State<MarketplaceHomePage> {
  static const _factoryPageSize = 6;
  static const _productsPageSize = 12;

  final _repo = MarketplacePublicRepository();
  final _searchController = TextEditingController();
  final _factoryScroll = ScrollController();

  List<Map<String, dynamic>> _factories = [];
  List<Map<String, dynamic>> _products = [];
  MpPage? _productsPage;
  List<String> _categoryOptions = const [];

  bool _loading = true;
  bool _productsLoading = false;
  String? _error;

  String? _category;
  String _sortBy = 'popular';
  int _factoryPage = 1;
  int _productsPageNo = 1;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _factoryScroll.dispose();
    super.dispose();
  }

  // ─── Data ────────────────────────────────────────────────────────

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final factories = await _repo.factories();
      final page = await _repo.productsPage(
        search: _searchController.text.trim(),
        category: _category,
        sortBy: _sortBy,
        page: 1,
        limit: _productsPageSize,
      );

      _factories = factories;
      _products = page.items;
      _productsPage = page;
      _factoryPage = 1;
      _productsPageNo = 1;

      // Chips are captured once, from an unfiltered first page, so applying a
      // filter does not make the chips themselves disappear.
      if (_categoryOptions.isEmpty &&
          _category == null &&
          _searchController.text.trim().isEmpty) {
        _categoryOptions = _categoriesFrom(page.items);
      }
    } catch (e) {
      _error = e.toString();
    }

    if (mounted) setState(() => _loading = false);
  }

  Future<void> _loadProductsPage(int page) async {
    setState(() => _productsLoading = true);
    try {
      final result = await _repo.productsPage(
        search: _searchController.text.trim(),
        category: _category,
        sortBy: _sortBy,
        page: page,
        limit: _productsPageSize,
      );
      if (!mounted) return;
      setState(() {
        _products = result.items;
        _productsPage = result;
        _productsPageNo = result.page;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    }
    if (mounted) setState(() => _productsLoading = false);
  }

  List<String> _categoriesFrom(List<Map<String, dynamic>> items) {
    final set = <String>{};
    for (final p in items) {
      final c = p['category']?.toString().trim() ?? '';
      if (c.isNotEmpty) set.add(c);
    }
    final list = set.toList()..sort();
    return list;
  }

  Future<void> _openRegister() =>
      launchUrl(Uri.parse(kRegisterUrl), mode: LaunchMode.externalApplication);

  // ─── Build ───────────────────────────────────────────────────────

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
              _factoriesSection(),
              _categoriesRow(),
              _productsSection(context),
            ],
            _footer(),
          ],
        ),
      ),
    );
  }

  Widget _sectionShell({required Widget child}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: child,
        ),
      ),
    );
  }

  // ─── Hero ────────────────────────────────────────────────────────

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
                  _stat('${_productsPage?.total ?? 0}', 'Products listed'),
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

  // ─── Verified factories: a fixed box that scrolls inside ─────────

  Widget _factoriesSection() {
    if (_factories.isEmpty) return const SizedBox.shrink();

    final totalPages =
        ((_factories.length + _factoryPageSize - 1) ~/ _factoryPageSize).clamp(
          1,
          9999,
        );
    final current = _factoryPage.clamp(1, totalPages);
    final start = (current - 1) * _factoryPageSize;
    final pageItems = _factories.skip(start).take(_factoryPageSize).toList();

    return _sectionShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Expanded(
                child: Text(
                  'Verified factories',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: MpColors.ink,
                  ),
                ),
              ),
              Text(
                '${_factories.length} factor${_factories.length == 1 ? 'y' : 'ies'}',
                style: const TextStyle(fontSize: 13, color: MpColors.inkFaint),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // The fixed box. It has a hard height, so the list scrolls INSIDE it
          // instead of pushing the products down the page.
          Container(
            height: 330,
            decoration: BoxDecoration(
              color: MpColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: MpColors.border),
            ),
            child: Scrollbar(
              controller: _factoryScroll,
              thumbVisibility: true,
              child: ListView.separated(
                controller: _factoryScroll,
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                itemCount: pageItems.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final f = pageItems[index];
                  return _FactoryRow(
                    factory: f,
                    onTap: () =>
                        context.go('/store/${f['id']?.toString() ?? ''}'),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 10),
          _Pager(
            current: current,
            total: totalPages,
            onSelect: (p) => setState(() {
              _factoryPage = p;
              if (_factoryScroll.hasClients) {
                _factoryScroll.jumpTo(0);
              }
            }),
          ),
        ],
      ),
    );
  }

  // ─── Categories ──────────────────────────────────────────────────

  Widget _categoriesRow() {
    final cats = _categoryOptions;
    if (cats.isEmpty) return const SizedBox.shrink();

    return _sectionShell(
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _categoryChip('All', null),
          ...cats.map((c) => _categoryChip(c.replaceAll('_', ' '), c)),
        ],
      ),
    );
  }

  Widget _categoryChip(String label, String? value) {
    final selected = _category == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      // Filtering happens on the server now, so the page resets.
      onSelected: (_) {
        setState(() => _category = value);
        _loadProductsPage(1);
      },
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

  // ─── Products: sorted, paged ─────────────────────────────────────

  Widget _productsSection(BuildContext context) {
    return _sectionShell(
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
              _sortDropdown(),
            ],
          ),
          const SizedBox(height: 16),
          if (_productsLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 60),
              child: Center(
                child: CircularProgressIndicator(color: MpColors.indigo),
              ),
            )
          else if (_products.isEmpty)
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
                  itemCount: _products.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.72,
                  ),
                  itemBuilder: (context, index) {
                    final product = _products[index];
                    return MpProductCard(
                      product: product,
                      onAdd: () => addProductToCart(product),
                      onTap: () => showMpProductDetails(
                        context,
                        product,
                        onAdd: () => addProductToCart(product),
                      ),
                    );
                  },
                );
              },
            ),
          const SizedBox(height: 18),
          _Pager(
            current: _productsPageNo,
            total: _productsPage?.totalPages ?? 1,
            onSelect: _loadProductsPage,
          ),
        ],
      ),
    );
  }

  Widget _sortDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: MpColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: MpColors.border),
      ),
      child: DropdownButton<String>(
        value: _sortBy,
        underline: const SizedBox.shrink(),
        borderRadius: BorderRadius.circular(10),
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: MpColors.ink,
        ),
        items: const [
          DropdownMenuItem(value: 'popular', child: Text('Most viewed')),
          DropdownMenuItem(value: 'newest', child: Text('Newest')),
          DropdownMenuItem(
            value: 'price_asc',
            child: Text('Price: low → high'),
          ),
          DropdownMenuItem(
            value: 'price_desc',
            child: Text('Price: high → low'),
          ),
          DropdownMenuItem(value: 'name', child: Text('Name (A–Z)')),
        ],
        onChanged: (value) {
          if (value == null) return;
          setState(() => _sortBy = value);
          _loadProductsPage(1);
        },
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

// ─── Small pieces ──────────────────────────────────────────────────

/// Page numbers. Scrolls horizontally so a long run (…24, 25) never overflows.
class _Pager extends StatelessWidget {
  const _Pager({
    required this.current,
    required this.total,
    required this.onSelect,
  });

  final int current;
  final int total;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    if (total <= 1) return const SizedBox.shrink();

    final start = (current - 3).clamp(1, total);
    final end = (current + 3).clamp(1, total);
    final pages = [for (var p = start; p <= end; p++) p];

    return Row(
      children: [
        IconButton(
          tooltip: 'Previous',
          onPressed: current > 1 ? () => onSelect(current - 1) : null,
          icon: const Icon(Icons.chevron_left),
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final p in pages)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: _PageButton(
                      number: p,
                      selected: p == current,
                      onTap: () => onSelect(p),
                    ),
                  ),
              ],
            ),
          ),
        ),
        IconButton(
          tooltip: 'Next',
          onPressed: current < total ? () => onSelect(current + 1) : null,
          icon: const Icon(Icons.chevron_right),
        ),
        const SizedBox(width: 6),
        Text(
          'Page $current of $total',
          style: const TextStyle(fontSize: 12, color: MpColors.inkFaint),
        ),
      ],
    );
  }
}

class _PageButton extends StatelessWidget {
  const _PageButton({
    required this.number,
    required this.selected,
    required this.onTap,
  });

  final int number;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? MpColors.indigo : MpColors.surface,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? MpColors.indigo : MpColors.border,
            ),
          ),
          child: Text(
            '$number',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : MpColors.inkSoft,
            ),
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
                        color: MpColors.surfaceAlt,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: SvgPicture.asset(
                        'assets/logo/traceodd_logo.svg',
                        semanticsLabel: 'Trace Odd',
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
              const _CartButton(),
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

/// Cart button with a live item-count badge.
class _CartButton extends StatelessWidget {
  const _CartButton();

  @override
  Widget build(BuildContext context) {
    final cart = MpCart.instance;

    return ListenableBuilder(
      listenable: cart,
      builder: (context, _) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              tooltip: 'Your cart',
              onPressed: () => context.go('/cart'),
              icon: const Icon(
                Icons.shopping_cart_outlined,
                color: MpColors.ink,
              ),
            ),
            if (cart.itemCount > 0)
              Positioned(
                right: 2,
                top: 2,
                child: IgnorePointer(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: MpColors.coral,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${cart.itemCount}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// One factory as a full-width row (it lives in a vertical list inside the box).
class _FactoryRow extends StatelessWidget {
  const _FactoryRow({required this.factory, required this.onTap});

  final Map<String, dynamic> factory;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final name = factory['name']?.toString() ?? 'Factory';
    final city = factory['city']?.toString() ?? '';
    final count = factory['product_count']?.toString() ?? '0';
    final logo = factory['logo_url']?.toString() ?? '';
    final rating = factory['rating'];
    final reviews = factory['total_reviews'];
    final ratingValue = rating is num ? rating.toDouble() : null;

    return Material(
      color: MpColors.bg,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 46,
                  height: 46,
                  child: logo.isNotEmpty
                      ? Image.network(
                          logo,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _placeholder(name),
                        )
                      : _placeholder(name),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: MpColors.ink,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.verified,
                          size: 15,
                          color: MpColors.teal,
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        if (ratingValue != null && ratingValue > 0) ...[
                          const Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: MpColors.amber,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            ratingValue.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: MpColors.inkSoft,
                            ),
                          ),
                          if (reviews is num && reviews > 0)
                            Text(
                              ' (${reviews.toInt()})',
                              style: const TextStyle(
                                fontSize: 11,
                                color: MpColors.inkFaint,
                              ),
                            ),
                          const SizedBox(width: 10),
                        ],
                        Expanded(
                          child: Text(
                            city.isEmpty
                                ? '$count products'
                                : '$city · $count products',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: MpColors.inkSoft,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                size: 20,
                color: MpColors.inkFaint,
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
