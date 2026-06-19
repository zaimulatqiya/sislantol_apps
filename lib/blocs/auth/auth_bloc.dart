import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../models/user_model.dart';
import '../../data/datasources/supabase_auth_datasource.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../utils/error_handler.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SupabaseAuthDataSource authDataSource;

  AuthBloc({required this.authDataSource}) : super(AuthInitial()) {
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
    try {
      final user = await authDataSource.login(event.email, event.password);
      
      // Save session
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', jsonEncode(user.toJson()));

      emit(AuthSuccess(user: user));
    } catch (e) {
      emit(AuthFailure(message: ErrorHandler.cleanMessage(e)));
    }
  }

  Future<void> _onRegister(RegisterSubmitted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final newUser = UserModel(
        id: 'u${DateTime.now().millisecondsSinceEpoch}',
        nama: event.nama,
        email: event.email,
        noHp: event.noHp,
        role: 'pengguna',
      );

      final registeredUser = await authDataSource.register(newUser, event.password);

      // Save session
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', jsonEncode(registeredUser.toJson()));

      emit(AuthSuccess(user: registeredUser));
    } catch (e) {
      emit(AuthFailure(message: ErrorHandler.cleanMessage(e)));
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
