import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:trace_odd/features/marketplace_public/data/marketplace_public_repository.dart';
import 'package:trace_odd/features/marketplace_public/presentation/widgets/marketplace_product_card.dart';
import 'package:trace_odd/features/marketplace_public/theme/marketplace_theme.dart';

/// One factory's public storefront — its published products only (item #12).
class MarketplaceStorefrontPage extends StatefulWidget {
  const MarketplaceStorefrontPage({super.key, required this.factoryId});

  final String factoryId;

  @override
  State<MarketplaceStorefrontPage> createState() =>
      _MarketplaceStorefrontPageState();
}

class _MarketplaceStorefrontPageState extends State<MarketplaceStorefrontPage> {
  final _repo = MarketplacePublicRepository();

  List<Map<String, dynamic>> _products = [];
  Map<String, dynamic>? _factory;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        _repo.products(factoryId: widget.factoryId),
        _repo.factories(),
      ]);

      _products = results[0];
      _factory = results[1].cast<Map<String, dynamic>>().firstWhere(
        (f) => f['id']?.toString() == widget.factoryId,
        orElse: () => _products.isNotEmpty
            ? _productAsFactory(_products.first)
            : const {},
      );
    } catch (e) {
      _error = e.toString();
    }
    if (mounted) setState(() => _loading = false);
  }

  /// A storefront header built from a product row, when the factory list does
  /// not carry this id (e.g. it fell out of the active set).
  Map<String, dynamic> _productAsFactory(Map<String, dynamic> p) => {
    'name': p['factory_name'],
    'city': p['factory_city'],
    'logo_url': p['factory_logo'],
    'product_count': null,
  };

  @override
  Widget build(BuildContext context) {
    final name = _factory?['name']?.toString() ?? 'Storefront';
    final city = _factory?['city']?.toString() ?? '';
    final logo = _factory?['logo_url']?.toString() ?? '';

    return Scaffold(
      backgroundColor: MpColors.bg,
      body: RefreshIndicator(
        color: MpColors.indigo,
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          children: [
            // Header
            Container(
              decoration: const BoxDecoration(gradient: MpColors.heroGradient),
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 34),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => context.go('/'),
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                            tooltip: 'Back to marketplace',
                          ),
                          const SizedBox(width: 6),
                          Container(
                            width: 24,
                            height: 24,
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.92),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: SvgPicture.asset(
                              'assets/logo/traceodd_logo.svg',
                              semanticsLabel: 'Trace Odd',
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Trace Odd Marketplace',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: SizedBox(
                              width: 62,
                              height: 62,
                              child: logo.isNotEmpty
                                  ? Image.network(
                                      logo,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          _placeholder(name),
                                    )
                                  : _placeholder(name),
                            ),
                          ),
                          const SizedBox(width: 16),
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
                                          fontSize: 24,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.verified,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  city.isEmpty
                                      ? '${_products.length} products'
                                      : '$city · ${_products.length} products',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white.withValues(alpha: 0.85),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 80),
                child: Center(
                  child: CircularProgressIndicator(color: MpColors.indigo),
                ),
              )
            else if (_error != null)
              _errorState()
            else
              _productGrid(),
          ],
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
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: MpColors.indigo,
        ),
      ),
    );
  }

  Widget _productGrid() {
    if (_products.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 70),
        child: Center(
          child: Text(
            'This factory has not published any products yet.',
            style: TextStyle(color: MpColors.inkSoft),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: LayoutBuilder(
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
                    onTap: () => showMpProductDetails(context, product),
                  );
                },
              );
            },
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
              'Could not load this storefront',
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
}
