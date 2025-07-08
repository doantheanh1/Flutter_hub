import 'dart:io';

import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
}

class GoogleLoginRequested extends AuthEvent {
  @override
  List<Object?> get props => [];
}

class LogoutRequested extends AuthEvent {
  @override
  List<Object?> get props => [];
}

class EmailSignUpRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;

  const EmailSignUpRequested({
    required this.name,
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [name, email, password];
}

class EmailLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const EmailLoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class UpdateProfileRequested extends AuthEvent {
  final String displayName;
  final File? avatarImage;

  UpdateProfileRequested({required this.displayName, this.avatarImage});

  @override
  List<Object?> get props => [displayName, avatarImage];
}
