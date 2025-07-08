abstract class ChatEvent {}

// Fetch conversations
class FetchConversationsEvent extends ChatEvent {
  final String userId;
  FetchConversationsEvent(this.userId);
}

// Fetch messages for a conversation
class FetchMessagesEvent extends ChatEvent {
  final String conversationId;
  final String userId;
  FetchMessagesEvent(this.conversationId, this.userId);
}

// Send message
class SendMessageEvent extends ChatEvent {
  final String senderId;
  final String receiverId;
  final String content;
  final String messageType;

  SendMessageEvent({
    required this.senderId,
    required this.receiverId,
    required this.content,
    this.messageType = 'text',
  });
}

// Mark messages as read
class MarkAsReadEvent extends ChatEvent {
  final String conversationId;
  final String userId;
  MarkAsReadEvent(this.conversationId, this.userId);
}

// Delete message
class DeleteMessageEvent extends ChatEvent {
  final String messageId;
  final String userId;
  DeleteMessageEvent(this.messageId, this.userId);
}

// Real-time events
class MessageReceivedEvent extends ChatEvent {
  final Map<String, dynamic> message;
  MessageReceivedEvent(this.message);
}

class ConversationUpdatedEvent extends ChatEvent {
  final Map<String, dynamic> conversation;
  ConversationUpdatedEvent(this.conversation);
}

// Clear chat state
class ClearChatEvent extends ChatEvent {}
