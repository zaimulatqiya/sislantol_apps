import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginSubmitted extends AuthEvent {
  final String email;
  final String password;

  const LoginSubmitted({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class RegisterSubmitted extends AuthEvent {
  final String nama;
  final String email;
  final String noHp;
  final String password;

  const RegisterSubmitted({
    required this.nama,
    required this.email,
    required this.noHp,
    required this.password,
  });

  @override
  List<Object?> get props => [nama, email, noHp, password];
}

class LogoutRequested extends AuthEvent {}
