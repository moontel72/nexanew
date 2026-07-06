// Chat Inbox Section — messaging panel for fleet dashboard
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class ChatInboxSection extends StatelessWidget {
  final List<Map<String, dynamic>> conversations;
  final List<Map<String, dynamic>> activeMessages;
  final bool isLoading;
  final bool isSending;
  final String? expandedId;
  final String? error;
  final void Function(String id) onExpand;
  final void Function(String id, String msg) onSend;

  const ChatInboxSection({
    super.key,
    required this.conversations,
    required this.activeMessages,
    required this.isLoading,
    required this.isSending,
    this.expandedId,
    this.error,
    required this.onExpand,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(16.w),
      children: [
        const Text(
          'Inbox',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        Gap(4),
        const Text(
          'Messages from linked carriers and system notifications.',
          style: TextStyle(color: Color(0xFF8899AA), fontSize: 12),
        ),
        Gap(12),
        if (error != null)
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.redAccent.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              error!,
              style: const TextStyle(color: Colors.redAccent, fontSize: 12),
            ),
          ),
        if (conversations.isEmpty)
          _empty('No messages', Icons.message_outlined)
        else
          ...conversations.map(_convCard),
      ],
    );
  }

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

  Widget _convCard(Map<String, dynamic> conv) {
    final aid = conv['id']?.toString() ?? '';
    final name = conv['owner_name']?.toString() ?? 'Owner';
    final latest = conv['latest_body']?.toString() ?? '';
    final time = conv['latest_at']?.toString() ?? '';
    final isExpanded = expandedId == aid;

    return Card(
      color: const Color(0xFF1A2A3A),
      margin: EdgeInsets.only(bottom: 10.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: InkWell(
        onTap: () => onExpand(aid),
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(14.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(
                      0xFF0D9488,
                    ).withValues(alpha: .15),
                    child: const Icon(
                      Icons.business,
                      color: Color(0xFF0D9488),
                      size: 18,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (time.isNotEmpty)
                    Text(
                      time,
                      style: const TextStyle(
                        color: Color(0xFF556677),
                        fontSize: 10,
                      ),
                    ),
                ],
              ),
              if (latest.isNotEmpty) ...[
                Gap(6),
                Text(
                  latest,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF8899AA),
                    fontSize: 12,
                  ),
                ),
              ],

              // ── Expanded: message thread + reply ──
              if (isExpanded) ...[
                Gap(10),
                const Divider(color: Color(0xFF2A3A4A), height: 1),
                Gap(10),
                if (activeMessages.isEmpty)
                  const Text(
                    'No messages yet.',
                    style: TextStyle(color: Color(0xFF667788), fontSize: 11),
                  )
                else
                  Container(
                    constraints: BoxConstraints(maxHeight: 250.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F1B2A),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.all(10.w),
                      itemCount: activeMessages.length,
                      itemBuilder: (_, i) {
                        final m = activeMessages[i];
                        final body = m['message_body']?.toString() ?? '';
                        final ctx = m['context_type']?.toString() ?? 'general';
                        final clr = ctx == 'rejection_reason'
                            ? Colors.red
                            : const Color(0xFF8899AA);
                        return Padding(
                          padding: EdgeInsets.only(bottom: 6.h),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 5.w,
                                  vertical: 1.h,
                                ),
                                decoration: BoxDecoration(
                                  color: clr.withValues(alpha: .2),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: Text(
                                  ctx.replaceAll('_', ' ').toUpperCase(),
                                  style: TextStyle(
                                    color: clr,
                                    fontSize: 8,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  body,
                                  style: const TextStyle(
                                    color: Color(0xFFCCCCCC),
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                // Reply bar
                Gap(8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: const TextStyle(color: Color(0xFF556677)),
                          filled: true,
                          fillColor: const Color(0xFF0F1B2A),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 10.h,
                          ),
                        ),
                        onSubmitted: (v) {
                          if (v.trim().isNotEmpty) onSend(aid, v.trim());
                        },
                      ),
                    ),
                    SizedBox(width: 8.w),
                    IconButton(
                      icon: isSending
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(
                              Icons.send_rounded,
                              color: Color(0xFF0D9488),
                            ),
                      onPressed: () {}, // handled by onSubmitted
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
