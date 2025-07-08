part of 'profile_bloc.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileStatsLoaded extends ProfileState {
  final int postsCount;
  final int likesCount;
  final int commentsCount;

  const ProfileStatsLoaded({
    required this.postsCount,
    required this.likesCount,
    required this.commentsCount,
  });

  @override
  List<Object> get props => [postsCount, likesCount, commentsCount];
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError({required this.message});

  @override
  List<Object> get props => [message];
}
