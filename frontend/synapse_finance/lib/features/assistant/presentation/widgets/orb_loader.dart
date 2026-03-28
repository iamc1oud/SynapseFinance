import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A sci-fi rotating dotted sphere with a gentle bobbing motion.
class OrbLoader extends StatefulWidget {
  final double size;
  final Color color;

  const OrbLoader({super.key, this.size = 24, required this.color});

  @override
  State<OrbLoader> createState() => _OrbLoaderState();
}

class _OrbLoaderState extends State<OrbLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        // Smooth bobbing via sine
        final bob = math.sin(_controller.value * 2 * math.pi) * 2;
        return Transform.translate(
          offset: Offset(0, bob),
          child: CustomPaint(
            size: Size.square(widget.size),
            painter: _OrbPainter(
              color: widget.color,
              rotation: _controller.value,
            ),
          ),
        );
      },
    );
  }
}

class _OrbPainter extends CustomPainter {
  final Color color;
  final double rotation;

  _OrbPainter({required this.color, required this.rotation});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.42;
    final angle = rotation * 2 * math.pi;

    // Subtle glow behind the orb
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(Offset(cx, cy), r * 0.7, glowPaint);

    // Draw 3 rings of dots, each tilted differently to form a sphere
    _drawRing(canvas, cx, cy, r, angle, 0, 12);           // equator
    _drawRing(canvas, cx, cy, r * 0.82, angle + 0.4, 0.9, 10);  // tilted ring
    _drawRing(canvas, cx, cy, r * 0.82, -angle + 0.8, -0.9, 10); // opposite tilt
  }

  void _drawRing(
    Canvas canvas,
    double cx,
    double cy,
    double radius,
    double rotationAngle,
    double tiltX,
    int dotCount,
  ) {
    for (int i = 0; i < dotCount; i++) {
      final theta = (i / dotCount) * 2 * math.pi + rotationAngle;

      // 3D point on a circle, then apply X-axis tilt
      final x = radius * math.cos(theta);
      var y = radius * math.sin(theta);
      var z = 0.0;

      // Rotate around X axis for tilt
      final cosT = math.cos(tiltX);
      final sinT = math.sin(tiltX);
      final ny = y * cosT - z * sinT;
      final nz = y * sinT + z * cosT;
      y = ny;
      z = nz;

      // Depth-based alpha and size (dots behind the sphere are dimmer/smaller)
      final depth = (z / radius + 1) / 2; // 0 = far, 1 = near
      final alpha = 0.2 + depth * 0.8;
      final dotRadius = (0.8 + depth * 1.0) * (radius / 12);

      final paint = Paint()..color = color.withValues(alpha: alpha);

      canvas.drawCircle(
        Offset(cx + x, cy + y),
        dotRadius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_OrbPainter oldDelegate) => true;
}
