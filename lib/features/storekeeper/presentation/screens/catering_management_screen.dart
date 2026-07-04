/// Catering Management Screen — Manage food/beverage items and categories.
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:trace_odd/features/storekeeper/presentation/screens/bundle_management_screen.dart';
import 'package:trace_odd/features/storekeeper/data/repositories/storekeeper_repository.dart';
import 'package:trace_odd/features/storekeeper/domain/models/catering_category.dart';
import 'package:trace_odd/features/storekeeper/domain/models/catering_item.dart';
import 'package:trace_odd/features/storekeeper/presentation/widgets/storekeeper_dialogs.dart';

class CateringManagementScreen extends StatefulWidget {
  final String? preselectedCategoryId;
  final String panel;

  const CateringManagementScreen({
    super.key,
    this.preselectedCategoryId,
    this.panel = 'bus-fleet',
  });

  @override
  State<CateringManagementScreen> createState() =>
      _CateringManagementScreenState();
}

class _CateringManagementScreenState extends State<CateringManagementScreen> {
  final _repo = StorekeeperRepository();
  List<CateringCategory> _categories = [];
  List<CateringItem> _items = [];
  Map<String, dynamic>? _itemMeta;
  String? _selectedCategoryId;
  bool _loading = true;
  String? _error;
  int _page = 1;
  String _search = '';
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.preselectedCategoryId != null) {
      _selectedCategoryId = widget.preselectedCategoryId;
    }
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final cats = await _repo.getCategories();
      final result = await _repo.getItems(
        categoryId: _selectedCategoryId,
        search: _search.isNotEmpty ? _search : null,
        page: _page,
      );
      if (mounted) {
        setState(() {
          _categories = cats;
          _items = result['items'] as List<CateringItem>;
          _itemMeta = result['meta'] as Map<String, dynamic>?;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _selectCategory(String? id) {
    setState(() {
      _selectedCategoryId = id;
      _page = 1;
    });
    _load();
  }

  Future<void> _createItem() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const CreateBundlePage()),
    );
    if (result == true) _load();
  }

  Future<void> _editItem(CateringItem item) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) =>
          CateringItemDialog(categories: _categories, existing: item),
    );
    if (result != null) {
      try {
        await _repo.updateItem(item.id, result);
        _load();
      } catch (e) {
        _showError(e.toString());
      }
    }
  }

  Future<void> _adjustStock(CateringItem item) async {
    final adjustment = await showDialog<int>(
      context: context,
      builder: (_) => StockAdjustDialog(item: item),
    );
    if (adjustment != null) {
      try {
        await _repo.adjustStock(item.id, adjustment);
        _load();
      } catch (e) {
        _showError(e.toString());
      }
    }
  }

  Future<void> _deleteItem(CateringItem item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1B2838),
        title: const Text('Delete Item', style: TextStyle(color: Colors.white)),
        content: Text(
          'Delete "${item.name}"?\nThis cannot be undone.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await _repo.deleteItem(item.id);
        _load();
      } catch (e) {
        _showError(e.toString());
      }
    }
  }

  void _showError(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;

    return Column(
      children: [
        // Search + Add bar
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Search items...',
                    hintStyle: const TextStyle(color: Colors.white38),
                    prefixIcon: const Icon(Icons.search, color: Colors.white38),
                    filled: true,
                    fillColor: const Color(0xFF1B2838),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  onSubmitted: (v) {
                    _search = v;
                    _page = 1;
                    _load();
                  },
                ),
              ),
              const Gap(8),
              IconButton(
                icon: const Icon(Icons.add_circle, color: Color(0xFF00B4D8)),
                tooltip: 'New Bundle',
                onPressed: _createItem,
              ),
            ],
          ),
        ),
        // Category chips
        SizedBox(
          height: 36.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _categories.length + 1,
            separatorBuilder: (_, __) => const Gap(6),
            itemBuilder: (_, i) {
              final isAll = i == 0;
              final cat = isAll ? null : _categories[i - 1];
              final selected = isAll
                  ? _selectedCategoryId == null
                  : _selectedCategoryId == cat!.id;
              return ChoiceChip(
                label: Text(
                  isAll ? 'All' : cat!.name,
                  style: TextStyle(
                    color: selected ? Colors.white : Colors.white70,
                    fontSize: 12,
                  ),
                ),
                selected: selected,
                selectedColor: const Color(0xFF00B4D8).withOpacity(0.3),
                backgroundColor: const Color(0xFF1B2838),
                side: BorderSide(
                  color: selected ? const Color(0xFF00B4D8) : Colors.white12,
                ),
                onSelected: (_) => _selectCategory(isAll ? null : cat!.id),
              );
            },
          ),
        ),
        const Gap(8),
        // Items list
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(
                  child: Text(
                    'Error: $_error',
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                )
              : _items.isEmpty
              ? const Center(
                  child: Text(
                    'No items found.',
                    style: TextStyle(color: Colors.white54),
                  ),
                )
              : _buildItemList(isWide),
        ),
        // Pagination
        if (_itemMeta != null) _buildPagination(),
      ],
    );
  }

  Widget _buildItemList(bool isWide) {
    if (isWide) {
      // Table layout for desktop
      return ListView(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Item',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'SKU',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Stock',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Price',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: Text(
                    '',
                    style: TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
          const Gap(4),
          ..._items.map((item) => _buildItemRow(item, isWide: true)),
        ],
      );
    }

    // Card layout for mobile
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: _items.length,
      separatorBuilder: (_, __) => const Gap(4),
      itemBuilder: (_, i) => _buildItemCard(_items[i]),
    );
  }

  Widget _buildItemRow(CateringItem item, {bool isWide = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2838),
        borderRadius: BorderRadius.circular(6),
        border: item.isLowStock
            ? Border.all(color: Colors.redAccent.withOpacity(0.5))
            : null,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (item.categoryName != null)
                  Text(
                    item.categoryName!,
                    style: const TextStyle(color: Colors.white38, fontSize: 11),
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              item.sku ?? '-',
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              children: [
                Icon(
                  item.isLowStock ? Icons.warning_amber : Icons.check_circle,
                  size: 14,
                  color: item.isLowStock ? Colors.orange : Colors.green,
                ),
                const Gap(4),
                Text(
                  '${item.stockOnHand}',
                  style: TextStyle(
                    color: item.isLowStock ? Colors.orange : Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'Rs. ${item.unitPriceInMain.toStringAsFixed(0)}',
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.add,
                  size: 16,
                  color: Colors.greenAccent,
                ),
                tooltip: 'Add stock',
                onPressed: () => _adjustStock(item),
                constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                padding: EdgeInsets.zero,
              ),
              IconButton(
                icon: const Icon(Icons.edit, size: 14, color: Colors.white54),
                tooltip: 'Edit',
                onPressed: () => _editItem(item),
                constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                padding: EdgeInsets.zero,
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  size: 14,
                  color: Colors.redAccent,
                ),
                tooltip: 'Delete',
                onPressed: () => _deleteItem(item),
                constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(CateringItem item) {
    return Card(
      color: const Color(0xFF1B2838),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            // Low stock indicator
            if (item.isLowStock)
              const Padding(
                padding: EdgeInsets.only(right: 6),
                child: Icon(
                  Icons.warning_amber,
                  color: Colors.orange,
                  size: 18,
                ),
              ),
            // Item info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const Gap(2),
                  Row(
                    children: [
                      if (item.categoryName != null) ...[
                        Text(
                          item.categoryName!,
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 11,
                          ),
                        ),
                        const Gap(8),
                      ],
                      Text(
                        'SKU: ${item.sku ?? '-'}',
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const Gap(4),
                  Row(
                    children: [
                      Text(
                        'Stock: ${item.stockOnHand}',
                        style: TextStyle(
                          color: item.isLowStock
                              ? Colors.orange
                              : Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Gap(12),
                      Text(
                        'Rs. ${item.unitPriceInMain.toStringAsFixed(0)} / ${item.unit}',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Actions
            PopupMenuButton<String>(
              color: const Color(0xFF1B2838),
              icon: const Icon(Icons.more_vert, color: Colors.white54),
              onSelected: (v) {
                switch (v) {
                  case 'adjust':
                    _adjustStock(item);
                    break;
                  case 'edit':
                    _editItem(item);
                    break;
                  case 'delete':
                    _deleteItem(item);
                    break;
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'adjust',
                  child: Text(
                    'Adjust Stock',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const PopupMenuItem(
                  value: 'edit',
                  child: Text('Edit', style: TextStyle(color: Colors.white)),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text(
                    'Delete',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPagination() {
    final current = (_itemMeta?['current_page'] ?? 1) as int;
    final last = (_itemMeta?['last_page'] ?? 1) as int;

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: Colors.white54),
            onPressed: current > 1
                ? () {
                    _page = current - 1;
                    _load();
                  }
                : null,
          ),
          Text(
            '$current / $last',
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: Colors.white54),
            onPressed: current < last
                ? () {
                    _page = current + 1;
                    _load();
                  }
                : null,
          ),
        ],
      ),
    );
  }
}
