// Supabase Chat Service — Protected B2B messaging stream bridge
//
// Provides a clean, low-footprint client manager for the Reseller ↔ Factory
// encrypted chat channel (Step 12F).  All outgoing messages pass through
// the AIChatGuardViolationException pre-validation filter BEFORE dispatch,
// mirroring the backend AIChatLeakFilter middleware (Step 25).
//
// Architecture:
//   • Outbound: validate → send → ack
//   • Inbound:  receive → parse → stream to UI
//   • Pre-validation catches phone/email/@handle leaks client-side
//     for instant feedback without a server round-trip.
//
// The transport layer is abstracted — swap Supabase Realtime / WebSocket /
// Pusher by implementing `_sendFrame` and `_onFrame`.

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:trace_odd/core/network/network_exceptions.dart';

// ─────────────────────────────────────────────────────────────
// Message types
// ─────────────────────────────────────────────────────────────

/// Inbound or outbound chat message envelope.
class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime sentAt;
  final bool isOutgoing; // true = sent by current user
  final ChatMessageStatus status;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.sentAt,
    this.isOutgoing = false,
    this.status = ChatMessageStatus.sent,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    id: json['id']?.toString() ?? '',
    senderId: json['sender_id']?.toString() ?? '',
    senderName: json['sender_name']?.toString() ?? 'Unknown',
    content: json['content']?.toString() ?? '',
    sentAt:
        DateTime.tryParse(json['sent_at']?.toString() ?? '') ?? DateTime.now(),
    isOutgoing: json['is_outgoing'] == true,
    status: _statusFromString(json['status']?.toString()),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'sender_id': senderId,
    'sender_name': senderName,
    'content': content,
    'sent_at': sentAt.toIso8601String(),
    'is_outgoing': isOutgoing,
    'status': status.name,
  };
}

enum ChatMessageStatus { sending, sent, delivered, read, failed }

ChatMessageStatus _statusFromString(String? s) => switch (s) {
    'sending' => ChatMessageStatus.sending,
    'delivered' => ChatMessageStatus.delivered,
    'read' => ChatMessageStatus.read,
    'failed' => ChatMessageStatus.failed,
    _ => ChatMessageStatus.sent,
  };

// ─────────────────────────────────────────────────────────────
// Pre-validation filter (mirrors backend AIChatLeakFilter)
// ─────────────────────────────────────────────────────────────

/// Client-side regex patterns matching the backend AIChatLeakFilter (Step 25).
/// Catches violations BEFORE they hit the network — instant UI feedback.
class ChatLeakGuard {
  ChatLeakGuard._();

  // Pakistani / international phone patterns.
  static final RegExp _phonePak = RegExp(r'03\d{2}[-\s]?\d{7}');
  static final RegExp _phoneIntl = RegExp(r'\+92\s?\d{2}\s?\d{7}');
  static final RegExp _rawDigits = RegExp(r'\b\d{7,12}\b');

