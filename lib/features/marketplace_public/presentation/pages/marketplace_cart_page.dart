import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trace_odd/features/marketplace_public/data/marketplace_cart.dart';
import 'package:trace_odd/features/marketplace_public/theme/marketplace_theme.dart';

/// The visitor's cart (item #13).
///
/// It prices what is in it and then hands over to the account door — because the
/// order itself belongs to a registered business, not to a browsing visitor.
class MarketplaceCartPage extends StatelessWidget {
  const MarketplaceCartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = MpCart.instance;

    return Scaffold(
      backgroundColor: MpColors.bg,
      appBar: AppBar(
        title: const Text(
          'Your cart',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
      ),
      body: ListenableBuilder(
        listenable: cart,
        builder: (context, _) {
          if (cart.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.shopping_cart_outlined,
                      size: 56,
                      color: MpColors.inkFaint,
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Your cart is empty',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: MpColors.ink,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Browse the marketplace and add what you need.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: MpColors.inkSoft),
                    ),
                    const SizedBox(height: 18),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: MpColors.indigo,
                      ),
                      onPressed: () => context.go('/'),
                      child: const Text('Browse products'),
                    ),
                  ],
                ),
              ),
            );
          }

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  for (final line in cart.lines) _line(context, cart, line),
                  const SizedBox(height: 8),
                  _totals(cart),
                  const SizedBox(height: 18),
                  _checkout(context),
                  const SizedBox(height: 10),
                  const Text(
                    'The marketplace does not sell to anonymous visitors. Your '
                    'cart is kept on this device, so you can register and come '
                    'back to it.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11.5, color: MpColors.inkFaint),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _line(BuildContext context, MpCart cart, MpCartLine line) {
    final canDecrease = line.qty > line.moq;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: MpColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 60,
                height: 60,
                child: line.imageUrl.isEmpty
                    ? _placeholder(line.name)
                    : Image.network(
                        line.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholder(line.name),
                      ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    line.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: MpColors.ink,
                    ),
                  ),
                  if (line.factoryName.isNotEmpty)
                    Text(
                      line.factoryName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: MpColors.inkSoft,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    '${line.currency} ${line.unitPrice.toStringAsFixed(2)} each'
                    '  ·  MOQ ${line.moq}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: MpColors.inkFaint,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _stepButton(
                        icon: Icons.remove,
                        enabled: canDecrease,
                        onTap: () => cart.setQty(line.productId, line.qty - 1),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          '${line.qty}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: MpColors.ink,
                          ),
                        ),
                      ),
                      _stepButton(
                        icon: Icons.add,
                        enabled: true,
                        onTap: () => cart.setQty(line.productId, line.qty + 1),
                      ),
                      const Spacer(),
                      Text(
                        '${line.currency} ${line.lineTotal.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: MpColors.coral,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Remove',
              onPressed: () => cart.remove(line.productId),
              icon: const Icon(Icons.close, size: 18, color: MpColors.inkFaint),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return Material(
      color: enabled ? MpColors.surfaceAlt : MpColors.bg,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 32,
          height: 32,
          child: Icon(
            icon,
            size: 17,
            color: enabled ? MpColors.ink : MpColors.inkFaint,
          ),
        ),
      ),
    );
  }

  Widget _totals(MpCart cart) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: MpColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            for (final currency in cart.currencies)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Subtotal ($currency)',
                        style: const TextStyle(color: MpColors.inkSoft),
                      ),
                    ),
                    Text(
                      '$currency ${cart.subtotalFor(currency).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: MpColors.ink,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 4),
            const Text(
              'Shipping, taxes and volume discounts are confirmed by the '
              'factory on the order itself.',
              style: TextStyle(fontSize: 11.5, color: MpColors.inkFaint),
            ),
          ],
        ),
      ),
    );
  }

  Widget _checkout(BuildContext context) {
    return SizedBox(
      height: 52,
      child: FilledButton.icon(
        style: FilledButton.styleFrom(
          backgroundColor: MpColors.coral,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () => context.go('/register'),
        icon: const Icon(Icons.storefront_outlined, size: 20),
        label: const Text(
          'Register / sign in to place the order',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  Widget _placeholder(String name) {
    return Container(
      decoration: const BoxDecoration(gradient: MpColors.placeholderGradient),
      alignment: Alignment.center,
      child: Text(
        name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase(),
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: MpColors.indigo,
        ),
      ),
    );
  }
}
