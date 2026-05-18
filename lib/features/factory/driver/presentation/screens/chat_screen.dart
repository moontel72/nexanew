import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:nexatrace_system/features/factory/driver/presentation/bloc/driver_bloc.dart';
import 'package:nexatrace_system/features/factory/driver/presentation/widgets/driver_feature_scaffold.dart';
import 'package:nexatrace_system/shared/theme/colors.dart';

class DriverChatScreen extends StatefulWidget {
  const DriverChatScreen({super.key});

  @override
  State<DriverChatScreen> createState() => _DriverChatScreenState();
}

class _DriverChatScreenState extends State<DriverChatScreen> {
  String? _activeConversationId;
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<DriverBloc>().add(const LoadConversations());
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _openConversation(String convId) {
    setState(() => _activeConversationId = convId);
    context.read<DriverBloc>().add(LoadMessages(conversationId: convId));
  }

  void _sendMessage() {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty || _activeConversationId == null) return;
    context.read<DriverBloc>().add(
      SendMessage(conversationId: _activeConversationId!, text: text),
    );
    _msgCtrl.clear();
  }

  void _attachFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );
    if (result?.files.isNotEmpty == true && _activeConversationId != null) {
      final fileName = result!.files.first.name;
      context.read<DriverBloc>().add(
        SendMessage(
          conversationId: _activeConversationId!,
          text: '📎 Attachment: $fileName',
        ),
      );
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DriverFeatureScaffold(
      title: _activeConversationId == null ? 'Chat' : 'Conversation',
      actions: _activeConversationId != null
          ? [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _activeConversationId = null),
              ),
            ]
          : null,
      child: _activeConversationId == null
          ? _buildConversationList()
          : _buildChatDetail(),
    );
  }

  Widget _buildConversationList() {
    return BlocBuilder<DriverBloc, DriverState>(
      builder: (context, state) {
        if (state is DriverLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is! MessagesLoaded) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 48.sp,
                  color: AppColors.gray400,
                ),
                SizedBox(height: 10.h),
                Text(
                  'No conversations yet',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          );
        }

        if (state.messages.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 48.sp,
                  color: AppColors.gray400,
                ),
                SizedBox(height: 10.h),
                Text(
                  'No conversations yet',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          );
        }

        final messages = state.messages;
        return ListView.separated(
          itemCount: messages.length,
          separatorBuilder: (_, __) => SizedBox(height: 10.h),
          itemBuilder: (context, index) {
            final msg = messages[index];
            final name = msg.senderId;
            final lastMsg = msg.message;
            final ts = msg.sentAt;
            final unread = msg.isRead ? 0 : 1;

            return InkWell(
              onTap: () => _openConversation(msg.chatId),
              borderRadius: BorderRadius.circular(12.r),
              child: Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: unread > 0
                      ? AppColors.primary.withOpacity(0.04)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: unread > 0
                        ? AppColors.primary.withOpacity(0.25)
                        : AppColors.border,
                  ),
                ),
                child: Row(
                  children: [
                    // Avatar
                    CircleAvatar(
                      radius: 24.r,
                      backgroundColor: AppColors.primary.withOpacity(0.12),
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : '?',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 18.sp,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ),
                              Text(
                                _formatTime(ts),
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4.h),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  lastMsg,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                              if (unread > 0) ...[
                                SizedBox(width: 8.w),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 7.w,
                                    vertical: 2.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  child: Text(
                                    '$unread',
                                    style: TextStyle(
                                      color: AppColors.white,
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildChatDetail() {
    return BlocBuilder<DriverBloc, DriverState>(
      builder: (context, state) {
        if (state is! MessagesLoaded) {
          return const Center(child: CircularProgressIndicator());
        }
        final messages = state.messages;

        // Auto-scroll
        _scrollToBottom();

        return Column(
          children: [
            // Messages area
            SizedBox(
              height: 450.h,
              child: messages.isEmpty
                  ? Center(
                      child: Text(
                        'No messages yet',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14.sp,
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollCtrl,
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final msg = messages[index];
                        final isSender = msg.senderId == 'driver';
                        final text = msg.message;
                        final ts = msg.sentAt;

                        return Padding(
                          padding: EdgeInsets.only(
                            left: isSender ? 60.w : 12.w,
                            right: isSender ? 12.w : 60.w,
                            bottom: 8.h,
                          ),
                          child: Column(
                            crossAxisAlignment: isSender
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 14.w,
                                  vertical: 10.h,
                                ),
                                decoration: BoxDecoration(
                                  color: isSender
                                      ? AppColors.primary
                                      : AppColors.gray100,
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(16),
                                    topRight: const Radius.circular(16),
                                    bottomLeft: Radius.circular(
                                      isSender ? 16 : 4,
                                    ),
                                    bottomRight: Radius.circular(
                                      isSender ? 4 : 16,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  text,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: isSender
                                        ? AppColors.white
                                        : AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                  top: 4.h,
                                  left: 4.w,
                                  right: 4.w,
                                ),
                                child: Text(
                                  _formatMessageTime(ts),
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            // Input bar
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.attach_file,
                      color: AppColors.textSecondary,
                      size: 22.sp,
                    ),
                    onPressed: _attachFile,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _msgCtrl,
                      style: TextStyle(fontSize: 14.sp),
                      decoration: InputDecoration(
                        hintText: 'Type a message…',
                        hintStyle: TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 14.sp,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24.r),
                          borderSide: BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24.r),
                          borderSide: BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24.r),
                          borderSide: BorderSide(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 10.h,
                        ),
                        isDense: true,
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.send_rounded,
                        color: AppColors.white,
                        size: 20.sp,
                      ),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MM/dd/yy').format(dt);
  }

  String _formatMessageTime(DateTime dt) {
    return DateFormat('h:mm a').format(dt);
  }
}
