import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/user_model.dart';

class SupabaseAuthDataSource {
  final _supabase = Supabase.instance.client;

  Future<UserModel> login(String email, String password) async {
    try {
      if (password.isEmpty) {
        throw Exception('Password wajib diisi');
      }

      final AuthResponse response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('User tidak ditemukan');
      }

      // Fetch profile from profiles table
      final profileData = await _supabase
          .from('profiles')
          .select()
          .eq('id', response.user!.id)
          .single();

      return UserModel(
        id: profileData['id'],
        nama: profileData['nama'] ?? '',
        email: profileData['email'] ?? email,
        noHp: profileData['no_hp'] ?? '',
        role: profileData['role'] ?? 'pengguna',
        statusPetugas: profileData['status_petugas'],
      );
    } catch (e) {
      if (e is AuthException) {
        String message = e.message;
        if (message.toLowerCase().contains('invalid login credentials')) {
          message = 'Email atau password salah';
        } else if (message.toLowerCase().contains('email not confirmed')) {
          message = 'Email belum diverifikasi';
        } else if (message.toLowerCase().contains('user not found')) {
          message = 'Email belum terdaftar';
        } else if (message.toLowerCase().contains('invalid email')) {
          message = 'Format email tidak valid';
        }
        throw Exception(message);
      }
      throw Exception('Gagal melakukan login: $e');
    }
  }

  Future<UserModel> register(UserModel newUser, String password) async {
    try {
      if (password.isEmpty) {
        throw Exception('Password wajib diisi');
      }

      final AuthResponse response = await _supabase.auth.signUp(
        email: newUser.email,
        password: password,
        data: {
          'nama': newUser.nama,
          'no_hp': newUser.noHp,
          'role': newUser.role,
        },
      );

      if (response.user == null) {
        throw Exception('Gagal melakukan registrasi');
      }

      // The profile will be automatically created by the Supabase trigger
      // Return the passed model with the new user id
      return UserModel(
        id: response.user!.id,
        nama: newUser.nama,
        email: newUser.email,
        noHp: newUser.noHp,
        role: newUser.role,
      );
    } catch (e) {
      if (e is AuthException) {
        String message = e.message;
        if (message.toLowerCase().contains('user already registered')) {
          message = 'Email sudah terdaftar';
        } else if (message.toLowerCase().contains('invalid email')) {
          message = 'Format email tidak valid';
        } else if (message.toLowerCase().contains('password should be')) {
          message = 'Password terlalu lemah, minimal 6 karakter';
        }
        throw Exception(message);
      }
      throw Exception('Gagal melakukan registrasi: $e');
    }
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
  }
}
