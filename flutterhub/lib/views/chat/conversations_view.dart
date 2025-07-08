import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutterhub/blocs/chat/chat_bloc.dart';
import 'package:flutterhub/blocs/chat/chat_event.dart';
import 'package:flutterhub/blocs/chat/chat_state.dart';
import 'package:flutterhub/views/chat/chat_view.dart';
import 'package:flutterhub/views/chat/search_user_to_chat_view.dart';

class ConversationsView extends StatefulWidget {
  const ConversationsView({super.key});

  @override
  State<ConversationsView> createState() => _ConversationsViewState();
}

class _ConversationsViewState extends State<ConversationsView>
    with TickerProviderStateMixin {
  User? currentUser;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();

    if (currentUser != null) {
      context.read<ChatBloc>().add(FetchConversationsEvent(currentUser!.uid));
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: _buildAppBar(theme),
      body: _buildBody(theme),
      floatingActionButton: FloatingActionButton(
        backgroundColor: theme.colorScheme.primary,
        child: Icon(Icons.search, color: theme.colorScheme.onPrimary),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SearchUserToChatView()),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.secondary,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.chat_bubble_outline,
              color: theme.colorScheme.onPrimary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Tin nhắn',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
              fontSize: 20,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
      actions: [],
    );
  }

  Widget _buildBody(ThemeData theme) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          if (state is ConversationsLoading) {
            return _buildLoadingState(theme);
          } else if (state is ConversationsLoaded) {
            if (state.conversations.isEmpty) {
              return _buildEmptyState(theme);
            }
            return _buildConversationsList(state.conversations, theme);
          } else if (state is ConversationsError) {
            return _buildErrorState(state.message, theme);
          } else if (state is NoConversations) {
            return _buildEmptyState(theme);
          }
          return _buildLoadingState(theme);
        },
      ),
    );
  }

  Widget _buildConversationsList(
    List<Map<String, dynamic>> conversations,
    ThemeData theme,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: conversations.length,
      itemBuilder: (context, index) {
        final conversation = conversations[index];
        return _buildConversationCard(conversation, index, theme);
      },
    );
  }

  Widget _buildConversationCard(
    Map<String, dynamic> conversation,
    int index,
    ThemeData theme,
  ) {
    final otherUser = conversation['otherUser'] ?? {};
    final lastMessage = conversation['lastMessageContent'] ?? '';
    final lastMessageTime = conversation['lastMessageTime'] ?? '';
    final unreadCount = conversation['unreadCount'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors:
              theme.brightness == Brightness.dark
                  ? [
                    const Color(0xFF1A1A2E).withOpacity(0.8),
                    const Color(0xFF16213E).withOpacity(0.8),
                  ]
                  : [
                    theme.colorScheme.surface,
                    theme.colorScheme.surface.withOpacity(0.9),
                  ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => BlocProvider(
                      create: (_) => ChatBloc(),
                      child: ChatView(
                        conversationId: conversation['_id'],
                        otherUserId: otherUser['id'] ?? '',
                        otherUserName: otherUser['name'] ?? 'Unknown User',
                        otherUserAvatar: otherUser['avatar'],
                      ),
                    ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.secondary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color:
                          unreadCount > 0
                              ? Colors.pink
                              : theme.colorScheme.onSurface.withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  child:
                      otherUser['avatar'] != null
                          ? ClipRRect(
                            borderRadius: BorderRadius.circular(23),
                            child: Image.network(
                              otherUser['avatar'].toString().startsWith('http')
                                  ? otherUser['avatar']
                                  : 'http://10.0.2.2:3000${otherUser['avatar']}',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: Text(
                                    (otherUser['name'] ?? 'U')[0].toUpperCase(),
                                    style: TextStyle(
                                      color: theme.colorScheme.onPrimary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 18,
                                    ),
                                  ),
                                );
                              },
                            ),
                          )
                          : Center(
                            child: Text(
                              (otherUser['name'] ?? 'U')[0].toUpperCase(),
                              style: TextStyle(
                                color: theme.colorScheme.onPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                              ),
                            ),
                          ),
                ),
                const SizedBox(width: 12),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              otherUser['name'] ?? 'Unknown User',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color:
                                    unreadCount > 0
                                        ? theme.colorScheme.onPrimary
                                        : theme.colorScheme.onSurface
                                            .withOpacity(0.9),
                              ),
                            ),
                          ),
                          Text(
                            _formatTime(lastMessageTime),
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              lastMessage.isNotEmpty
                                  ? lastMessage
                                  : 'Bắt đầu cuộc trò chuyện',
                              style: TextStyle(
                                fontSize: 14,
                                color:
                                    unreadCount > 0
                                        ? theme.colorScheme.onPrimary
                                            .withOpacity(0.9)
                                        : theme.colorScheme.onSurface
                                            .withOpacity(0.7),
                                fontWeight:
                                    unreadCount > 0
                                        ? FontWeight.w500
                                        : FontWeight.normal,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (unreadCount > 0) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [theme.colorScheme.error, Colors.red],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                unreadCount.toString(),
                                style: TextStyle(
                                  color: theme.colorScheme.onError,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
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
        ),
      ),
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.secondary,
                ],
              ),
              borderRadius: BorderRadius.circular(50),
            ),
            child: CircularProgressIndicator(
              color: theme.colorScheme.onPrimary,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Đang tải tin nhắn...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.secondary,
                ],
              ),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              Icons.chat_bubble_outline,
              color: theme.colorScheme.onPrimary,
              size: 48,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Chưa có cuộc trò chuyện nào',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bắt đầu trò chuyện với bạn bè!',
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.error.withOpacity(0.2),
              borderRadius: BorderRadius.circular(50),
              border: Border.all(
                color: theme.colorScheme.error.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.error_outline,
              color: theme.colorScheme.error,
              size: 48,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Đã xảy ra lỗi',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              if (currentUser != null) {
                context.read<ChatBloc>().add(
                  FetchConversationsEvent(currentUser!.uid),
                );
              }
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
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
