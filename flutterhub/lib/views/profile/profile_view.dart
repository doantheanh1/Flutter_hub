import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterhub/blocs/auth/auth_bloc.dart';
import 'package:flutterhub/blocs/auth/auth_event.dart';
import 'package:flutterhub/blocs/auth/auth_state.dart';
import 'package:flutterhub/blocs/profile/profile_bloc.dart';
import 'package:flutterhub/views/login/signin/view/signin_view.dart';
import 'package:flutterhub/views/profile/updateProfile_View.dart';
import 'package:flutterhub/repositories/profile_repository.dart';
import 'package:flutterhub/blocs/theme_cubit.dart';

class ProfileView extends StatelessWidget {
  final String displayName;
  final User user;

  const ProfileView({super.key, required this.displayName, required this.user});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthInitial) {
          // Khi logout thành công thì quay về màn hình login
          Navigator.of(
            context,
          ).pushReplacement(MaterialPageRoute(builder: (_) => LoginView()));
        }
        if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.white),
                  SizedBox(width: 8),
                  Expanded(child: Text('Lỗi: ${state.message}')),
                ],
              ),
              backgroundColor: Colors.red[400],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
        if (state is AuthProfileUpdateSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Cập nhật hồ sơ thành công'),
                ],
              ),
              backgroundColor: Colors.green[400],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Container(
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
          child: SafeArea(
            child: Column(
              children: [
                // Custom App Bar
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Text(
                        'Hồ sơ cá nhân',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      ),
                      Spacer(),
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).colorScheme.secondary,
                              Theme.of(context).colorScheme.secondary,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.person,
                          color: Theme.of(context).colorScheme.onBackground,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),

                // Profile Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Profile Header
                        Container(
                          padding: EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.surface.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).colorScheme.surface.withOpacity(0.2),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 20,
                                offset: Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Avatar with gradient border
                              Container(
                                padding: EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Theme.of(context).colorScheme.secondary,
                                      Theme.of(context).colorScheme.secondary,
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundColor:
                                      Theme.of(context).colorScheme.surface,
                                  backgroundImage:
                                      user.photoURL != null
                                          ? NetworkImage(user.photoURL!)
                                          : AssetImage(
                                                'assets/images/avatar.png',
                                              )
                                              as ImageProvider,
                                ),
                              ),
                              SizedBox(height: 20),
                              Text(
                                displayName.isNotEmpty
                                    ? displayName
                                    : 'Người dùng',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.onBackground,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                user.email ?? '',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onBackground.withOpacity(0.7),
                                ),
                              ),
                              SizedBox(height: 16),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.secondary.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.secondary.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.verified,
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.secondary,
                                      size: 16,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'Đã xác thực',
                                      style: TextStyle(
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.secondary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 24),

                        // User Stats
                        BlocProvider(
                          create:
                              (context) =>
                                  ProfileBloc(repository: ProfileRepository())
                                    ..add(LoadProfileStats(userId: user.uid)),
                          child: BlocBuilder<ProfileBloc, ProfileState>(
                            builder: (context, state) {
                              if (state is ProfileLoading) {
                                return Container(
                                  padding: EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.surface.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.surface.withOpacity(0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: _buildStatItem(
                                          context,
                                          icon: Icons.post_add,
                                          value: '...',
                                          label: 'Bài viết',
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.secondary,
                                        ),
                                      ),
                                      Container(
                                        width: 1,
                                        height: 40,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.surface.withOpacity(0.2),
                                      ),
                                      Expanded(
                                        child: _buildStatItem(
                                          context,
                                          icon: Icons.favorite,
                                          value: '...',
                                          label: 'Lượt thích',
                                          color: Color(0xFFe74c3c),
                                        ),
                                      ),
                                      Container(
                                        width: 1,
                                        height: 40,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.surface.withOpacity(0.2),
                                      ),
                                      Expanded(
                                        child: _buildStatItem(
                                          context,
                                          icon: Icons.comment,
                                          value: '...',
                                          label: 'Bình luận',
                                          color: Color(0xFFf39c12),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              } else if (state is ProfileStatsLoaded) {
                                return Container(
                                  padding: EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.surface.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.surface.withOpacity(0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: _buildStatItem(
                                          context,
                                          icon: Icons.post_add,
                                          value: state.postsCount.toString(),
                                          label: 'Bài viết',
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.secondary,
                                        ),
                                      ),
                                      Container(
                                        width: 1,
                                        height: 40,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.surface.withOpacity(0.2),
                                      ),
                                      Expanded(
                                        child: _buildStatItem(
                                          context,
                                          icon: Icons.favorite,
                                          value: state.likesCount.toString(),
                                          label: 'Lượt thích',
                                          color: Color(0xFFe74c3c),
                                        ),
                                      ),
                                      Container(
                                        width: 1,
                                        height: 40,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.surface.withOpacity(0.2),
                                      ),
                                      Expanded(
                                        child: _buildStatItem(
                                          context,
                                          icon: Icons.comment,
                                          value: state.commentsCount.toString(),
                                          label: 'Bình luận',
                                          color: Color(0xFFf39c12),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              } else if (state is ProfileError) {
                                return Container(
                                  padding: EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.surface.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.surface.withOpacity(0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: _buildStatItem(
                                          context,
                                          icon: Icons.post_add,
                                          value: '0',
                                          label: 'Bài viết',
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.secondary,
                                        ),
                                      ),
                                      Container(
                                        width: 1,
                                        height: 40,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.surface.withOpacity(0.2),
                                      ),
                                      Expanded(
                                        child: _buildStatItem(
                                          context,
                                          icon: Icons.favorite,
                                          value: '0',
                                          label: 'Lượt thích',
                                          color: Color(0xFFe74c3c),
                                        ),
                                      ),
                                      Container(
                                        width: 1,
                                        height: 40,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.surface.withOpacity(0.2),
                                      ),
                                      Expanded(
                                        child: _buildStatItem(
                                          context,
                                          icon: Icons.comment,
                                          value: '0',
                                          label: 'Bình luận',
                                          color: Color(0xFFf39c12),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              } else {
                                return Container(
                                  padding: EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.surface.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.surface.withOpacity(0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: _buildStatItem(
                                          context,
                                          icon: Icons.post_add,
                                          value: '0',
                                          label: 'Bài viết',
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.secondary,
                                        ),
                                      ),
                                      Container(
                                        width: 1,
                                        height: 40,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.surface.withOpacity(0.2),
                                      ),
                                      Expanded(
                                        child: _buildStatItem(
                                          context,
                                          icon: Icons.favorite,
                                          value: '0',
                                          label: 'Lượt thích',
                                          color: Color(0xFFe74c3c),
                                        ),
                                      ),
                                      Container(
                                        width: 1,
                                        height: 40,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.surface.withOpacity(0.2),
                                      ),
                                      Expanded(
                                        child: _buildStatItem(
                                          context,
                                          icon: Icons.comment,
                                          value: '0',
                                          label: 'Bình luận',
                                          color: Color(0xFFf39c12),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            },
                          ),
                        ),

                        SizedBox(height: 24),

                        // Action Buttons
                        _buildActionButton(
                          context: context,
                          icon: Icons.edit,
                          title: 'Cập nhật hồ sơ',
                          subtitle: 'Chỉnh sửa thông tin cá nhân',
                          color: Theme.of(context).colorScheme.secondary,
                          onTap: () async {
                            final updated = await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder:
                                    (_) => UpdateProfileView(
                                      currentDisplayName: displayName,
                                    ),
                              ),
                            );

                            if (updated == true) {
                              // Reload user hiện tại từ Firebase và rebuild UI
                              final currentUser =
                                  FirebaseAuth.instance.currentUser;
                              await currentUser?.reload();
                              final updatedUser =
                                  FirebaseAuth.instance.currentUser;

                              // Bắt buộc gọi lại chính màn hình với dữ liệu mới
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder:
                                      (_) => ProfileView(
                                        displayName:
                                            updatedUser?.displayName ?? '',
                                        user: updatedUser!,
                                      ),
                                ),
                              );
                            }
                          },
                        ),

                        SizedBox(height: 16),

                        _buildActionButton(
                          context: context,
                          icon: Icons.settings,
                          title: 'Cài đặt',
                          subtitle: 'Tùy chỉnh ứng dụng',
                          color: Theme.of(context).colorScheme.secondary,
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              backgroundColor: Colors.transparent,
                              builder: (ctx) {
                                final themeCubit = context.read<ThemeCubit>();
                                return BlocProvider.value(
                                  value: themeCubit,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.surface.withOpacity(0.95),
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(24),
                                      ),
                                    ),
                                    padding: EdgeInsets.all(24),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Cài đặt',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 16),
                                        BlocBuilder<ThemeCubit, ThemeMode>(
                                          builder: (context, themeMode) {
                                            return Row(
                                              children: [
                                                Icon(
                                                  Icons.brightness_6,
                                                  color:
                                                      Theme.of(
                                                        context,
                                                      ).colorScheme.secondary,
                                                ),
                                                SizedBox(width: 12),
                                                Expanded(
                                                  child: Text(
                                                    'Chế độ giao diện',
                                                  ),
                                                ),
                                                Switch(
                                                  value:
                                                      themeMode ==
                                                      ThemeMode.dark,
                                                  onChanged: (val) {
                                                    context
                                                        .read<ThemeCubit>()
                                                        .toggleTheme();
                                                  },
                                                ),
                                                Text(
                                                  themeMode == ThemeMode.dark
                                                      ? 'Tối'
                                                      : 'Sáng',
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),

                        SizedBox(height: 16),

                        _buildActionButton(
                          context: context,
                          icon: Icons.help_outline,
                          title: 'Trợ giúp',
                          subtitle: 'Hướng dẫn sử dụng',
                          color: Theme.of(context).colorScheme.secondary,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Tính năng đang phát triển'),
                                backgroundColor: Colors.orange[400],
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                          },
                        ),

                        SizedBox(height: 24),

                        // Logout Button
                        Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFFe74c3c), Color(0xFFc0392b)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFFe74c3c).withOpacity(0.3),
                                blurRadius: 15,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                _showLogoutDialog(context);
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.logout,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      'Đăng xuất',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.surface.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(
                            context,
                          ).colorScheme.onBackground.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Theme.of(
                    context,
                  ).colorScheme.onBackground.withOpacity(0.5),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.logout, color: Color(0xFFe74c3c), size: 24),
              SizedBox(width: 12),
              Text(
                'Đăng xuất',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onBackground,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            'Bạn có chắc chắn muốn đăng xuất khỏi ứng dụng?',
            style: TextStyle(
              color: Theme.of(
                context,
              ).colorScheme.onBackground.withOpacity(0.8),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Hủy',
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onBackground.withOpacity(0.6),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFe74c3c), Color(0xFFc0392b)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.read<AuthBloc>().add(LogoutRequested());
                },
                child: Text(
                  'Đăng xuất',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
