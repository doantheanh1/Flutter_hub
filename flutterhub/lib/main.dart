import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterhub/blocs/auth/auth_bloc.dart';
import 'package:flutterhub/blocs/post/post_bloc.dart';
import 'package:flutterhub/blocs/post/post_event.dart';
import 'package:flutterhub/blocs/comment/comment_bloc.dart';
import 'package:flutterhub/blocs/likes/like_bloc.dart';
import 'package:flutterhub/repositories/auth_repository.dart';
import 'package:flutterhub/repositories/cloudinary_repository.dart';
import 'package:flutterhub/repositories/Comment_Repository.dart';
import 'package:flutterhub/views/create_post/post_page.dart';
import 'package:flutterhub/views/login/signin/view/signin_view.dart';
import 'services/google_auth_service.dart';
import 'package:flutterhub/blocs/theme_cubit.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final googleAuthService = GoogleAuthService();
    final authRepository = AuthRepository(googleAuthService);

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create:
              (_) => AuthBloc(
                authRepository: authRepository,
                cloudinaryRepository: CloudinaryRepository(),
              ),
        ),
        BlocProvider(create: (_) => PostBloc()..add(FetchPostsEvent())),
        BlocProvider(create: (_) => LikeBloc()),
        BlocProvider(
          create: (_) => CommentBloc(CommentRepository('http://10.0.2.2:3000')),
        ),
        BlocProvider(create: (_) => ThemeCubit()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            themeMode: themeMode,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            home: LoginView(),
            routes: {'/post': (_) => const PostPage()},
          );
        },
      ),
    );
  }
}
