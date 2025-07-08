import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthState extends Equatable {
  const AuthState();
}

class AuthInitial extends AuthState {
  @override
  List<Object?> get props => [];
}

class AuthLoading extends AuthState {
  @override
  List<Object?> get props => [];
}

class AuthSuccess extends AuthState {
  final String displayName;
  final User user;

  const AuthSuccess(this.user, this.displayName);

  @override
  List<Object?> get props => [displayName];
}

class AuthFailure extends AuthState {
  final String message;

  const AuthFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class AuthProfileUpdating extends AuthState {
  @override
  List<Object?> get props => [];
}

class AuthProfileUpdateSuccess extends AuthState {
  final User user;
  final String displayName;

  const AuthProfileUpdateSuccess(this.user, this.displayName);
  @override
  List<Object?> get props => [];
}

class AuthProfileUpdateFailure extends AuthState {
  final String message;

  const AuthProfileUpdateFailure(this.message);
  @override
  List<Object?> get props => [];
}
