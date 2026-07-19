// Layout List Section — shared vehicle/layout list widget
// Used by both Fleet and Owner dashboards.
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class LayoutListSection extends StatelessWidget {
  final List<Map<String, dynamic>> layouts;
  final bool isLoading;
  final bool isMutating;
  final String emptyMessage;
  final void Function(String id, String name) onPublish;
  final void Function(String id, String name) onArchive;
  final void Function(String id, String name) onDelete;
  final void Function(String id, String name) onEdit;
  final VoidCallback onAdd;
  final VoidCallback? onPurgeAll;

  const LayoutListSection({
    super.key,
    required this.layouts,
    required this.isLoading,
    this.isMutating = false,
    this.emptyMessage = 'No vehicles yet',
    required this.onPublish,
    required this.onArchive,
    required this.onDelete,
    required this.onEdit,
    required this.onAdd,
    this.onPurgeAll,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());

    if (layouts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_seat,
              size: 48,
              color: Colors.white.withValues(alpha: .15),
            ),
            Gap(12),
            Text(
              emptyMessage,
              style: const TextStyle(color: Color(0xFF8899AA)),
            ),
            Gap(12),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Create Your First Layout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(16.w, 16.w, 16.w, 80.h),
          itemCount: layouts.length,
          itemBuilder: (_, i) {
            final l = layouts[i];
            final id = l['id']?.toString() ?? '';
            final name =
                l['display_name']?.toString() ??
                l['name']?.toString() ??
                'Unnamed';
            final status =
                l['layout_status']?.toString() ??
                l['status']?.toString() ??
                'draft';
            final seats =
                l['total_seats']?.toString() ??
                l['seat_count']?.toString() ??
                '—';
            final rowColInfo = _rowColInfo(l);
            // Per-type seat breakdown from snapshot components
            final seatBreakdown = _countByType(l);
            final updated =
                l['updated_at']?.toString() ??
                l['created_at']?.toString() ??
                '';
            final isPublished = status == 'published';
            final statusColor = isPublished
                ? const Color(0xFF16A34A)
                : const Color(0xFFF59E0B);

            return Card(
              color: const Color(0xFF1A2A3A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              margin: EdgeInsets.only(bottom: 10.h),
              child: Padding(
                padding: EdgeInsets.all(14.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: const Color(
                            0xFF2563EB,
                          ).withValues(alpha: .15),
                          child: const Icon(
                            Icons.directions_bus,
                            color: Color(0xFF2563EB),
                            size: 20,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                updated.isNotEmpty ? 'Updated $updated' : '',
                                style: const TextStyle(
                                  color: Color(0xFF667788),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: .15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            status.toUpperCase(),
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        if (seatBreakdown.isNotEmpty)
                          ...seatBreakdown.entries.map((e) => Padding(
                            padding: EdgeInsets.only(right: 12.w),
                            child: _chip(_iconForType(e.key), '${e.value} ${e.key}'),
                        if (rowColInfo.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.only(right: 12.w),
                            child: _chip(Icons.table_rows, rowColInfo),
                          ),
                          )),
                        if (seatBreakdown.isEmpty)
                          _chip(Icons.event_seat, '$seats seats'),
                      ],
                    ),
                    Gap(10),
                    Row(
                      children: [
                        Expanded(
                          child: _btn(
                            'Edit',
                            Icons.edit,
                            const Color(0xFF2563EB),
                            isMutating ? null : () => onEdit(id, name),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        if (!isPublished)
                          Expanded(
                            child: _btn(
                              'Publish',
                              Icons.publish,
                              const Color(0xFF16A34A),
                              isMutating ? null : () => onPublish(id, name),
                            ),
                          ),
                        if (!isPublished) SizedBox(width: 8.w),
                        Expanded(
                          child: _btn(
                            'Archive',
                            Icons.archive,
                            const Color(0xFFF59E0B),
                            isMutating ? null : () => onArchive(id, name),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: _btn(
                            'Delete',
                            Icons.delete_outline,
                            Colors.redAccent,
                            isMutating ? null : () => onDelete(id, name),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        if (onPurgeAll != null)
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton.extended(
              onPressed: isMutating ? null : onPurgeAll,
              icon: const Icon(Icons.delete_sweep),
              label: const Text('Purge All'),
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
          ),
      ],
    );
  }

  Widget _chip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: const Color(0xFF667788)),
        SizedBox(width: 4.w),
        Text(
          label,
          style: const TextStyle(color: Color(0xFF8899AA), fontSize: 11),
        ),
      ],
    );
  }

  Widget _btn(String label, IconData icon, Color color, VoidCallback? onTap) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 14),
      label: Text(label, style: const TextStyle(fontSize: 11)),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withValues(alpha: .5)),
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
  /// Parse current_snapshot components and count by readable type.
  static Map<String, int> _countByType(Map<String, dynamic> layout) {
    final result = <String, int>{};
    // current_snapshot may be a Map or a JSON string from DB
    dynamic snap = layout['current_snapshot'];
    if (snap is String) {
      try { snap = jsonDecode(snap); } catch (_) { snap = null; }
    }
    final comps = (snap is Map ? snap['components'] : null) ?? layout['components'];
    // debugPrint('COUNT: found ${comps is List ? comps.length : 0} components');
    if (comps is! List) return result;
    // Structural types that should never be counted as seats
    const structural = {
      'driverCabin', 'exitDoor', 'sideDoor', 'slidingDoor',
      'frontDoor', 'rearDoor', 'aisle', 'emergency',
      'lavatory', 'restaurantTable', 'empty',
    };
    for (final c in comps) {
      if (c is! Map) continue;
      final type = c['type']?.toString() ?? '';
      if (structural.contains(type)) continue;
      // Skip non-bookable components
      final bookable = c['bookable'];
      if (bookable == false || bookable == 'false') continue;
      // Custom-labelled seats (e.g. VIP) get their own category
      final customLabel = c['custom_label']?.toString();
      if (customLabel != null && customLabel.isNotEmpty) {
        result[customLabel] = (result[customLabel] ?? 0) + 1;
        continue;
      }
      final label = switch (type) {
        'seat' => 'Seats',
        'sleeperLower' => 'Low.Berth',
        'sleeperUpper' => 'Upp.Berth',
        'businessClassSeat' => 'Business',
        'foldingSeat' => 'Folding',
        _ => null,
      };
      if (label != null) result[label] = (result[label] ?? 0) + 1;
    }
n  /// Count unique rows and seats-per-side from component positions.
  static String _rowColInfo(Map<String, dynamic> layout) {
    final snap = layout['current_snapshot'];
    var comps = (snap is Map ? snap['components'] : null) ?? layout['components'];
    if (snap is String) {
      try { final s = jsonDecode(snap); comps = s is Map ? s['components'] : null; } catch (_) {}
    }
    if (comps is! List || comps.isEmpty) return '';
    // Collect seat positions (skip structural)
    final rows = <double>{};
    final structural = {'driverCabin', 'exitDoor', 'sideDoor', 'slidingDoor', 'frontDoor', 'rearDoor', 'aisle', 'emergency', 'lavatory', 'restaurantTable', 'empty'};
    double minX = double.infinity, maxX = 0;
    for (final c in comps) {
      if (c is! Map) continue;
      final t = c['type']?.toString() ?? '';
      if (structural.contains(t)) continue;
      final y = (c['y'] as num?)?.toDouble();
      final x = (c['x'] as num?)?.toDouble();
      if (y != null) rows.add(y);
      if (x != null) { if (x < minX) minX = x; if (x > maxX) maxX = x; }
    }
    if (rows.isEmpty) return '';
    // Estimate cols from X spread (rough)
    final colEstimate = maxX > minX ? ((maxX - minX) / 50).round().clamp(1, 6) : 1;
    return '${rows.length}R x ~${colEstimate}C';
  }
    return result;
  }

  static IconData _iconForType(String label) => switch (label) {
    'Seats' => Icons.event_seat,
    'Low.Berth' || 'Upp.Berth' => Icons.airline_seat_flat,
    'Business' => Icons.airline_seat_flat_angled,
    'Folding' => Icons.chair_alt,
    _ => Icons.label_important,
  };
}
