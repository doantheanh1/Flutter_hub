import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutterhub/repositories/profile_repository.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository repository;
  ProfileBloc({required this.repository}) : super(ProfileInitial()) {
    on<LoadProfileStats>(_onLoadProfileStats);
  }

  Future<void> _onLoadProfileStats(
    LoadProfileStats event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      emit(ProfileLoading());
      final stats = await repository.getProfileStats(event.userId);
      emit(
        ProfileStatsLoaded(
          postsCount: stats.posts,
          likesCount: stats.likes,
          commentsCount: stats.comments,
        ),
      );
    } catch (e) {
      emit(ProfileError(message: 'Không thể tải thống kê: ${e.toString()}'));
    }
  }
}
