import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../dashboard_models.dart';

/// 🎨 Glassmorphism Card Widget
class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.color,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: padding ?? const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  (color ?? Colors.white).withOpacity(0.1),
                  (color ?? Colors.white).withOpacity(0.05),
                ],
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// 🔢 Animated Counter Widget
class AnimatedCounter extends StatelessWidget {
  final double value;
  final Duration duration;
  final String Function(double) formatter;
  final TextStyle? style;

  const AnimatedCounter({
    super.key,
    required this.value,
    this.duration = const Duration(seconds: 2),
    String Function(double)? formatter,
    this.style,
  }) : formatter = formatter ?? _defaultFormatter;

  static String _defaultFormatter(double value) => value.toStringAsFixed(0);

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: duration,
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Text(
          formatter(value),
          style: style,
        );
      },
    );
  }
}

/// 💫 Shimmer Loading Card
class ShimmerLoadingCard extends StatelessWidget {
  final double height;
  final double? width;
  final double borderRadius;

  const ShimmerLoadingCard({
    super.key,
    this.height = 100,
    this.width,
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// 📊 Enhanced KPI Card
class EnhancedKpiCard extends StatelessWidget {
  final KpiCardData data;
  final bool isDarkMode;

  const EnhancedKpiCard({
    super.key,
    required this.data,
    this.isDarkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode
            ? data.color.withOpacity(0.15)
            : data.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: data.color.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: data.color.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: data.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(data.icon, color: data.color, size: 24),
              ),
              const Spacer(),
              if (data.trend != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: data.isPositiveTrend
                        ? Colors.green.withOpacity(0.2)
                        : Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        data.isPositiveTrend
                            ? Icons.trending_up
                            : Icons.trending_down,
                        size: 14,
                        color: data.isPositiveTrend ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        data.trend!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color:
                              data.isPositiveTrend ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            data.title,
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? Colors.white70 : Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          AnimatedCounter(
            value: double.tryParse(
                    data.value.replaceAll(RegExp(r'[^0-9.]'), '')) ??
                0,
            formatter: (v) => data.value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: data.color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            data.subtitle,
            style: TextStyle(
              fontSize: 12,
              color: isDarkMode ? Colors.white60 : Colors.grey[500],
            ),
          ),
          if (data.progress > 0) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: data.progress,
                minHeight: 6,
                backgroundColor: data.color.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(data.color),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// ⚡ Enhanced Quick Action Card
class EnhancedQuickActionCard extends StatefulWidget {
  final QuickActionData data;
  final VoidCallback onTap;
  final bool isDarkMode;

  const EnhancedQuickActionCard({
    super.key,
    required this.data,
    required this.onTap,
    this.isDarkMode = false,
  });

  @override
  State<EnhancedQuickActionCard> createState() =>
      _EnhancedQuickActionCardState();
}

class _EnhancedQuickActionCardState extends State<EnhancedQuickActionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.data.isEnabled ? (_) => _controller.forward() : null,
      onTapUp: widget.data.isEnabled ? (_) => _controller.reverse() : null,
      onTapCancel: widget.data.isEnabled ? () => _controller.reverse() : null,
      onTap: widget.data.isEnabled ? widget.onTap : null,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: widget.isDarkMode
                    ? widget.data.color.withOpacity(0.15)
                    : widget.data.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: widget.data.color.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: widget.data.color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      widget.data.icon,
                      color: widget.data.color,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.data.title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: widget.isDarkMode ? Colors.white : Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (widget.data.badge != null && widget.data.badge! > 0)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    widget.data.badge! > 99 ? '99+' : '${widget.data.badge}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// 📋 Enhanced Activity Item
class EnhancedActivityItem extends StatelessWidget {
  final ActivityModelEnhanced activity;
  final bool isDarkMode;
  final VoidCallback? onTap;

  const EnhancedActivityItem({
    super.key,
    required this.activity,
    this.isDarkMode = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: activity.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: activity.color.withOpacity(0.3),
                ),
              ),
              child: Icon(
                activity.icon,
                color: activity.color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    activity.subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDarkMode ? Colors.white70 : Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Text(
              activity.timeAgo,
              style: TextStyle(
                fontSize: 11,
                color: isDarkMode ? Colors.white60 : Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
