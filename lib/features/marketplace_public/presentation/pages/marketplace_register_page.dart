import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:trace_odd/features/marketplace_public/theme/marketplace_theme.dart';

/// The buying door (item #13).
///
/// The owner's rule: *the account is the buying door, the marketplace is not*.
/// So this page does not sell anything — it explains which of the three
/// business accounts a visitor needs and hands them to the registration that
/// already exists for it.
class MarketplaceRegisterPage extends StatelessWidget {
  const MarketplaceRegisterPage({super.key});

  static const _registerUrl = 'https://traceodd.com';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MpColors.bg,
      appBar: AppBar(
        title: const Text(
          'Open a buying account',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const Text(
                'Browsing is open to everyone.\nBuying needs an account.',
                style: TextStyle(
                  fontSize: 24,
                  height: 1.25,
                  fontWeight: FontWeight.w800,
                  color: MpColors.ink,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Every order on the marketplace is placed between registered '
                'businesses, so each side can be verified and both sides can be '
                'held to the order. Pick the account that matches what you do.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: MpColors.inkSoft,
                ),
              ),
              const SizedBox(height: 24),
              LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 820;
                  final cards = [
                    _card(
                      context,
                      icon: Icons.precision_manufacturing_outlined,
                      title: 'Factory',
                      blurb:
                          'Manufacture and sell wholesale. Publish products to '
                          'the marketplace and receive reseller orders.',
                    ),
                    _card(
                      context,
                      icon: Icons.storefront_outlined,
                      title: 'Reseller / Wholesaler',
                      blurb:
                          'Buy in bulk from factories and sell on. Your account '
                          'is what places an order against a factory.',
                    ),
                    _card(
                      context,
                      icon: Icons.local_convenience_store_outlined,
                      title: 'Shop Keeper',
                      blurb:
                          'Buy smaller quantities for a retail shop. Stock comes '
                          'from factories and resellers you are linked to.',
                    ),
                  ];

                  if (!wide) {
                    return Column(
                      children: [
                        for (final c in cards) ...[
                          c,
                          const SizedBox(height: 14),
                        ],
                      ],
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < cards.length; i++) ...[
                        Expanded(child: cards[i]),
                        if (i != cards.length - 1) const SizedBox(width: 14),
                      ],
                    ],
                  );
                },
              ),
              const SizedBox(height: 26),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: MpColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: MpColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.shopping_cart_checkout,
                      color: MpColors.coral,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Your cart is saved on this device. Register, sign in, '
                        'and it will still be waiting for you.',
                        style: TextStyle(fontSize: 13, color: MpColors.inkSoft),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 52,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: MpColors.indigo,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => launchUrl(
                    Uri.parse(_registerUrl),
                    mode: LaunchMode.externalApplication,
                  ),
                  icon: const Icon(Icons.person_add_alt_1, size: 20),
                  label: const Text(
                    'Open registration',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Already registered? Sign in there too — the same account '
                'opens your panel and your orders.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11.5, color: MpColors.inkFaint),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String blurb,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: MpColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MpColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: MpColors.indigo.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: MpColors.indigo),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: MpColors.ink,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            blurb,
            style: const TextStyle(
              fontSize: 13,
              height: 1.45,
              color: MpColors.inkSoft,
            ),
          ),
        ],
      ),
    );
  }
}
