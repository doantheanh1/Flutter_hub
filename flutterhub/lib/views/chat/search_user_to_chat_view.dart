import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutterhub/views/chat/chat_view.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterhub/blocs/chat/chat_bloc.dart';

class SearchUserToChatView extends StatefulWidget {
  const SearchUserToChatView({super.key});

  @override
  State<SearchUserToChatView> createState() => _SearchUserToChatViewState();
}

class _SearchUserToChatViewState extends State<SearchUserToChatView> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = false;
  String _error = '';
  User? currentUser;

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
  }

  Future<void> _searchUsers(String keyword) async {
    setState(() {
      _isLoading = true;
      _error = '';
    });
    try {
      final response = await http.get(
        Uri.parse(
          'http://10.0.2.2:3000/api/users/search?search=$keyword&excludeId=${currentUser?.uid ?? ''}',
        ),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          final rawUsers = List<Map<String, dynamic>>.from(data['users']);
          final uniqueUsers = <String, Map<String, dynamic>>{};
          for (var user in rawUsers) {
            if (user['authorId'] != null &&
                !uniqueUsers.containsKey(user['authorId'])) {
              uniqueUsers[user['authorId']] = user;
            }
          }
          setState(() {
            _users = uniqueUsers.values.toList();
          });
        } else {
          setState(() {
            _error = data['message'] ?? 'Không tìm thấy người dùng.';
          });
        }
      } else {
        setState(() {
          _error = 'Lỗi server: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Lỗi mạng hoặc server.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Container(
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
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onSurface.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.colorScheme.onSurface.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          Icons.arrow_back_ios,
                          color: theme.colorScheme.onSurface,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Tìm kiếm người dùng',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const Spacer(),
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
                        Icons.search,
                        color: theme.colorScheme.onPrimary,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),

              // Search Content
              Expanded(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        controller: _searchController,
                        style: TextStyle(color: theme.colorScheme.onSurface),
                        decoration: InputDecoration(
                          hintText: 'Nhập tên hoặc email...',
                          hintStyle: TextStyle(
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                          filled: true,
                          fillColor: theme.colorScheme.surface.withOpacity(0.8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              Icons.search,
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.7,
                              ),
                            ),
                            onPressed: () {
                              _searchUsers(_searchController.text.trim());
                            },
                          ),
                        ),
                        onSubmitted: (value) => _searchUsers(value.trim()),
                      ),
                    ),
                    if (_isLoading)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: CircularProgressIndicator(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    if (_error.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          _error,
                          style: TextStyle(color: theme.colorScheme.error),
                        ),
                      ),
                    if (!_isLoading)
                      Expanded(
                        child:
                            _users.isNotEmpty
                                ? ListView.builder(
                                  itemCount: _users.length,
                                  itemBuilder: (context, index) {
                                    final user = _users[index];
                                    return ListTile(
                                      leading:
                                          user['avatarUrl'] != null &&
                                                  user['avatarUrl']
                                                      .toString()
                                                      .isNotEmpty
                                              ? CircleAvatar(
                                                backgroundImage:
                                                    user['avatarUrl']
                                                            .toString()
                                                            .startsWith('http')
                                                        ? NetworkImage(
                                                          user['avatarUrl'],
                                                        )
                                                        : NetworkImage(
                                                          'http://10.0.2.2:3000${user['avatarUrl']}',
                                                        ),
                                              )
                                              : CircleAvatar(
                                                child: Icon(
                                                  Icons.person,
                                                  color:
                                                      theme
                                                          .colorScheme
                                                          .onSurface,
                                                ),
                                                backgroundColor:
                                                    theme.colorScheme.surface,
                                              ),
                                      title: Text(
                                        user['author'] ?? '',
                                        style: TextStyle(
                                          color: theme.colorScheme.onSurface,
                                        ),
                                      ),
                                      subtitle: Text(
                                        user['email'] ?? '',
                                        style: TextStyle(
                                          color: theme.colorScheme.onSurface
                                              .withOpacity(0.7),
                                        ),
                                      ),
                                      onTap: () {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (_) => BlocProvider(
                                                  create: (_) => ChatBloc(),
                                                  child: ChatView(
                                                    conversationId: '',
                                                    otherUserId:
                                                        user['authorId'],
                                                    otherUserName:
                                                        user['author'],
                                                    otherUserAvatar:
                                                        user['avatarUrl'],
                                                  ),
                                                ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                )
                                : Center(
                                  child: Text(
                                    'Không tìm thấy người dùng nào.',
                                    style: TextStyle(
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.7),
                                    ),
                                  ),
                                ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
