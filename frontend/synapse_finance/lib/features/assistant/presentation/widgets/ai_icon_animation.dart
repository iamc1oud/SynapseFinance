import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class AiIconAnimation extends StatefulWidget {
  final double size;
  const AiIconAnimation({super.key, this.size = 100});

  @override
  State<AiIconAnimation> createState() => _AiIconAnimationState();
}

class _AiIconAnimationState extends State<AiIconAnimation>
    with TickerProviderStateMixin {
  late final AnimationController _orbitController;
  late final AnimationController _innerOrbitController;
  late final AnimationController _pulseController;
  late final AnimationController _sparkleController;

  @override
  void initState() {
    super.initState();

    // Outer ring: 6 seconds per revolution
    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    // Inner ring: separate controller, opposite direction, 4.5s per revolution
    _innerOrbitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4500),
    )..repeat();

    // Pulse: linear for smooth continuous breathing
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
  }

  @override
  void dispose() {
    _orbitController.dispose();
    _innerOrbitController.dispose();
    _pulseController.dispose();
    _sparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final size = widget.size;

    return SizedBox(
      width: size,
      height: size,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _orbitController,
          _innerOrbitController,
          _pulseController,
          _sparkleController,
        ]),
        builder: (context, _) {
          // Smooth sine-based pulse (no snapping at endpoints)
          final pulseValue =
              0.5 + 0.5 * math.sin(_pulseController.value * 2 * math.pi);

          return CustomPaint(
            painter: _AiIconPainter(
              primaryColor: c.primary,
              outerOrbit: _orbitController.value,
              innerOrbit: _innerOrbitController.value,
              pulseValue: pulseValue,
              sparkleProgress: _sparkleController.value,
            ),
            child: Center(
              child: Transform.scale(
                scale: 0.92 + (pulseValue * 0.08),
                child: Icon(
                  Icons.auto_awesome,
                  size: size * 0.36,
                  color: c.primary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AiIconPainter extends CustomPainter {
  final Color primaryColor;
  final double outerOrbit;
  final double innerOrbit;
  final double pulseValue;
  final double sparkleProgress;

  _AiIconPainter({
    required this.primaryColor,
    required this.outerOrbit,
    required this.innerOrbit,
    required this.pulseValue,
    required this.sparkleProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Pulsing glow
    final glowPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.08 * pulseValue)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    canvas.drawCircle(center, radius * 0.7, glowPaint);

    final innerGlow = Paint()
      ..color = primaryColor.withValues(alpha: 0.12 * pulseValue)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(center, radius * 0.4, innerGlow);

    // Outer orbit ring (clockwise)
    _drawOrbitRing(canvas, center, radius * 0.78, outerOrbit, 0.15);
    // Inner orbit ring (counter-clockwise, own controller)
    _drawOrbitRing(canvas, center, radius * 0.58, -innerOrbit, 0.10);

    // Orbiting dots on outer ring
    _drawOrbitDot(canvas, center, radius * 0.78, outerOrbit, 4.5);
    _drawOrbitDot(canvas, center, radius * 0.78, outerOrbit + 0.5, 3.0);
    // Orbiting dot on inner ring
    _drawOrbitDot(canvas, center, radius * 0.58, -innerOrbit, 3.5);

    // Sparkle particles
    _drawSparkles(canvas, center, radius);
  }

  void _drawOrbitRing(
    Canvas canvas,
    Offset center,
    double radius,
    double progress,
    double opacity,
  ) {
    final paint = Paint()
      ..color = primaryColor.withValues(alpha: opacity * pulseValue)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    const segments = 8;
    const gapRatio = 0.35;
    final segmentAngle = (2 * math.pi / segments) * (1 - gapRatio);
    final totalAngle = 2 * math.pi / segments;

    for (int i = 0; i < segments; i++) {
      final startAngle = (i * totalAngle) + (progress * 2 * math.pi);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        segmentAngle,
        false,
        paint,
      );
    }
  }

  void _drawOrbitDot(
    Canvas canvas,
    Offset center,
    double radius,
    double progress,
    double dotRadius,
  ) {
    final angle = progress * 2 * math.pi;
    final dotCenter = Offset(
      center.dx + radius * math.cos(angle),
      center.dy + radius * math.sin(angle),
    );

    // Glow behind dot
    final glowPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(dotCenter, dotRadius + 2, glowPaint);

    // Dot
    final dotPaint = Paint()..color = primaryColor.withValues(alpha: 0.85);
    canvas.drawCircle(dotCenter, dotRadius, dotPaint);
  }

  void _drawSparkles(Canvas canvas, Offset center, double radius) {
    final rng = math.Random(42);

    for (int i = 0; i < 5; i++) {
      final baseAngle = rng.nextDouble() * 2 * math.pi;
      final dist = radius * (0.45 + rng.nextDouble() * 0.5);
      final speed = 0.8 + rng.nextDouble() * 0.4;
      final phase = rng.nextDouble();

      final t = ((sparkleProgress * speed) + phase) % 1.0;
      // Smooth sine fade in/out (no snapping)
      final alpha = math.sin(t * math.pi);

      final angle = baseAngle + sparkleProgress * math.pi * 0.3;
      final pos = Offset(
        center.dx + dist * math.cos(angle),
        center.dy + dist * math.sin(angle),
      );

      final sparkSize = 1.5 + rng.nextDouble() * 1.5;

      final paint = Paint()
        ..color = primaryColor.withValues(alpha: alpha * 0.7)
        ..strokeWidth = 1.0;

      // Draw small cross sparkle
      canvas.drawLine(
        pos.translate(-sparkSize, 0),
        pos.translate(sparkSize, 0),
        paint,
      );
      canvas.drawLine(
        pos.translate(0, -sparkSize),
        pos.translate(0, sparkSize),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_AiIconPainter oldDelegate) => true;
}
