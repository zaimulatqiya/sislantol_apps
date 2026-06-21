import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  SplashCubit() : super(SplashInitial());

  Future<void> initializeApp() async {
    emit(SplashLoading());
    
    // Simulate loading delay for aesthetic splash screen
    // We do it before network check to ensure splash screen shows at least 1.5s
    await Future.delayed(const Duration(milliseconds: 1500));

    // Cek koneksi internet
    bool hasConnection = await _checkInternetConnection();
    
    if (!hasConnection) {
      emit(const SplashError(message: 'Pastikan perangkat Anda terhubung ke internet yang stabil untuk melanjutkan.'));
      return;
    }

    // Additional delay to ensure total splash time is roughly 2.5s if network is fast
    await Future.delayed(const Duration(milliseconds: 1000));
    emit(SplashCompleted());
  }

  Future<bool> _checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }
}
