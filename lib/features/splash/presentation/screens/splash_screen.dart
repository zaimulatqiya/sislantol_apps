import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../utils/network_ui_helper.dart';
import '../../../../blocs/auth/auth_bloc.dart';
import '../../../../blocs/auth/auth_state.dart';
import '../bloc/splash_cubit.dart';
import '../bloc/splash_state.dart';
import '../widgets/splash_logo_animation.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  bool _isDataLoaded = false;
  bool _isIntroCompleted = false;

  late AnimationController _textFadeController;
  late Animation<double> _textFadeAnimation;
  late Animation<Offset> _textSlideAnimation;

  @override
  void initState() {
    super.initState();
    
    // Text entrance animation
    _textFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    
    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textFadeController, curve: const Interval(0.5, 1.0, curve: Curves.easeIn)),
    );
    
    _textSlideAnimation = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _textFadeController, curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic)),
    );

    _textFadeController.forward();

    // Initialize the splash timer/data loading
    context.read<SplashCubit>().initializeApp();
  }

  @override
  void dispose() {
    _textFadeController.dispose();
    super.dispose();
  }

  void _checkAndNavigate() {
    // Only navigate when both the intro animation is done AND data is loaded
    if (_isDataLoaded && _isIntroCompleted) {
      _navigateToNextScreen();
    }
  }

  void _navigateToNextScreen() {
    // Check current auth state
    final authState = context.read<AuthBloc>().state;
    
    if (authState is AuthSuccess) {
      if (authState.user.role == 'pengguna') {
        Navigator.pushReplacementNamed(context, AppRoutes.penggunaHome);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.petugasHome);
      }
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashCubit, SplashState>(
      listener: (context, state) {
        if (state is SplashCompleted) {
          if (mounted) {
            setState(() {
              _isDataLoaded = true;
            });
            _checkAndNavigate();
          }
        } else if (state is SplashError) {
          NetworkUIHelper.showNetworkErrorModal(
            context,
            message: state.message,
            onRetry: () {
              context.read<SplashCubit>().initializeApp();
            },
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC), // Slightly off-white for a premium feel
        body: Stack(
          children: [
            // Aesthetic Background Decorations
            Positioned(
              top: -150,
              left: -100,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.03),
                ),
              ),
            ),
            Positioned(
              bottom: -150,
              right: -100,
              child: Container(
                width: 350,
                height: 350,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.04),
                ),
              ),
            ),
            
            SafeArea(
              child: Stack(
                children: [
                  // Center Content (Logo and Typography)
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Custom Animated Logo
                        SplashLogoAnimation(
                          onIntroComplete: () {
                            if (mounted) {
                              setState(() {
                                _isIntroCompleted = true;
                              });
                              _checkAndNavigate();
                            }
                          },
                        ),
                        const SizedBox(height: 40),
                        
                        // Animated Typography
                        SlideTransition(
                          position: _textSlideAnimation,
                          child: FadeTransition(
                            opacity: _textFadeAnimation,
                            child: Column(
                              children: [
                                const Text(
                                  'SISLANTOL',
                                  style: TextStyle(
                                    fontSize: 34,
                                    fontWeight: FontWeight.w900, // Extra bold for clean aesthetic
                                    color: AppColors.primary,
                                    letterSpacing: 6,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'LAYANAN MOBIL DEREK & PATROLI',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.primary.withOpacity(0.8),
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Minimalist Bottom Loading Indicator
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 48.0),
                      child: FadeTransition(
                        opacity: _textFadeAnimation,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                                strokeWidth: 2.5,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Memuat data...',
                              style: TextStyle(
                                color: AppColors.primary.withOpacity(0.6),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
