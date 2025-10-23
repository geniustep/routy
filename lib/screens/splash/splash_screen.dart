import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:routy/screens/splash/splash_controller.dart';
import 'package:routy/screens/splash/splash_animations.dart';
import 'package:routy/screens/splash/splash_config.dart';

/// 🚀 Splash Screen - شاشة البداية
///
/// UI فقط - جميع المنطق في SplashController
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Controller
  late final SplashController _controller;

  // Animations
  late final SplashAnimations _animations;

  @override
  void initState() {
    super.initState();

    // تهيئة Controller
    _controller = Get.put(SplashController());

    // تهيئة Animations
    _animations = SplashAnimations(vsync: this);
  }

  @override
  void dispose() {
    _animations.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SplashConfig.backgroundColor,
      body: Stack(
        children: [
          // خلفية متحركة
          _buildAnimatedBackground(),

          // المحتوى
          _buildContent(),

          // حالة الخطأ
          _buildErrorOverlay(),
        ],
      ),
    );
  }

  // ==================== Background ====================

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _animations.particles,
      builder: (context, child) {
        return CustomPaint(
          painter: ParticlesPainter(
            animationValue: _animations.particles.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }

  // ==================== Main Content ====================

  Widget _buildContent() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(SplashConfig.contentPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),

            // الشعار المتحرك
            _buildAnimatedLogo(),

            const SizedBox(height: 48),

            // اسم التطبيق
            _buildAppName(),

            const Spacer(),

            // التقدم والحالة
            _buildProgressSection(),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ==================== Logo ====================

  Widget _buildAnimatedLogo() {
    return AnimatedBuilder(
      animation: _animations.logoController,
      builder: (context, child) {
        return Transform.scale(
          scale: _animations.logoScale.value,
          child: Transform.rotate(
            angle: _animations.logoRotation.value,
            child: Opacity(
              opacity: _animations.logoOpacity.value,
              child: Container(
                width: SplashConfig.logoSize,
                height: SplashConfig.logoSize,
                decoration: BoxDecoration(
                  color: SplashConfig.progressColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: SplashConfig.progressColor.withValues(alpha: 0.5),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(Icons.route, size: 80, color: Colors.white),
              ),
            ),
          ),
        );
      },
    );
  }

  // ==================== App Name ====================

  Widget _buildAppName() {
    return const Text(
      'Routy',
      style: TextStyle(
        fontSize: 42,
        fontWeight: FontWeight.bold,
        color: SplashConfig.textColor,
        letterSpacing: 2,
      ),
    );
  }

  // ==================== Progress Section ====================

  Widget _buildProgressSection() {
    return Obx(() {
      return Column(
        children: [
          // الحالة الرئيسية
          Text(
            _controller.currentStatus.value.tr,
            style: const TextStyle(
              fontSize: SplashConfig.statusTextSize,
              color: SplashConfig.textColor,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // شريط التقدم العام
          _buildProgressBar(
            progress: _controller.progress.value,
            showPercentage: true,
          ),

          const SizedBox(height: 24),

          // تقدم النموذج الحالي
          if (_controller.currentModel.value.isNotEmpty) ...[
            Text(
              'splash_model_${_controller.currentModel.value}'.tr,
              style: const TextStyle(
                fontSize: SplashConfig.modelTextSize,
                color: SplashConfig.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 8),
            _buildProgressBar(
              progress: _controller.modelProgress.value,
              showPercentage: false,
              height: 2,
            ),
          ],
        ],
      );
    });
  }

  // ==================== Progress Bar ====================

  Widget _buildProgressBar({
    required double progress,
    bool showPercentage = false,
    double height = SplashConfig.progressBarHeight,
  }) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(SplashConfig.progressBarRadius),
          child: SizedBox(
            height: height,
            child: LinearProgressIndicator(
              value: progress / 100,
              backgroundColor: SplashConfig.progressBackgroundColor,
              valueColor: const AlwaysStoppedAnimation<Color>(
                SplashConfig.progressColor,
              ),
            ),
          ),
        ),
        if (showPercentage) ...[
          const SizedBox(height: 8),
          Text(
            '${progress.toStringAsFixed(0)}%',
            style: const TextStyle(
              fontSize: SplashConfig.progressTextSize,
              color: SplashConfig.textSecondaryColor,
            ),
          ),
        ],
      ],
    );
  }

  // ==================== Error Overlay ====================

  Widget _buildErrorOverlay() {
    return Obx(() {
      final error = _controller.errorMessage.value;
      if (error == null) return const SizedBox.shrink();

      return Container(
        color: Colors.black.withValues(alpha: 0.8),
        child: Center(
          child: Card(
            margin: const EdgeInsets.all(32),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // أيقونة الخطأ
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),

                  const SizedBox(height: 16),

                  // رسالة الخطأ
                  Text(
                    error,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 24),

                  // الأزرار
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // إعادة المحاولة
                      if (_controller.retryCount.value <
                          SplashConfig.maxRetries)
                        ElevatedButton.icon(
                          onPressed: () => _controller.retryManually(),
                          icon: const Icon(Icons.refresh),
                          label: Text('splash_retry'.tr),
                        ),

                      // تخطي للـ Login
                      TextButton.icon(
                        onPressed: () => _controller.skipToLogin(),
                        icon: const Icon(Icons.arrow_forward),
                        label: Text('splash_skip'.tr),
                      ),
                    ],
                  ),

                  // عداد المحاولات
                  if (_controller.retryCount.value > 0) ...[
                    const SizedBox(height: 8),
                    Text(
                      'splash_retry_count'.trParams({
                        'current': '${_controller.retryCount.value}',
                        'max': '${SplashConfig.maxRetries}',
                      }),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}

// ==================== Particles Painter ====================

/// رسام الجزيئات المتحركة
class ParticlesPainter extends CustomPainter {
  final double animationValue;
  final Random random = Random(42); // Seed ثابت لنتائج متسقة

  ParticlesPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < SplashConfig.particlesCount; i++) {
      final x = random.nextDouble() * size.width;
      final baseY = random.nextDouble() * size.height;

      // حركة عمودية
      final y = baseY + (animationValue * size.height) % size.height;

      // حجم عشوائي
      final particleSize =
          SplashConfig.particleMinSize +
          random.nextDouble() *
              (SplashConfig.particleMaxSize - SplashConfig.particleMinSize);

      canvas.drawCircle(Offset(x, y), particleSize, paint);
    }
  }

  @override
  bool shouldRepaint(ParticlesPainter oldDelegate) {
    return animationValue != oldDelegate.animationValue;
  }
}
