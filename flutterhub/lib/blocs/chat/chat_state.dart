abstract class ChatState {}

// Initial state
class ChatInitial extends ChatState {}

// Loading states
class ChatLoading extends ChatState {}

class ConversationsLoading extends ChatState {}

class MessagesLoading extends ChatState {}

class SendingMessage extends ChatState {}

// Success states
class ConversationsLoaded extends ChatState {
  final List<Map<String, dynamic>> conversations;
  ConversationsLoaded(this.conversations);
}

class MessagesLoaded extends ChatState {
  final List<Map<String, dynamic>> messages;
  final String conversationId;
  MessagesLoaded(this.messages, this.conversationId);
}

class MessageSent extends ChatState {
  final Map<String, dynamic> message;
  MessageSent(this.message);
}

class MessagesMarkedAsRead extends ChatState {
  final String conversationId;
  MessagesMarkedAsRead(this.conversationId);
}

class MessageDeleted extends ChatState {
  final String messageId;
  MessageDeleted(this.messageId);
}

// Error states
class ChatError extends ChatState {
  final String message;
  ChatError(this.message);
}

class ConversationsError extends ChatState {
  final String message;
  ConversationsError(this.message);
}

class MessagesError extends ChatState {
  final String message;
  MessagesError(this.message);
}

class SendMessageError extends ChatState {
  final String message;
  SendMessageError(this.message);
}

// Empty states
class NoConversations extends ChatState {}

class NoMessages extends ChatState {
  final String conversationId;
  NoMessages(this.conversationId);
}
