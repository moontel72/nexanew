/// Dialogs for StoreKeeper operations — item creation/editing, stock adjustments.
library;

import 'package:flutter/material.dart';
import 'package:trace_odd/features/storekeeper/domain/models/catering_category.dart';
import 'package:trace_odd/features/storekeeper/domain/models/catering_item.dart';

/// Dialog for creating or editing a catering item.
class CateringItemDialog extends StatefulWidget {
  final List<CateringCategory> categories;
  final CateringItem? existing;

  const CateringItemDialog({
    super.key,
    required this.categories,
    this.existing,
  });

  @override
  State<CateringItemDialog> createState() => _CateringItemDialogState();
}

class _CateringItemDialogState extends State<CateringItemDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _skuCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _thresholdCtrl;
  late final TextEditingController _stockCtrl;
  late final TextEditingController _unitCtrl;
  String? _categoryId;
  String _status = 'active';

  bool get isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _skuCtrl = TextEditingController(text: e?.sku ?? '');
    _priceCtrl = TextEditingController(
      text: ((e?.unitPricePaisa ?? 0) / 100).toStringAsFixed(2),
    );
    _thresholdCtrl = TextEditingController(
      text: (e?.lowStockThreshold ?? 10).toString(),
    );
    _stockCtrl = TextEditingController(text: (e?.stockOnHand ?? 0).toString());
    _unitCtrl = TextEditingController(text: e?.unit ?? 'piece');
    _categoryId = e?.categoryId;
    _status = e?.status ?? 'active';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _skuCtrl.dispose();
    _priceCtrl.dispose();
    _thresholdCtrl.dispose();
    _stockCtrl.dispose();
    _unitCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.pop(context, {
      'name': _nameCtrl.text.trim(),
      'sku': _skuCtrl.text.trim().isEmpty ? null : _skuCtrl.text.trim(),
      'unit': _unitCtrl.text.trim().isEmpty ? 'piece' : _unitCtrl.text.trim(),
      'unit_price_paisa': ((double.tryParse(_priceCtrl.text) ?? 0) * 100)
          .round(),
      'low_stock_threshold': int.tryParse(_thresholdCtrl.text) ?? 10,
      'stock_on_hand': int.tryParse(_stockCtrl.text) ?? 0,
      'status': _status,
      if (_categoryId != null) 'category_id': _categoryId,
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1B2838),
      title: Text(
        isEditing ? 'Edit Item' : 'Add Item',
        style: const TextStyle(color: Colors.white),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _field(
                'Name *',
                _nameCtrl,
                hint: 'e.g. Lays Chips',
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 10),
              _field('SKU (optional)', _skuCtrl, hint: 'e.g. LAY-001'),
              const SizedBox(height: 10),
              _field(
                'Price',
                _priceCtrl,
                hint: 'e.g. 50.00',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              _field(
                'Low Stock Threshold',
                _thresholdCtrl,
                hint: 'e.g. 10',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              _field(
                isEditing ? 'Stock On Hand' : 'Initial Stock',
                _stockCtrl,
                hint: 'e.g. 100',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              // Category dropdown
              DropdownButtonFormField<String>(
                value: _categoryId,
                dropdownColor: const Color(0xFF1B2838),
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: _dec('Category'),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text(
                      'None',
                      style: TextStyle(color: Colors.white54),
                    ),
                  ),
                  ...widget.categories.map(
                    (c) => DropdownMenuItem(
                      value: c.id,
                      child: Text(
                        c.name,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
                onChanged: (v) => setState(() => _categoryId = v),
              ),
              const SizedBox(height: 10),
              // Status
              DropdownButtonFormField<String>(
                value: _status,
                dropdownColor: const Color(0xFF1B2838),
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: _dec('Status'),
                items: const [
                  DropdownMenuItem(
                    value: 'active',
                    child: Text(
                      'Active',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'discontinued',
                    child: Text(
                      'Discontinued',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
                onChanged: (v) => setState(() => _status = v!),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00B4D8),
          ),
          onPressed: _submit,
          child: Text(
            isEditing ? 'Save' : 'Create',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _field(
    String label,
    TextEditingController ctrl, {
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    String? hint,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white, fontSize: 13),
      decoration: _dec(label).copyWith(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white30, fontSize: 12),
      ),
      validator: validator,
    );
  }

  InputDecoration _dec(String label) => InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: Colors.white54, fontSize: 12),
    filled: true,
    fillColor: const Color(0xFF0D1B2A),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: BorderSide.none,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    isDense: true,
  );
}

/// Dialog for adjusting stock quantity of an item.
class StockAdjustDialog extends StatefulWidget {
  final CateringItem item;

  const StockAdjustDialog({super.key, required this.item});

  @override
  State<StockAdjustDialog> createState() => _StockAdjustDialogState();
}

class _StockAdjustDialogState extends State<StockAdjustDialog> {
  final _qtyCtrl = TextEditingController();
  final _reasonCtrl = TextEditingController();
  bool _add = true;

  @override
  void dispose() {
    _qtyCtrl.dispose();
    _reasonCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final qty = int.tryParse(_qtyCtrl.text) ?? 0;
    if (qty <= 0) return;

    Navigator.pop(context, _add ? qty : -qty);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1B2838),
      title: Text(
        'Adjust Stock — ${widget.item.name}',
        style: const TextStyle(color: Colors.white, fontSize: 15),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Current stock: ${widget.item.stockOnHand} ${widget.item.unit}',
            style: const TextStyle(color: Colors.white54, fontSize: 13),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ChoiceChip(
                label: const Text(
                  'Add',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
                selected: _add,
                selectedColor: Colors.green.withOpacity(0.3),
                backgroundColor: const Color(0xFF0D1B2A),
                onSelected: (_) => setState(() => _add = true),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text(
                  'Remove',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
                selected: !_add,
                selectedColor: Colors.redAccent.withOpacity(0.3),
                backgroundColor: const Color(0xFF0D1B2A),
                onSelected: (_) => setState(() => _add = false),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _qtyCtrl,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Quantity',
              hintStyle: const TextStyle(color: Colors.white38),
              filled: true,
              fillColor: const Color(0xFF0D1B2A),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _reasonCtrl,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Reason (optional)',
              hintStyle: const TextStyle(color: Colors.white38),
              filled: true,
              fillColor: const Color(0xFF0D1B2A),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _add ? Colors.green : Colors.redAccent,
          ),
          onPressed: _submit,
          child: Text(
            _add ? 'Add Stock' : 'Remove Stock',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
