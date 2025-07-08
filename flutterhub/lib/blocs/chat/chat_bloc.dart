import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterhub/blocs/chat/chat_event.dart';
import 'package:flutterhub/blocs/chat/chat_state.dart';
import 'package:flutterhub/repositories/chat_repository.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository _chatRepository = ChatRepository();

  // Local state for conversations and messages
  List<Map<String, dynamic>> _conversations = [];
  Map<String, List<Map<String, dynamic>>> _messages = {};
  String? _currentConversationId;

  ChatBloc() : super(ChatInitial()) {
    on<FetchConversationsEvent>(_onFetchConversations);
    on<FetchMessagesEvent>(_onFetchMessages);
    on<SendMessageEvent>(_onSendMessage);
    on<MarkAsReadEvent>(_onMarkAsRead);
    on<DeleteMessageEvent>(_onDeleteMessage);
    on<MessageReceivedEvent>(_onMessageReceived);
    on<ConversationUpdatedEvent>(_onConversationUpdated);
    on<ClearChatEvent>(_onClearChat);
  }

  // Get conversations
  Future<void> _onFetchConversations(
    FetchConversationsEvent event,
    Emitter<ChatState> emit,
  ) async {
    try {
      emit(ConversationsLoading());

      final conversations = await _chatRepository.getConversations(
        event.userId,
      );
      _conversations = conversations;

      if (conversations.isEmpty) {
        emit(NoConversations());
      } else {
        emit(ConversationsLoaded(conversations));
      }
    } catch (e) {
      emit(ConversationsError(e.toString()));
    }
  }

  // Get messages for a conversation
  Future<void> _onFetchMessages(
    FetchMessagesEvent event,
    Emitter<ChatState> emit,
  ) async {
    try {
      emit(MessagesLoading());
      final messages = await _chatRepository.getMessages(
        event.conversationId,
        event.userId,
      );
      print(
        '[ChatBloc] FetchMessagesEvent: conversationId=${event.conversationId}, userId=${event.userId}, messages.length=${messages.length}',
      );
      _messages[event.conversationId] = messages;
      _currentConversationId = event.conversationId;
      if (messages.isEmpty) {
        emit(NoMessages(event.conversationId));
      } else {
        emit(MessagesLoaded(messages, event.conversationId));
      }
    } catch (e) {
      print('[ChatBloc] FetchMessagesEvent ERROR: $e');
      emit(MessagesError(e.toString()));
    }
  }

  // Send message
  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    try {
      emit(SendingMessage());
      final message = await _chatRepository.sendMessage(
        senderId: event.senderId,
        receiverId: event.receiverId,
        content: event.content,
        messageType: event.messageType,
      );
      print('[ChatBloc] SendMessageEvent: message=' + message.toString());
      // Add message to local state
      final conversationId =
          message['conversationId'] ?? _currentConversationId;
      if (conversationId != null) {
        if (!_messages.containsKey(conversationId)) {
          _messages[conversationId] = [];
        }
        _messages[conversationId]!.add(message);
        _updateConversationInList(message, conversationId);
      }
      emit(MessageSent(message));
      if (conversationId != null && _messages.containsKey(conversationId)) {
        emit(MessagesLoaded(_messages[conversationId]!, conversationId));
      }
    } catch (e) {
      print('[ChatBloc] SendMessageEvent ERROR: $e');
      emit(SendMessageError(e.toString()));
    }
  }

  // Mark messages as read
  Future<void> _onMarkAsRead(
    MarkAsReadEvent event,
    Emitter<ChatState> emit,
  ) async {
    try {
      await _chatRepository.markAsRead(event.conversationId, event.userId);

      // Update local state
      if (_messages.containsKey(event.conversationId)) {
        for (var message in _messages[event.conversationId]!) {
          if (message['receiverId'] == event.userId) {
            message['isRead'] = true;
            message['readAt'] = DateTime.now().toIso8601String();
          }
        }
      }

      emit(MessagesMarkedAsRead(event.conversationId));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  // Delete message
  Future<void> _onDeleteMessage(
    DeleteMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    try {
      await _chatRepository.deleteMessage(event.messageId, event.userId);

      // Remove from local state
      for (var conversationId in _messages.keys) {
        _messages[conversationId]!.removeWhere(
          (message) => message['_id'] == event.messageId,
        );
      }

      emit(MessageDeleted(event.messageId));

      // Re-emit current state
      if (_currentConversationId != null &&
          _messages.containsKey(_currentConversationId)) {
        emit(
          MessagesLoaded(
            _messages[_currentConversationId]!,
            _currentConversationId!,
          ),
        );
      }
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  // Handle real-time message received
  void _onMessageReceived(MessageReceivedEvent event, Emitter<ChatState> emit) {
    final message = event.message;
    final conversationId = message['conversationId'];

    if (conversationId != null) {
      // Add to messages
      if (!_messages.containsKey(conversationId)) {
        _messages[conversationId] = [];
      }
      _messages[conversationId]!.add(message);

      // Update conversation list
      _updateConversationInList(message, conversationId);

      // Emit updated state if this is the current conversation
      if (_currentConversationId == conversationId) {
        emit(MessagesLoaded(_messages[conversationId]!, conversationId));
      }
    }
  }

  // Handle conversation update
  void _onConversationUpdated(
    ConversationUpdatedEvent event,
    Emitter<ChatState> emit,
  ) {
    final conversation = event.conversation;
    final conversationId = conversation['_id'];

    // Update in conversations list
    final index = _conversations.indexWhere((c) => c['_id'] == conversationId);
    if (index != -1) {
      _conversations[index] = conversation;
    } else {
      _conversations.insert(0, conversation);
    }

    // Sort by last message time
    _conversations.sort(
      (a, b) => DateTime.parse(
        b['lastMessageTime'],
      ).compareTo(DateTime.parse(a['lastMessageTime'])),
    );

    emit(ConversationsLoaded(_conversations));
  }

  // Clear chat state
  void _onClearChat(ClearChatEvent event, Emitter<ChatState> emit) {
    _conversations.clear();
    _messages.clear();
    _currentConversationId = null;
    emit(ChatInitial());
  }

  // Helper method to update conversation in list
  void _updateConversationInList(
    Map<String, dynamic> message,
    String conversationId,
  ) {
    final index = _conversations.indexWhere((c) => c['_id'] == conversationId);
    if (index != -1) {
      _conversations[index]['lastMessageContent'] = message['content'];
      _conversations[index]['lastMessageTime'] = message['createdAt'];
    }

    // Sort by last message time
    _conversations.sort(
      (a, b) => DateTime.parse(
        b['lastMessageTime'],
      ).compareTo(DateTime.parse(a['lastMessageTime'])),
    );
  }

  // Getters for current state
  List<Map<String, dynamic>> get conversations => _conversations;
  Map<String, List<Map<String, dynamic>>> get messages => _messages;
  String? get currentConversationId => _currentConversationId;
}
