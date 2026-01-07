import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Animated Vitrin Circle with rotating gradient border (like Instagram stories)
class AnimatedVitrinCircle extends StatefulWidget {
  final Widget child;
  final String? label;
  final VoidCallback? onTap;
  final double size;

  const AnimatedVitrinCircle({
    super.key,
    required this.child,
    this.label,
    this.onTap,
    this.size = 66,
  });

  @override
  State<AnimatedVitrinCircle> createState() => _AnimatedVitrinCircleState();
}

class _AnimatedVitrinCircleState extends State<AnimatedVitrinCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated rotating gradient border
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Container(
                  width: widget.size + 6,
                  height: widget.size + 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: SweepGradient(
                      startAngle: _controller.value * 2 * math.pi,
                      endAngle: _controller.value * 2 * math.pi + math.pi * 2,
                      colors: const [
                        Color(0xFFFF6B6B), // Red
                        Color(0xFFFFE66D), // Yellow
                        Color(0xFF4ECDC4), // Teal
                        Color(0xFF45B7D1), // Blue
                        Color(0xFF96CEB4), // Green
                        Color(0xFFFF6B6B), // Back to red
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryBlue.withAlpha(60),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: child,
                );
              },
              child: Container(
                margin: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: widget.child,
              ),
            ),
            if (widget.label != null) ...[
              const SizedBox(height: 4),
              SizedBox(
                width: 70,
                child: Text(
                  widget.label!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Animated Campaign Card with pulse and shimmer effect
class AnimatedCampaignCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String? discount;
  final Color accentColor;
  final Color? bgColor;
  final VoidCallback? onTap;

  const AnimatedCampaignCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.discount,
    this.accentColor = AppTheme.accentGreen,
    this.bgColor,
    this.onTap,
  });

  @override
  State<AnimatedCampaignCard> createState() => _AnimatedCampaignCardState();
}

class _AnimatedCampaignCardState extends State<AnimatedCampaignCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
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
    final backgroundColor = widget.bgColor ?? widget.accentColor.withAlpha(30);
    
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 140,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: widget.accentColor.withAlpha(40),
                    blurRadius: 8 + (_scaleAnimation.value - 1) * 50,
                    spreadRadius: (_scaleAnimation.value - 1) * 5,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Shimmer effect overlay
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: ShaderMask(
                        shaderCallback: (bounds) {
                          return LinearGradient(
                            begin: Alignment(_shimmerAnimation.value - 1, 0),
                            end: Alignment(_shimmerAnimation.value, 0),
                            colors: [
                              Colors.transparent,
                              Colors.white.withAlpha(30),
                              Colors.transparent,
                            ],
                          ).createShader(bounds);
                        },
                        blendMode: BlendMode.srcATop,
                        child: Container(
                          color: widget.accentColor.withAlpha(10),
                        ),
                      ),
                    ),
                  ),
                  // Content
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Discount badge or icon
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: widget.accentColor.withAlpha(50),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: widget.discount != null
                              ? Text(
                                  widget.discount!,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: widget.accentColor,
                                  ),
                                )
                              : Icon(
                                  Icons.local_offer,
                                  color: widget.accentColor,
                                  size: 24,
                                ),
                        ),
                        const Spacer(),
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.subtitle,
                          style: const TextStyle(
                            color: AppTheme.mediumGray,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Sparkle/Glitter effect widget
class SparkleEffect extends StatefulWidget {
  final Widget child;
  final Color sparkleColor;

  const SparkleEffect({
    super.key,
    required this.child,
    this.sparkleColor = Colors.white,
  });

  @override
  State<SparkleEffect> createState() => _SparkleEffectState();
}

class _SparkleEffectState extends State<SparkleEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        // Sparkle dots
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return CustomPaint(
                painter: _SparklePainter(
                  progress: _controller.value,
                  color: widget.sparkleColor,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SparklePainter extends CustomPainter {
  final double progress;
  final Color color;

  _SparklePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withAlpha((100 * (1 - progress)).toInt())
      ..style = PaintingStyle.fill;

    final random = math.Random(42); // Fixed seed for consistent positions
    
    for (int i = 0; i < 8; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final sparkleProgress = (progress + i * 0.1) % 1;
      
      final radius = 2 * math.sin(sparkleProgress * math.pi);
      if (radius > 0) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SparklePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
