import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/cloudinary_repository.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  final CloudinaryRepository cloudinaryRepository;

  AuthBloc({required this.authRepository, required this.cloudinaryRepository})
    : super(AuthInitial()) {
    on<GoogleLoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await authRepository.signInWithGoogle();
        await authRepository.createUserOnBackend(
          authorId: user.uid,
          author: user.displayName ?? '',
          email: user.email ?? '',
          avatarUrl: user.photoURL,
        );
        emit(AuthSuccess(user, user.displayName ?? ""));
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<LogoutRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await authRepository.signOut();
        emit(AuthInitial());
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<EmailSignUpRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await authRepository.signUpWithEmail(
          event.name,
          event.email,
          event.password,
        );
        emit(AuthSuccess(user, user.displayName ?? ""));
      } catch (e) {
        String errorMessage = "Đăng ký thất bại";
        if (e.toString().contains("email-already-in-use")) {
          errorMessage = "Email này đã được đăng ký";
        }
        emit(AuthFailure(errorMessage));
      }
    });

    on<EmailLoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await authRepository.signInWithEmail(
          event.email,
          event.password,
        );
        await authRepository.createUserOnBackend(
          authorId: user.uid,
          author: user.displayName ?? '',
          email: user.email ?? '',
          avatarUrl: user.photoURL,
        );
        emit(AuthSuccess(user, user.displayName ?? ""));
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });
    on<UpdateProfileRequested>((event, emit) async {
      emit(AuthProfileUpdating());
      try {
        String? imageUrl;
        if (event.avatarImage != null) {
          // upload ảnh lên Cloudinary
          imageUrl = await cloudinaryRepository.uploadImage(event.avatarImage!);
        }

        // gọi hàm cập nhật profile Firebase
        final updatedUser = await authRepository.updateProfile(
          displayName: event.displayName,
          photoUrl: imageUrl,
        );

        emit(
          AuthProfileUpdateSuccess(updatedUser, updatedUser.displayName ?? ""),
        );
      } catch (e) {
        emit(AuthProfileUpdateFailure("Cập nhật thất bại: ${e.toString()}"));
      }
    });
  }
}
