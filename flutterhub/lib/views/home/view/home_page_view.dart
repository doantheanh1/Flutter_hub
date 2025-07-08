// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutterhub/blocs/comment/comment_bloc.dart';
import 'package:flutterhub/blocs/likes/like_bloc.dart';
import 'package:flutterhub/blocs/likes/like_event.dart';
import 'package:flutterhub/blocs/likes/like_state.dart';
import 'package:flutterhub/blocs/post/post_bloc.dart';
import 'package:flutterhub/blocs/post/post_event.dart';
import 'package:flutterhub/blocs/post/post_state.dart';
import 'package:flutterhub/views/create_post/post_page.dart';
import 'package:flutterhub/views/home/view/comment_popup.dart';
import 'package:flutterhub/views/home/widgets/facebook_style_images.dart';

class HomePageView extends StatefulWidget {
  const HomePageView({super.key});
  static const String baseUrl = 'http://10.0.2.2:3000';

  @override
  State<HomePageView> createState() => _HomePageState();
}

class _HomePageState extends State<HomePageView> with TickerProviderStateMixin {
  User? currentUser;
  final Set<String> likedPosts = {};
  final Map<String, int> postLikes = {}; // Lưu số like của từng post
  final Map<String, bool> postLikeStatus =
      {}; // Lưu trạng thái like của user cho từng post
  String? processingPostId; // Track post đang được xử lý
  Map<String, dynamic>? originalPostData; // Lưu dữ liệu gốc để revert

  late AnimationController _refreshController;
  late AnimationController _fabController;

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
    context.read<PostBloc>().add(FetchPostsEvent());