  // Email pattern.
  static final RegExp _email = RegExp(
    r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}',
  );

  // @username handle.
  static final RegExp _handle = RegExp(r'@\w{3,}');

  /// Validate [text] before dispatch.  Returns null if clean, or an
  /// [AIChatGuardViolationException] describing the first detected leak.
  static AIChatGuardViolationException? validate(String text) {
    // Phone — Pakistani mobile.
    final pakMatch = _phonePak.firstMatch(text);
    if (pakMatch != null) {
      return AIChatGuardViolationException(
        detectedPattern: pakMatch.group(0) ?? '',
        maskedPayload: _mask(text, pakMatch.start, pakMatch.end),
        leakType: 'phone',
        errors: {'message': 'Phone numbers are not allowed in chat'},
      );
    }

    // Phone — international.
    final intlMatch = _phoneIntl.firstMatch(text);
    if (intlMatch != null) {
      return AIChatGuardViolationException(
        detectedPattern: intlMatch.group(0) ?? '',
        maskedPayload: _mask(text, intlMatch.start, intlMatch.end),
        leakType: 'phone',
        errors: {'message': 'Phone numbers are not allowed in chat'},
      );
    }

    // Raw 7-12 digit numbers (likely a phone number without formatting).
    final digitsMatch = _rawDigits.firstMatch(text);
    if (digitsMatch != null) {
      return AIChatGuardViolationException(
        detectedPattern: digitsMatch.group(0) ?? '',
        maskedPayload: _mask(text, digitsMatch.start, digitsMatch.end),
        leakType: 'raw_number',
        errors: {'message': 'Sharing raw phone numbers is not allowed'},
      );
    }

    // Email.
    final emailMatch = _email.firstMatch(text);
    if (emailMatch != null) {
      return AIChatGuardViolationException(
        detectedPattern: emailMatch.group(0) ?? '',
        maskedPayload: _mask(text, emailMatch.start, emailMatch.end),
        leakType: 'email',
        errors: {'message': 'Email addresses are not allowed in chat'},
      );
    }

    // @handle.
    final handleMatch = _handle.firstMatch(text);
    if (handleMatch != null) {
      return AIChatGuardViolationException(
        detectedPattern: handleMatch.group(0) ?? '',
        maskedPayload: _mask(text, handleMatch.start, handleMatch.end),
        leakType: 'handle',
        errors: {'message': 'Social media handles are not allowed in chat'},
      );
    }

    return null; // Clean.
  }

  static String _mask(String text, int start, int end) {
    if (start < 0 || end > text.length || start >= end) return text;
    final before = text.substring(0, start);
    final after = text.substring(end);
    return '$before[REDACTED]$after';
  }
}

// ─────────────────────────────────────────────────────────────
// Supabase Chat Service
// ─────────────────────────────────────────────────────────────

class SupabaseChatService {
  final String _userId;
  final String _userName;

  final StreamController<ChatMessage> _incomingController =
      StreamController<ChatMessage>.broadcast();

  /// Callback invoked when the AI guard blocks a message.
  void Function(AIChatGuardViolationException)? onMessageBlocked;

  /// Callback invoked when a message fails to send.
  void Function(String messageId, String error)? onSendFailed;

  SupabaseChatService({
    required String channelId,
    required String userId,
    required String userName,
  }) : _userId = userId,
       _userName = userName;

  // ── Streams ───────────────────────────────────────────────

  /// Incoming messages from the channel.
  Stream<ChatMessage> get messages => _incomingController.stream;

  // ── Send with pre-validation ──────────────────────────────

  /// Send a message after passing the AI leak guard.
  /// Returns the message ID on success, or throws on guard violation.
  String send(String content) {
    // ── Pre-validation ───────────────────────────────────
    final violation = ChatLeakGuard.validate(content);
    if (violation != null) {
      onMessageBlocked?.call(violation);
      throw violation;
    }

    final message = ChatMessage(
      id: '${DateTime.now().millisecondsSinceEpoch}_$_userId',
      senderId: _userId,
      senderName: _userName,
      content: content,
      sentAt: DateTime.now(),
      isOutgoing: true,
      status: ChatMessageStatus.sending,
    );

    // Add to local stream immediately for optimistic UI.
    _incomingController.add(message);

    // Dispatch to transport.
    _sendFrame(message.toJson());

    return message.id;
  }

  // ── Receive ───────────────────────────────────────────────

  /// Feed an incoming frame from the transport layer.
  void receiveFrame(Map<String, dynamic> frame) {
    final message = ChatMessage.fromJson(frame);
    _incomingController.add(message);
  }

  /// Simulate receiving a message (for stub/testing).
  void simulateReceive(String content, String senderId, String senderName) {
    final message = ChatMessage(
      id: '${DateTime.now().millisecondsSinceEpoch}_$senderId',
      senderId: senderId,
      senderName: senderName,
      content: content,
      sentAt: DateTime.now(),
      isOutgoing: false,
    );
    _incomingController.add(message);
  }

  // ── Transport (abstracted — swap Supabase/WebSocket here) ──

  void _sendFrame(Map<String, dynamic> frame) {
    // Stub: log the frame.  Replace with Supabase Realtime channel push
    // or WebSocket frame dispatch when transport is wired.
    if (kDebugMode) {
      debugPrint('CHAT_SVC: Outgoing → ${jsonEncode(frame)}');
    }
  }

  void dispose() {
    _incomingController.close();
    onMessageBlocked = null;
    onSendFailed = null;
  }
}
