import 'package:flutter/material.dart';

/// 🎨 Splash Animations Manager
///
/// يدير جميع الأنيميشنز في Splash Screen:
/// - Logo Animation
/// - Progress Animation
/// - Particles Animation
class SplashAnimations {
  final TickerProvider vsync;

  // Controllers
  late final AnimationController logoController;
  late final AnimationController progressController;
  late final AnimationController particlesController;

  // Animations
  late final Animation<double> logoScale;
  late final Animation<double> logoRotation;
  late final Animation<double> logoOpacity;
  late final Animation<double> particles;

  SplashAnimations({required this.vsync}) {
    _initializeAnimations();
  }

  void _initializeAnimations() {
    // Logo Animation (3 seconds, repeating)
    logoController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: vsync,
    );

    logoScale = Tween<double>(begin: 0.8, end: 1.1).animate(
      CurvedAnimation(parent: logoController, curve: Curves.elasticOut),
    );

    logoRotation = Tween<double>(
      begin: -0.1,
      end: 0.1,
    ).animate(CurvedAnimation(parent: logoController, curve: Curves.easeInOut));

    logoOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: logoController, curve: Curves.easeIn));

    logoController.repeat(reverse: true);

    // Progress Animation (500ms)
    progressController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: vsync,
    );

    // Particles Animation (20 seconds, repeating)
    particlesController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: vsync,
    )..repeat();

    particles = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(particlesController);
  }

  /// تنظيف الموارد
  void dispose() {
    logoController.dispose();
    progressController.dispose();
    particlesController.dispose();
  }

  /// إيقاف مؤقت
  void pause() {
    logoController.stop();
    progressController.stop();
    particlesController.stop();
  }

  /// استئناف
  void resume() {
    logoController.repeat(reverse: true);
    particlesController.repeat();
  }
}