    _refreshController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _fabController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    context.read<PostBloc>().add(FetchPostsEvent());
    await Future.delayed(const Duration(milliseconds: 1500));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient:
              Theme.of(context).brightness == Brightness.dark
                  ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1A1A2E),
                      Color(0xFF16213E),
                      Color(0xFF0F3460),
                    ],
                  )
                  : const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFE3E6F3),
                      Color(0xFFF5F6FA),
                      Color(0xFFFFFFFF),
                    ],
                  ),
        ),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.flutter_dash,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Flutter Hub',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.onBackground,
              fontSize: 24,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
      actions: [
        if (currentUser != null)
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white24, width: 2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: CircleAvatar(
              radius: 18,
              backgroundImage:
                  currentUser!.photoURL != null
                      ? NetworkImage(currentUser!.photoURL!)
                      : const AssetImage('assets/images/avatar.png')
                          as ImageProvider,
            ),
          ),
      ],
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        _buildCreatePostButton(),
        Expanded(
          child: BlocListener<LikeBloc, LikeState>(
            listener: (context, state) {
              if (state is LikeSuccess && state.postData != null) {
                final postData = state.postData!;
                final postId = postData['_id'];
                final newLikes = postData['likes'] ?? 0;
                final likedBy = List<String>.from(postData['likedBy'] ?? []);
                final isUserLiked = likedBy.contains(currentUser?.uid);

                setState(() {
                  postLikes[postId] = newLikes;
                  postLikeStatus[postId] = isUserLiked;
                  processingPostId = null;
                  originalPostData = null;
                });
              } else if (state is LikeError) {
                if (processingPostId != null && originalPostData != null) {
                  setState(() {
                    postLikes[processingPostId!] = originalPostData!['likes'];
                    postLikeStatus[processingPostId!] =
                        originalPostData!['isLiked'];
                    processingPostId = null;
                    originalPostData = null;
                  });
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.white),
                        const SizedBox(width: 8),
                        Expanded(child: Text(state.message)),
                      ],
                    ),
                    backgroundColor: Colors.red.shade600,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              }
            },
            child: BlocBuilder<PostBloc, PostState>(
              builder: (context, state) {
                if (state is PostLoaded) {
                  if (state.posts.isEmpty) {
                    return _buildEmptyState();
                  }

                  return RefreshIndicator(
                    onRefresh: _onRefresh,
                    color: const Color(0xFF667eea),
                    backgroundColor: const Color(0xFF1A1A2E),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: state.posts.length,
                      itemBuilder: (context, index) {
                        return _buildPostCard(state.posts[index]);
                      },
                    ),
                  );
                } else if (state is PostError) {
                  return _buildErrorState(state.message);
                }
                return _buildLoadingState();
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCreatePostButton() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient:
            Theme.of(context).brightness == Brightness.dark
                ? const LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                )
                : const LinearGradient(
                  colors: [Color(0xFF7C4DFF), Color(0xFF42A5F5)],
                ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:
                Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF667eea).withOpacity(0.3)
                    : Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PostPage()),
            );
            if (result == true) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        'Tạo bài viết thành công!',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: Colors.green.shade600,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Tạo bài viết mới',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post) {
    final List<dynamic> imageUrls = post['imageUrls'] ?? [];
    final String postId = post['_id'];
    int likes = post['likes'] ?? 0;

    // Khởi tạo local state nếu chưa có
    if (!postLikes.containsKey(postId)) {
      postLikes[postId] = likes;
    }
    if (!postLikeStatus.containsKey(postId)) {
      postLikeStatus[postId] =
          (post['likedBy'] as List<dynamic>?)?.contains(currentUser?.uid) ??
          false;
    }

    bool isLiked = postLikeStatus[postId] ?? false;
    int displayLikes = postLikes[postId] ?? likes;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPostHeader(post),
            if (imageUrls.isNotEmpty) _buildPostImages(imageUrls),
            _buildPostContent(post),
            _buildPostActions(postId, isLiked, displayLikes, post),
          ],
        ),
      ),
    );
  }

  Widget _buildPostHeader(Map<String, dynamic> post) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.05),
            Colors.white.withOpacity(0.02),
          ],
        ),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color:
                    Theme.of(context).brightness == Brightness.dark
                        ? Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.25)
                        : Colors.black.withOpacity(0.18),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: CircleAvatar(
              radius: 20,
              backgroundImage:
                  post['avatarUrl'] != null &&
                          post['avatarUrl'].toString().isNotEmpty
                      ? (post['avatarUrl'].toString().startsWith('http')
                          ? NetworkImage(post['avatarUrl'])
                          : NetworkImage(
                            'http://10.0.2.2:3000${post['avatarUrl']}',
                          ))
                      : const AssetImage('assets/images/avatar.png')
                          as ImageProvider,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post['author'] ?? 'Ẩn danh',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatPostTime(post['createdAt']),
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(
                      context,
                    ).colorScheme.onBackground.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.more_horiz,
              color: Colors.white70,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostImages(List<dynamic> imageUrls) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.25),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: FacebookStyleImages(imageUrls: imageUrls),
      ),
    );
  }

  Widget _buildPostContent(Map<String, dynamic> post) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (post['title']?.isNotEmpty == true) ...[
            Text(
              post['title'] ?? '',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: Theme.of(context).colorScheme.onBackground,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 8),
          ],
          if (post['content']?.isNotEmpty == true)
            Text(
              post['content'] ?? '',
              style: TextStyle(
                fontSize: 15,
                color: Theme.of(
                  context,
                ).colorScheme.onBackground.withOpacity(0.8),
                height: 1.4,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPostActions(
    String postId,
    bool isLiked,
    int displayLikes,
    Map<String, dynamic> post,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white.withOpacity(0.02), Colors.transparent],
        ),
      ),
      child: Row(
        children: [
          _buildLikeButton(postId, isLiked, displayLikes),
          const SizedBox(width: 16),
          _buildCommentButton(postId, post['authorId'] ?? ''),
          const Spacer(),
          _buildShareButton(),
        ],
      ),
    );
  }

  Widget _buildLikeButton(String postId, bool isLiked, int displayLikes) {
    return BlocBuilder<LikeBloc, LikeState>(
      builder: (context, likeState) {
        final isLoading =
            likeState is LikeLoading && processingPostId == postId;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap:
                isLoading
                    ? null
                    : () {
                      originalPostData = {
                        'likes': postLikes[postId] ?? 0,
                        'isLiked': isLiked,
                      };

                      setState(() {
                        processingPostId = postId;
                        if (!isLiked) {
                          postLikeStatus[postId] = true;
                          postLikes[postId] = (postLikes[postId] ?? 0) + 1;
                        } else {
                          postLikeStatus[postId] = false;
                          postLikes[postId] = (postLikes[postId] ?? 0) - 1;
                        }
                      });

                      if (!isLiked) {
                        context.read<LikeBloc>().add(
                          LikePostEvent(postId, currentUser!.uid),
                        );
                      } else {
                        context.read<LikeBloc>().add(
                          UnlikePostEvent(postId, currentUser!.uid),
                        );
                      }
                    },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color:
                    isLiked
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(
                          context,
                        ).colorScheme.secondary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color:
                      isLiked
                          ? Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.3)
                          : Theme.of(context).dividerColor.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow:
                    isLiked
                        ? [
                          BoxShadow(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.10),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                        : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isLoading)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.pink,
                      ),
                    )
                  else
                    Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      color:
                          isLiked
                              ? Colors.white
                              : Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                  const SizedBox(width: 6),
                  Text(
                    '$displayLikes',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onBackground,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCommentButton(String postId, [String authorId = '']) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          showDialog(
            context: context,
            builder:
                (_) => CommentPopup(
                  postId: postId,
                  userId: currentUser!.uid,
                  userName: currentUser!.displayName ?? 'Ẩn danh',
                  authorId: authorId,
                ),
          );
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.comment,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 6),
            Text(
              'Bình luận',
              style: TextStyle(
                color: Theme.of(
                  context,
                ).colorScheme.onBackground.withOpacity(0.8),
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareButton() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Icon(
        Icons.share,
        color: Theme.of(context).colorScheme.primary,
        size: 20,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Icon(Icons.post_add, color: Colors.white, size: 48),
          ),
          const SizedBox(height: 24),
          Text(
            'Chưa có bài viết nào',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Theme.of(
                context,
              ).colorScheme.onBackground.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hãy tạo bài viết đầu tiên để chia sẻ với mọi người!',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(
                context,
              ).colorScheme.onBackground.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
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
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: Colors.red.withOpacity(0.3), width: 2),
            ),
            child: const Icon(Icons.error_outline, color: Colors.red, size: 48),
          ),
          const SizedBox(height: 24),
          Text(
            'Đã xảy ra lỗi',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Theme.of(
                context,
              ).colorScheme.onBackground.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(
                context,
              ).colorScheme.onBackground.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              context.read<PostBloc>().add(FetchPostsEvent());
            },
            icon: const Icon(Icons.refresh),
            label: Text(
              'Thử lại',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF667eea),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
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
            padding: const EdgeInsets.all(24),
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
          const SizedBox(height: 24),
          Text(
            'Đang tải bài viết...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Theme.of(
                context,
              ).colorScheme.onBackground.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  String _formatPostTime(dynamic createdAt) {
    if (createdAt == null) return '';
    DateTime postTime;
    if (createdAt is String) {
      postTime = DateTime.tryParse(createdAt)?.toLocal() ?? DateTime.now();
    } else if (createdAt is DateTime) {
      postTime = createdAt.toLocal();
    } else {
      return '';
    }
    final now = DateTime.now();
    final diff = now.difference(postTime);
    if (diff.inSeconds < 60) return 'Vừa đăng';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    if (diff.inDays < 7) return '${diff.inDays} ngày trước';
    return '${postTime.day}/${postTime.month}/${postTime.year}';
  }
}
