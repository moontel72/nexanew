/// Catering Management Screen — BLoC-driven (P1 wired)
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trace_odd/features/storekeeper/presentation/bloc/storekeeper_bloc.dart';
import 'package:trace_odd/features/storekeeper/presentation/bloc/storekeeper_event.dart';
import 'package:trace_odd/features/storekeeper/presentation/bloc/storekeeper_state.dart';

class CateringManagementScreen extends StatelessWidget {
  final String? preselectedCategoryId;
  final String panel;

  const CateringManagementScreen({
    super.key,
    this.preselectedCategoryId,
    this.panel = 'bus-fleet',
  });

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<StorekeeperDashboardBloc>();
    return BlocBuilder<StorekeeperDashboardBloc, StorekeeperDashboardState>(
      builder: (ctx, state) {
        final categories = state.categories;
        final items = state.items;
        final selId = state.selectedCategoryId ?? preselectedCategoryId;

        return Column(
          children: [
            // Category chips
            SizedBox(
              height: 50,
              child: categories.isEmpty && !state.bundlesLoading
                  ? const Center(
                      child: Text(
                        'No categories',
                        style: TextStyle(color: Colors.white54),
                      ),
                    )
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      itemCount: categories.length + 1,
                      itemBuilder: (_, i) {
                        if (i == 0) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: const Text(
                                'All',
                                style: TextStyle(color: Colors.white),
                              ),
                              selected: selId == null,
                              selectedColor: const Color(0xFF00B4D8),
                              backgroundColor: const Color(0xFF1B2838),
                              onSelected: (_) => bloc.add(
                                LoadItems(panel: panel, categoryId: null),
                              ),
                            ),
                          );
                        }
                        final cat = categories[i - 1];
                        final catId =
                            ((cat is Map)
                                ? cat['id']?.toString()
                                : cat.id.toString()) ??
                            '';
                        final catName =
                            ((cat is Map)
                                ? cat['name']?.toString()
                                : cat.name.toString()) ??
                            'Category';
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(
                              catName,
                              style: const TextStyle(color: Colors.white),
                            ),
                            selected: selId == catId,
                            selectedColor: const Color(0xFF00B4D8),
                            backgroundColor: const Color(0xFF1B2838),
                            onSelected: (_) => bloc.add(
                              LoadItems(panel: panel, categoryId: catId),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            Expanded(
              child: state.bundlesLoading
                  ? const Center(child: CircularProgressIndicator())
                  : state.error != null
                  ? Center(
                      child: Text(
                        'Error: ${state.error}',
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    )
                  : items.isEmpty
                  ? const Center(
                      child: Text(
                        'No items',
                        style: TextStyle(color: Colors.white54),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: items.length,
                      itemBuilder: (_, i) {
                        final item = items[i];
                        final name =
                            ((item is Map)
                                ? item['name']?.toString()
                                : item.name.toString()) ??
                            'Item';
                        final stock = (item is Map)
                            ? (item['stock'] ?? 0)
                            : item.stock;
                        return Card(
                          color: const Color(0xFF1B2838),
                          margin: const EdgeInsets.only(bottom: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Color(0x2000B4D8),
                              child: Icon(
                                Icons.fastfood,
                                color: Color(0xFF00B4D8),
                                size: 18,
                              ),
                            ),
                            title: Text(
                              name,
                              style: const TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              'Stock: $stock',
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
