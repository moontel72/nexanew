import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:trace_odd/features/marketplace_public/theme/marketplace_theme.dart';

/// Where a buyer goes to open an account. Item #13 makes the account the buying
/// door; this public site only browses, so the CTA links back to the main site.
const String kRegisterUrl = 'https://traceodd.com';

double? _num(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString());
}

String _str(dynamic v) => v?.toString() ?? '';

/// A single published product, as a buyer sees it.
class MpProductCard extends StatelessWidget {
  const MpProductCard({super.key, required this.product, this.onTap});

  final Map<String, dynamic> product;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final name = _str(product['name']).isEmpty
        ? 'Product'
        : _str(product['name']);
    final factory = _str(product['factory_name']);
    final city = _str(product['factory_city']);
    final currency = _str(product['currency']).isEmpty
        ? 'PKR'
        : _str(product['currency']);
    final wholesale = _num(product['wholesale_price']);
    final price = wholesale ?? _num(product['price']) ?? 0;
    final moq = _str(product['moq']).isEmpty ? '1' : _str(product['moq']);
    final imageUrl = _str(product['image_url']);
    final category = _str(product['category']);
    final verified = _str(product['factory_status']) == 'active';

    return Material(
      color: MpColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: MpColors.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 1.15,
                    child: _ProductImage(url: imageUrl, name: name),
                  ),
                  if (category.isNotEmpty)
                    Positioned(
                      left: 10,
                      top: 10,
                      child: _Pill(
                        text: category.replaceAll('_', ' '),
                        background: MpColors.surface.withValues(alpha: 0.92),
                        foreground: MpColors.inkSoft,
                      ),
                    ),
                  if (wholesale != null)
                    Positioned(
                      right: 10,
                      top: 10,
                      child: _Pill(
                        text: 'WHOLESALE',
                        background: MpColors.coral,
                        foreground: Colors.white,
                      ),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.25,
                        fontWeight: FontWeight.w700,
                        color: MpColors.ink,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (verified)
                          const Icon(
                            Icons.verified,
                            size: 14,
                            color: MpColors.teal,
                          ),
                        if (verified) const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            city.isEmpty ? factory : '$factory · $city',
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
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: '$currency ',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: MpColors.inkFaint,
                                  ),
                                ),
                                TextSpan(
                                  text: price.toStringAsFixed(0),
                                  style: const TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w800,
                                    color: MpColors.coral,
                                  ),
                                ),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _Pill(
                          text: 'MOQ $moq',
                          background: MpColors.surfaceAlt,
                          foreground: MpColors.inkSoft,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.url, required this.name});

  final String url;
  final String name;

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return _placeholder();
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _placeholder(),
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : _placeholder(),
    );
  }

  Widget _placeholder() {
    final letter = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
    return Container(
      decoration: const BoxDecoration(gradient: MpColors.placeholderGradient),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: const TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.w800,
          color: MpColors.indigo,
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.text,
    required this.background,
    required this.foreground,
  });

  final String text;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
          color: foreground,
        ),
      ),
    );
  }
}

/// Full product details, shown as a bottom sheet (no product-detail endpoint is
/// public, so everything the browse APIs return is rendered here).
Future<void> showMpProductDetails(
  BuildContext context,
  Map<String, dynamic> p,
) {
  final name = _str(p['name']).isEmpty ? 'Product' : _str(p['name']);
  final factory = _str(p['factory_name']);
  final city = _str(p['factory_city']);
  final currency = _str(p['currency']).isEmpty ? 'PKR' : _str(p['currency']);
  final price = _num(p['wholesale_price']) ?? _num(p['price']) ?? 0;
  final carton = _num(p['carton_price']);
  final moq = _str(p['moq']).isEmpty ? '1' : _str(p['moq']);
  final imageUrl = _str(p['image_url']);
  final sku = _str(p['sku']);
  final promo = _num(p['promo_discount']);
  final bonusQty = _num(p['bonus_quantity']);
  final bonusThreshold = _num(p['bonus_threshold']);
  final tiers = p['volume_discounts'];

  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: MpColors.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    builder: (ctx) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        builder: (ctx, scrollController) {
          return ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: MpColors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: AspectRatio(
                  aspectRatio: 1.4,
                  child: _ProductImage(url: imageUrl, name: name),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  color: MpColors.ink,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.verified, size: 15, color: MpColors.teal),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      city.isEmpty ? factory : '$factory · $city',
                      style: const TextStyle(
                        fontSize: 13,
                        color: MpColors.inkSoft,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '$currency ',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: MpColors.inkFaint,
                          ),
                        ),
                        TextSpan(
                          text: price.toStringAsFixed(2),
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: MpColors.coral,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: _Pill(
                      text: 'per unit',
                      background: MpColors.surfaceAlt,
                      foreground: MpColors.inkSoft,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _DetailRow(label: 'Minimum order (MOQ)', value: moq),
              if (sku.isNotEmpty) _DetailRow(label: 'SKU', value: sku),
              if (carton != null)
                _DetailRow(
                  label: 'Carton price',
                  value: '$currency ${carton.toStringAsFixed(2)}',
                ),
              if (promo != null && promo > 0)
                _DetailRow(
                  label: 'Promo discount',
                  value: '${promo.toStringAsFixed(0)}%',
                ),
              if (bonusQty != null && bonusThreshold != null)
                _DetailRow(
                  label: 'Bonus',
                  value:
                      '+${bonusQty.toStringAsFixed(0)} free on '
                      '${bonusThreshold.toStringAsFixed(0)}+',
                ),
              if (tiers is List && tiers.isNotEmpty) ...[
                const SizedBox(height: 18),
                const Text(
                  'Volume pricing',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: MpColors.ink,
                  ),
                ),
                const SizedBox(height: 8),
                ...tiers.whereType<Map>().map((t) {
                  final min = _num(t['min_qty'] ?? t['min_quantity']) ?? 0;
                  final pct = _num(t['discount_percent'] ?? t['discount']) ?? 0;
                  final tierPrice = price * (1 - pct / 100);
                  return _DetailRow(
                    label: '$min+ units',
                    value:
                        '$currency ${tierPrice.toStringAsFixed(2)}'
                        '  (−${pct.toStringAsFixed(0)}%)',
                  );
                }),
              ],
              const SizedBox(height: 22),
              SizedBox(
                height: 50,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: MpColors.indigo,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => launchUrl(
                    Uri.parse(kRegisterUrl),
                    mode: LaunchMode.externalApplication,
                  ),
                  icon: const Icon(Icons.storefront_outlined, size: 20),
                  label: const Text(
                    'Register your factory / reseller / shop',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Browsing is open to everyone. To place an order you need a '
                'business account — that is the buying door.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11.5, color: MpColors.inkFaint),
              ),
            ],
          );
        },
      );
    },
  );
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: MpColors.inkSoft),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: MpColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}
