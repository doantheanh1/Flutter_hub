import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterhub/blocs/comment/comment_bloc.dart';
import 'package:flutterhub/blocs/likes/like_bloc.dart';
import 'package:flutterhub/blocs/post/post_bloc.dart';
import 'package:flutterhub/blocs/post/post_event.dart';
import 'package:flutterhub/repositories/Comment_Repository.dart';
import 'package:flutterhub/views/profile/profile_view.dart';
import 'package:flutterhub/views/chat/conversations_view.dart';
import 'package:flutterhub/blocs/chat/chat_bloc.dart';
import 'view/home_page_view.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    final currentUser = FirebaseAuth.instance.currentUser;
    _pages = [
      BlocProvider<CommentBloc>(
        create: (_) => CommentBloc(CommentRepository('http://10.0.2.2:3000')),
        child: const HomePageView(),
      ),
      BlocProvider(create: (_) => ChatBloc(), child: const ConversationsView()),
      ProfileView(
        user: currentUser!,
        displayName: currentUser.displayName ?? currentUser.email ?? "Ẩn danh",
      ),
    ];
  }

  void _onTap(int index) async {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PostBloc>.value(value: BlocProvider.of<PostBloc>(context)),
        BlocProvider<LikeBloc>(create: (_) => LikeBloc()),
      ],
      child: Scaffold(
        body: _pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onTap,
          backgroundColor: Theme.of(context).colorScheme.surface,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Theme.of(
            context,
          ).colorScheme.onSurface.withOpacity(0.7),
          type: BottomNavigationBarType.fixed,
          showUnselectedLabels: true,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              label: 'Tin nhắn',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Cá nhân'),
          ],
        ),
      ),
    );
  }
}
