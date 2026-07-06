// Staff List Section — shared driver/conductor list widget
// Used by both Fleet and Owner dashboards.
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StaffListSection extends StatelessWidget {
  final String title;
  final Color accentColor;
  final IconData icon;
  final List<Map<String, dynamic>> items;
  final bool isLoading;
  final VoidCallback onAdd;
  final void Function(String id, String name) onRemove;
  final String emptyMessage;

  const StaffListSection({
    super.key,
    required this.title,
    required this.accentColor,
    required this.icon,
    required this.items,
    required this.isLoading,
    required this.onAdd,
    required this.onRemove,
    this.emptyMessage = 'No staff registered',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: Text(title, style: const TextStyle(color: Colors.white)),
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        actions: [IconButton(icon: const Icon(Icons.add), onPressed: onAdd)],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
          ? Center(
              child: Text(
                emptyMessage,
                style: const TextStyle(color: Color(0xFF8899AA)),
              ),
            )
          : ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(16.w),
              itemCount: items.length,
              separatorBuilder: (_, __) => SizedBox(height: 8.h),
              itemBuilder: (_, i) =>
                  _staffCard(items[i], accentColor, icon, onRemove),
            ),
    );
  }

  Widget _staffCard(
    Map<String, dynamic> s,
    Color accent,
    IconData icon,
    void Function(String id, String name) onRemove,
  ) {
    final name = s['name']?.toString() ?? '—';
    final phone = s['phone']?.toString();
    final license = s['license']?.toString() ?? s['license_number']?.toString();
    final id = s['id']?.toString() ?? '';
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      color: const Color(0xFF1A2A3A),
      child: Padding(
        padding: EdgeInsets.all(14.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: accent.withValues(alpha: .15),
              child: Icon(icon, color: accent),
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
                    ),
                  ),
                  if (phone != null && phone.isNotEmpty)
                    _chip(Icons.phone, phone),
                  if (license != null && license.isNotEmpty)
                    _chip(Icons.credit_card, license),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.redAccent,
                size: 20,
              ),
              tooltip: 'Remove',
              onPressed: () => onRemove(id, name),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(IconData ic, String txt) => Padding(
    padding: EdgeInsets.only(top: 4.h),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(ic, size: 12, color: const Color(0xFF667788)),
        SizedBox(width: 4.w),
        Text(
          txt,
          style: const TextStyle(color: Color(0xFF8899AA), fontSize: 11),
        ),
      ],
    ),
  );
}
