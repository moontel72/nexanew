import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// One line in the public marketplace cart.
class MpCartLine {
  MpCartLine({
    required this.productId,
    required this.name,
    required this.factoryName,
    required this.factoryId,
    required this.currency,
    required this.unitPrice,
    required this.moq,
    required this.qty,
    this.imageUrl = '',
  });

  final String productId;
  final String name;
  final String factoryName;
  final String factoryId;
  final String currency;
  final double unitPrice;
  final int moq;
  final String imageUrl;
  int qty;

  double get lineTotal => unitPrice * qty;

  Map<String, dynamic> toJson() => {
    'product_id': productId,
    'name': name,
    'factory_name': factoryName,
    'factory_id': factoryId,
    'currency': currency,
    'unit_price': unitPrice,
    'moq': moq,
    'qty': qty,
    'image_url': imageUrl,
  };

  static MpCartLine? fromJson(Map<String, dynamic> json) {
    final id = json['product_id']?.toString();
    if (id == null || id.isEmpty) return null;
    return MpCartLine(
      productId: id,
      name: json['name']?.toString() ?? 'Product',
      factoryName: json['factory_name']?.toString() ?? '',
      factoryId: json['factory_id']?.toString() ?? '',
      currency: json['currency']?.toString() ?? 'PKR',
      unitPrice: (json['unit_price'] is num)
          ? (json['unit_price'] as num).toDouble()
          : double.tryParse('${json['unit_price'] ?? ''}') ?? 0,
      moq: (json['moq'] is num)
          ? (json['moq'] as num).toInt()
          : int.tryParse('${json['moq'] ?? ''}') ?? 1,
      qty: (json['qty'] is num)
          ? (json['qty'] as num).toInt()
          : int.tryParse('${json['qty'] ?? ''}') ?? 1,
      imageUrl: json['image_url']?.toString() ?? '',
    );
  }
}

/// The public marketplace's cart (MASTER-TASK-LIST item #13).
///
/// Browsing needs no account, but a cart that dies on refresh would make the
/// "register to buy" hand-off useless — the visitor registers in a new tab and
/// comes back. So the cart is persisted in the browser (localStorage via
/// shared_preferences) and is the ONLY state this site keeps.
///
/// It deliberately does not place an order: creating an order needs an
/// authenticated reseller (`POST /reseller/orders`), and that is the account
/// door this cart hands over to.
class MpCart extends ChangeNotifier {
  MpCart._();

  static final MpCart instance = MpCart._();

  static const _storageKey = 'mp_cart_v1';

  final List<MpCartLine> lines = [];
  bool _loaded = false;

  bool get isLoaded => _loaded;

  int get itemCount => lines.fold(0, (sum, l) => sum + l.qty);

  bool get isEmpty => lines.isEmpty;

  /// Currencies present in the cart (a cart may mix them; they are totalled apart).
  List<String> get currencies {
    final set = <String>{for (final l in lines) l.currency};
    return set.toList()..sort();
  }

  double subtotalFor(String currency) => lines
      .where((l) => l.currency == currency)
      .fold(0, (sum, l) => sum + l.lineTotal);

  /// Loads the persisted cart once. Safe to call from every page.
  Future<void> ensureLoaded() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          lines
            ..clear()
            ..addAll(
              decoded
                  .whereType<Map>()
                  .map((e) => MpCartLine.fromJson(e.cast<String, dynamic>()))
                  .whereType<MpCartLine>(),
            );
        }
      }
    } catch (_) {
      // A corrupt cart must never block the site — start empty.
    }
    _loaded = true;
    notifyListeners();
  }

  /// Adds a product, or raises its quantity. The first add starts at the MOQ,
  /// because that is the smallest order the factory accepts.
  Future<void> add({
    required String productId,
    required String name,
    required String factoryName,
    required String factoryId,
    required String currency,
    required double unitPrice,
    required int moq,
    required String imageUrl,
    int? quantity,
  }) async {
    await ensureLoaded();
    final minQty = moq < 1 ? 1 : moq;

    final existing = lines.indexWhere((l) => l.productId == productId);
    if (existing >= 0) {
      lines[existing].qty += quantity ?? minQty;
    } else {
      lines.add(
        MpCartLine(
          productId: productId,
          name: name,
          factoryName: factoryName,
          factoryId: factoryId,
          currency: currency,
          unitPrice: unitPrice,
          moq: minQty,
          qty: quantity ?? minQty,
          imageUrl: imageUrl,
        ),
      );
    }

    notifyListeners();
    await _persist();
  }

  /// Sets an absolute quantity, never below the line's MOQ.
  Future<void> setQty(String productId, int qty) async {
    final i = lines.indexWhere((l) => l.productId == productId);
    if (i < 0) return;
    final minQty = lines[i].moq;
    lines[i].qty = qty < minQty ? minQty : qty;
    notifyListeners();
    await _persist();
  }

  Future<void> remove(String productId) async {
    lines.removeWhere((l) => l.productId == productId);
    notifyListeners();
    await _persist();
  }

  Future<void> clear() async {
    lines.clear();
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _storageKey,
        jsonEncode(lines.map((l) => l.toJson()).toList()),
      );
    } catch (_) {
      // Persistence is best-effort; the in-memory cart still works.
    }
  }
}
