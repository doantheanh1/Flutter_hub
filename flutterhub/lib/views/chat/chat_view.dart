import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutterhub/blocs/chat/chat_bloc.dart';
import 'package:flutterhub/blocs/chat/chat_event.dart';
import 'package:flutterhub/blocs/chat/chat_state.dart';
import 'package:flutterhub/views/chat/search_user_to_chat_view.dart';

class ChatView extends StatefulWidget {
  final String conversationId;
  final String otherUserId;
  final String otherUserName;
  final String? otherUserAvatar;

  const ChatView({
    super.key,
    required this.conversationId,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserAvatar,
  });

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  User? currentUser;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String? _currentConversationId;

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
    _currentConversationId = widget.conversationId;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();

    if (currentUser != null && widget.conversationId.isNotEmpty) {
      context.read<ChatBloc>().add(
        FetchMessagesEvent(widget.conversationId, currentUser!.uid),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      children: [
        Scaffold(
          backgroundColor: theme.colorScheme.background,
          appBar: _buildAppBar(),
          body: _buildBody(),
        ),
        Positioned(
          bottom: 24,
          right: 24,
          child: FloatingActionButton(
            backgroundColor: theme.colorScheme.primary,
            child: Icon(Icons.search, color: theme.colorScheme.onPrimary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchUserToChatView()),
              );
            },
          ),
        ),
      ],
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final theme = Theme.of(context);
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors:
                theme.brightness == Brightness.dark
                    ? [
                      const Color(0xFF1A1A2E),
                      const Color(0xFF16213E),
                      const Color(0xFF0F3460),
                    ]
                    : [
                      theme.colorScheme.surface,
                      theme.colorScheme.surface.withOpacity(0.9),
                      theme.colorScheme.surface.withOpacity(0.8),
                    ],
          ),
        ),
      ),
      title: Row(
        children: [
          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.secondary,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: theme.colorScheme.onSurface.withOpacity(0.2),
                width: 2,
              ),
            ),
            child:
                widget.otherUserAvatar != null
                    ? ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.network(
                        widget.otherUserAvatar!.startsWith('http')
                            ? widget.otherUserAvatar!
                            : 'http://10.0.2.2:3000${widget.otherUserAvatar}',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Text(
                              widget.otherUserName[0].toUpperCase(),
                              style: TextStyle(
                                color: theme.colorScheme.onPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          );
                        },
                      ),
                    )
                    : Center(
                      child: Text(
                        widget.otherUserName[0].toUpperCase(),
                        style: TextStyle(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.otherUserName,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Đang hoạt động',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {
            // TODO: Add more options
          },
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.more_vert,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          Expanded(
            child: BlocListener<ChatBloc, ChatState>(
              listener: (context, state) {
                if (state is MessagesLoaded || state is MessageSent) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _scrollToBottom();
                  });
                }
                if (state is MessageSent &&
                    state.message['conversationId'] != null) {
                  final newConvId = state.message['conversationId'];
                  print(
                    '[ChatView] MessageSent: newConvId=$newConvId, _currentConversationId=$_currentConversationId',
                  );
                  if (newConvId != _currentConversationId) {
                    setState(() {
                      _currentConversationId = newConvId;
                    });
                    if (currentUser != null) {
                      print(
                        '[ChatView] Dispatch FetchMessagesEvent for new conversationId',
                      );
                      context.read<ChatBloc>().add(
                        FetchMessagesEvent(newConvId, currentUser!.uid),
                      );
                    }
                  }
                }
              },
              child: BlocBuilder<ChatBloc, ChatState>(
                builder: (context, state) {
                  if (state is MessagesLoading) {
                    return _buildLoadingState();
                  } else if (state is MessagesLoaded) {
                    if (state.messages.isEmpty) {
                      return _buildEmptyState();
                    }
                    return _buildMessagesList(state.messages);
                  } else if (state is MessagesError) {
                    return _buildErrorState(state.message);
                  } else if (state is NoMessages) {
                    return _buildEmptyState();
                  }
                  return _buildLoadingState();
                },
              ),
            ),
          ),
          _buildInputField(),
        ],
      ),
    );
  }

  Widget _buildMessagesList(List<Map<String, dynamic>> messages) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isOwnMessage = message['senderId'] == currentUser?.uid;

        return _buildMessageBubble(message, isOwnMessage, index);
      },
    );
  }

  Widget _buildMessageBubble(
    Map<String, dynamic> message,
    bool isOwnMessage,
    int index,
  ) {
    final theme = Theme.of(context);
    final content = message['content'] ?? '';
    final timestamp = message['createdAt'] ?? '';
    final isRead = message['isRead'] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isOwnMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isOwnMessage) ...[
            // Avatar for other user
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.secondary,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child:
                  widget.otherUserAvatar != null
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.network(
                          widget.otherUserAvatar!.startsWith('http')
                              ? widget.otherUserAvatar!
                              : 'http://10.0.2.2:3000${widget.otherUserAvatar}',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Text(
                                widget.otherUserName[0].toUpperCase(),
                                style: TextStyle(
                                  color: theme.colorScheme.onPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            );
                          },
                        ),
                      )
                      : Center(
                        child: Text(
                          widget.otherUserName[0].toUpperCase(),
                          style: TextStyle(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
            ),
          ],
          // Message bubble
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors:
                      isOwnMessage
                          ? [
                            theme.colorScheme.primary,
                            theme.colorScheme.secondary,
                          ]
                          : theme.brightness == Brightness.dark
                          ? [
                            Colors.white.withOpacity(0.1),
                            Colors.white.withOpacity(0.05),
                          ]
                          : [
                            theme.colorScheme.surface,
                            theme.colorScheme.surface.withOpacity(0.8),
                          ],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isOwnMessage ? 20 : 4),
                  bottomRight: Radius.circular(isOwnMessage ? 4 : 20),
                ),
                border: Border.all(
                  color:
                      isOwnMessage
                          ? theme.colorScheme.onPrimary.withOpacity(0.2)
                          : theme.colorScheme.onSurface.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    content,
                    style: TextStyle(
                      fontSize: 15,
                      color:
                          isOwnMessage
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSurface,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(timestamp),
                        style: TextStyle(
                          fontSize: 11,
                          color:
                              isOwnMessage
                                  ? theme.colorScheme.onPrimary.withOpacity(0.7)
                                  : theme.colorScheme.onSurface.withOpacity(
                                    0.5,
                                  ),
                        ),
                      ),
                      if (isOwnMessage) ...[
                        const SizedBox(width: 4),
                        Icon(
                          isRead ? Icons.done_all : Icons.done,
                          size: 14,
                          color:
                              isRead
                                  ? Colors.blue
                                  : theme.colorScheme.onPrimary.withOpacity(
                                    0.7,
                                  ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isOwnMessage) ...[
            const SizedBox(width: 8),
            // Avatar for own message
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.secondary,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child:
                  currentUser?.photoURL != null
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.network(
                          currentUser!.photoURL!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Text(
                                (currentUser?.displayName ?? 'U')[0]
                                    .toUpperCase(),
                                style: TextStyle(
                                  color: theme.colorScheme.onPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            );
                          },
                        ),
                      )
                      : Center(
                        child: Text(
                          (currentUser?.displayName ?? 'U')[0].toUpperCase(),
                          style: TextStyle(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputField() {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              theme.brightness == Brightness.dark
                  ? [
                    Colors.white.withOpacity(0.05),
                    Colors.white.withOpacity(0.02),
                  ]
                  : [
                    theme.colorScheme.surface,
                    theme.colorScheme.surface.withOpacity(0.9),
                  ],
        ),
      ),
      child: Row(
        children: [
          // Attachment button
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.attach_file,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          // Message input
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: theme.colorScheme.onSurface.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _messageController,
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                  hintText: 'Nhập tin nhắn...',
                  hintStyle: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                    fontSize: 15,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (text) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Send button
          BlocBuilder<ChatBloc, ChatState>(
            builder: (context, state) {
              final isLoading = state is SendingMessage;

              return Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  ),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: IconButton(
                  onPressed: isLoading ? null : _sendMessage,
                  icon:
                      isLoading
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : const Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
              borderRadius: BorderRadius.circular(50),
            ),
            child: const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Đang tải tin nhắn...',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Icon(
              Icons.chat_bubble_outline,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Chưa có tin nhắn nào',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bắt đầu cuộc trò chuyện!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: Colors.red.withOpacity(0.3), width: 2),
            ),
            child: const Icon(Icons.error_outline, color: Colors.red, size: 32),
          ),
          const SizedBox(height: 16),
          Text(
            'Đã xảy ra lỗi',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isNotEmpty && currentUser != null) {
      context.read<ChatBloc>().add(
        SendMessageEvent(
          senderId: currentUser!.uid,
          receiverId: widget.otherUserId,
          content: text,
        ),
      );
      _messageController.clear();
    }
  }

  String _formatTime(String timeString) {
    if (timeString.isEmpty) return '';

    try {
      final dateTime = DateTime.parse(timeString);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 0) {
        return '${difference.inDays}d';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m';
      } else {
        return 'Vừa xong';
      }
    } catch (e) {
      return '';
    }
  }
}
