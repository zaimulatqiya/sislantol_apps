import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../models/user_model.dart';
import '../../data/mock_data.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<LoginSubmitted>(_onLogin);
    on<RegisterSubmitted>(_onRegister);
    on<LogoutRequested>(_onLogout);
    
    // Auto-login check when BLoC is created could also be added here
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user_data');
    if (userJson != null) {
      try {
        final user = UserModel.fromJson(jsonDecode(userJson));
        emit(AuthSuccess(user: user));
      } catch (e) {
        emit(AuthUnauthenticated());
      }
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onLogin(LoginSubmitted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await Future.delayed(const Duration(seconds: 1)); // Simulate network

    try {
      // Find user from mock data
      final user = MockData.users.firstWhere(
        (u) => u.email == event.email,
        orElse: () => throw Exception('Email tidak ditemukan'),
      );
      
      // Since dummy, we ignore password check or just assume it is 'password123'
      if (event.password.isEmpty) {
        throw Exception('Password wajib diisi');
      }

      // Save session
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', jsonEncode(user.toJson()));

      emit(AuthSuccess(user: user));
    } catch (e) {
      emit(AuthFailure(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onRegister(RegisterSubmitted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await Future.delayed(const Duration(seconds: 1)); // Simulate network

    try {
      // Simulate registering new user logic
      final newUser = UserModel(
        id: 'u${DateTime.now().millisecondsSinceEpoch}',
        nama: event.nama,
        email: event.email,
        noHp: event.noHp,
        role: 'pengguna',
      );

      // Save to mock memory so it's queryable during the session if needed
      MockData.users.add(newUser);

      // Save session
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', jsonEncode(newUser.toJson()));

      emit(AuthSuccess(user: newUser));
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }

  Future<void> _onLogout(LogoutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
    await Future.delayed(const Duration(milliseconds: 500));
    emit(AuthUnauthenticated());
  }
}
