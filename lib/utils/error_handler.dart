import 'package:supabase_flutter/supabase_flutter.dart';

class ErrorHandler {
  /// Menerjemahkan pesan error raw (seperti Exception/SocketException) menjadi pesan bahasa Indonesia yang bersih
  static String cleanMessage(dynamic error) {
    if (error == null) return 'Terjadi kesalahan tidak dikenal.';
    
    if (error is PostgrestException) {
      if (error.code == '23505') return 'Data sudah ada (duplikat).';
      if (error.code == '23503') return 'Data tidak dapat dihapus karena masih digunakan di tempat lain.';
      return error.message;
    }
    if (error is AuthException) {
      return error.message;
    }

    final errorString = error.toString().toLowerCase();

    // Koneksi
    if (errorString.contains('socketexception') ||
        errorString.contains('failed host lookup') ||
        errorString.contains('connection refused') ||
        errorString.contains('clientexception')) {
      return 'Gagal terhubung ke server. Periksa koneksi internet Anda.';
    }

    if (errorString.contains('timeout')) {
      return 'Koneksi lambat atau habis waktu. Silakan coba lagi.';
    }

    // Auth Supabase (contoh)
    if (errorString.contains('invalid login credentials') ||
        errorString.contains('invalid credentials')) {
      return 'Email atau password yang Anda masukkan salah.';
    }

    if (errorString.contains('user already registered')) {
      return 'Email tersebut sudah terdaftar.';
    }

    // Default cleanup if no specific match
    String cleaned = error.toString().replaceAll('Exception: ', '').trim();
    if (cleaned.length > 100) {
      cleaned = 'Terjadi kesalahan pada sistem. Silakan coba beberapa saat lagi.';
    }
    return cleaned;
  }
}
