import 'package:flutter_bloc/flutter_bloc.dart';
import 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  SplashCubit() : super(SplashInitial());

  Future<void> initializeApp() async {
    emit(SplashLoading());
    // Simulate loading delay for aesthetic splash screen
    await Future.delayed(const Duration(milliseconds: 2500));
    emit(SplashCompleted());
  }
}
