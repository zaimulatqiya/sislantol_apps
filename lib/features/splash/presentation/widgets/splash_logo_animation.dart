import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_colors.dart';

class SplashLogoAnimation extends StatefulWidget {
  final VoidCallback onIntroComplete;

  const SplashLogoAnimation({
    super.key,
    required this.onIntroComplete,
  });

  @override
  State<SplashLogoAnimation> createState() => _SplashLogoAnimationState();
}

class _SplashLogoAnimationState extends State<SplashLogoAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200), // Longer duration for an epic feel
    );

    // Bouncy scale for the logo
    _scaleAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    // Smooth fade in
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    // Glowing pulse effect behind the logo that expands slowly
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _animationController.forward().then((_) {
      if (mounted) {
        widget.onIntroComplete();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Soft aesthetic glowing background pulse
            Opacity(
              opacity: (1.0 - _glowAnimation.value) * 0.15, // Fades out as it expands
              child: Transform.scale(
                scale: 1.0 + (_glowAnimation.value * 0.8),
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            // The Logo itself with color filter applied to match theme
            FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: SvgPicture.asset(
                  'assets/images/logo_1.svg',
                  height: 160,
                  // ColorFilter ensures the black logo turns into Dark Navy to match the text
                  colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        );
      }
    );
  }
}
