class Conversation {
  final int id;
  final String subject;
  final int unreadCount;
  final String? lastBody;
  final String? lastSender;
  final String? lastTime;

  Conversation({
    required this.id,
    required this.subject,
    this.unreadCount = 0,
    this.lastBody,
    this.lastSender,
    this.lastTime,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    final last = json['last_message'];
    Map<String, dynamic>? lastMsg;
    if (last is Map<String, dynamic>) {
      lastMsg = last;
    }
    final sender = lastMsg?['sender'];
    return Conversation(
      id: json['id'] as int,
      subject: json['subject'] as String? ?? 'Chat',
      unreadCount: (json['unread_count'] as int?) ?? 0,
      lastBody: lastMsg?['body'] as String?,
      lastSender: sender is Map<String, dynamic> ? sender['first_name'] as String? : null,
      lastTime: lastMsg?['created_at'] as String?,
    );
  }
}

class ChatMessage {
  final int id;
  final int conversationId;
  final int senderId;
  final String body;
  final bool isRead;
  final String createdAt;
  final String? senderName;

  ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.body,
    this.isRead = false,
    required this.createdAt,
    this.senderName,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final sender = json['sender'];
    return ChatMessage(
      id: json['id'] as int,
      conversationId: json['conversation_id'] as int,
      senderId: json['sender_id'] as int,
      body: json['body'] as String,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: json['created_at'] as String,
      senderName: sender is Map<String, dynamic> ? (sender['first_name'] as String? ?? 'User') : 'User',
    );
  }
}