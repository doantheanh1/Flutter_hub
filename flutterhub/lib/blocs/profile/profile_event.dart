part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}

class LoadProfileStats extends ProfileEvent {
  final String userId;

  const LoadProfileStats({required this.userId});

  @override
  List<Object> get props => [userId];
}
