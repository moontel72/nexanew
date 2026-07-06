// Fleet Carrier Link Section — bus-fleet inbound requests + linked carriers
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class FleetCarrierLinkSection extends StatelessWidget {
  final List<Map<String, dynamic>> incomingRequests;
  final List<Map<String, dynamic>> linkedCarriers;
  final bool isLoading;
  final void Function(String id) onAccept;
  final void Function(String id) onReject;
  final void Function(String id, String name) onUnlink;

  const FleetCarrierLinkSection({
    super.key,
    required this.incomingRequests,
    required this.linkedCarriers,
    required this.isLoading,
    required this.onAccept,
    required this.onReject,
    required this.onUnlink,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(16.w),
      children: [
        // ── Section 1: Incoming Requests ──
        _sectionTitle(
          'Incoming Link Requests',
          'Third-party owners requesting to join your fleet.',
        ),
        Gap(12),
        if (incomingRequests.isEmpty)
          _empty('No pending requests', Icons.inbox_outlined)
        else
          ...incomingRequests.map(_incomingCard),

        Gap(32),

        // ── Section 2: Linked Carriers ──
        _sectionTitle(
          'Linked Carriers',
          'Owners currently connected to your fleet.',
        ),
        Gap(12),
        if (linkedCarriers.isEmpty)
          _empty('No linked carriers', Icons.link_off_rounded)
        else
          ...linkedCarriers.map(_linkedCard),
      ],
    );
  }

  Widget _sectionTitle(String title, String subtitle) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
      Gap(4),
      Text(
        subtitle,
        style: const TextStyle(color: Color(0xFF8899AA), fontSize: 12),
      ),
    ],
  );

  Widget _empty(String msg, IconData icon) => Container(
    width: double.infinity,
    padding: EdgeInsets.all(32.w),
    decoration: BoxDecoration(
      color: const Color(0xFF1A2A3A),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      children: [
        Icon(icon, size: 36, color: const Color(0xFF556677)),
        Gap(8),
        Text(
          msg,
          style: const TextStyle(color: Color(0xFF667788), fontSize: 13),
        ),
      ],
    ),
  );

  Widget _incomingCard(Map<String, dynamic> req) {
    final name = req['owner_name']?.toString() ?? '—';
    final email = req['email']?.toString() ?? '';
    final id = req['id']?.toString() ?? '';
    final at = req['created_at']?.toString() ?? '';
    return Card(
      color: const Color(0xFF1A2A3A),
      margin: EdgeInsets.only(bottom: 8.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: EdgeInsets.all(14.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(
                    0xFFF59E0B,
                  ).withValues(alpha: .15),
                  child: const Icon(
                    Icons.person,
                    color: Color(0xFFF59E0B),
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
                        ),
                      ),
                      if (email.isNotEmpty)
                        Text(
                          email,
                          style: const TextStyle(
                            color: Color(0xFF667788),
                            fontSize: 11,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            Gap(10),
            Text(
              'Requested: $at',
              style: const TextStyle(color: Color(0xFF556677), fontSize: 11),
            ),
            Gap(10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => onAccept(id),
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Accept'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16A34A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => onReject(id),
                    icon: const Icon(Icons.close, size: 16),
                    label: const Text('Reject'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(color: Colors.redAccent),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _linkedCard(Map<String, dynamic> c) {
    final name = c['owner_name']?.toString() ?? '—';
    final drivers = c['driver_count'] ?? 0;
    final conductors = c['conductor_count'] ?? 0;
    final buses = c['bus_count'] ?? 0;
    final since = c['linked_since']?.toString() ?? '';
    final id = c['assignment_id']?.toString() ?? '';
    return Card(
      color: const Color(0xFF1A2A3A),
      margin: EdgeInsets.only(bottom: 8.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: EdgeInsets.all(14.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(
                    0xFF16A34A,
                  ).withValues(alpha: .15),
                  child: const Icon(
                    Icons.directions_bus,
                    color: Color(0xFF16A34A),
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
                        ),
                      ),
                      Text(
                        'Active · Since $since',
                        style: const TextStyle(
                          color: Color(0xFF667788),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: () => onUnlink(id, name),
                  icon: const Icon(Icons.link_off, size: 14),
                  label: const Text('Unlink', style: TextStyle(fontSize: 11)),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                  ),
                ),
              ],
            ),
            Gap(10),
            Row(
              children: [
                _chip('$drivers Drivers', Icons.badge),
                SizedBox(width: 10.w),
                _chip('$conductors Conductors', Icons.group),
                SizedBox(width: 10.w),
                _chip('$buses Buses', Icons.directions_bus),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, IconData icon) => Container(
    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
    decoration: BoxDecoration(
      color: const Color(0xFF0D1B2A),
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: const Color(0xFF2A3A4A)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: const Color(0xFF667788)),
        SizedBox(width: 4.w),
        Text(
          label,
          style: const TextStyle(color: Color(0xFF8899AA), fontSize: 11),
        ),
      ],
    ),
  );
}
