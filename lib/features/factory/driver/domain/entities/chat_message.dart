import 'package:equatable/equatable.dart';

/// Chat message entity for driver communication
class ChatMessage extends Equatable {
  final String id;
  final String chatId;
  final String senderId;
  final String message;
  final String? attachmentUrl;
  final String? attachmentPath;
  final bool isRead;
  final DateTime sentAt;

  const ChatMessage({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.message,
    this.attachmentUrl,
    this.attachmentPath,
    this.isRead = false,
    required this.sentAt,
  });

  ChatMessage copyWith({
    String? id,
    String? chatId,
    String? senderId,
    String? message,
    String? attachmentUrl,
    String? attachmentPath,
    bool? isRead,
    DateTime? sentAt,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      message: message ?? this.message,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      attachmentPath: attachmentPath ?? this.attachmentPath,
      isRead: isRead ?? this.isRead,
      sentAt: sentAt ?? this.sentAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chat_id': chatId,
      'sender_id': senderId,
      'message': message,
      'attachment_url': attachmentUrl,
      'attachment_path': attachmentPath,
      'is_read': isRead,
      'sent_at': sentAt.toIso8601String(),
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      chatId: json['chat_id'] as String,
      senderId: json['sender_id'] as String,
      message: json['message'] as String? ?? '',
      attachmentUrl: json['attachment_url'] as String?,
      attachmentPath: json['attachment_path'] as String?,
      isRead: json['is_read'] as bool? ?? false,
      sentAt: json['sent_at'] != null
          ? DateTime.parse(json['sent_at'] as String)
          : DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    chatId,
    senderId,
    message,
    attachmentUrl,
    attachmentPath,
    isRead,
    sentAt,
  ];
}
