import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late final AnimationController _iconController;
  late final AnimationController _textController;
  late final AnimationController _pulseController;

  late final Animation<double> _iconScale;
  late final Animation<double> _iconFade;
  late final Animation<double> _textFade;
  late final Animation<Offset> _textSlide;
  late final Animation<double> _pulseScale;

  @override
  void initState() {
    super.initState();

    // Icon: scale + fade in
    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _iconScale = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.elasticOut),
    );

    _iconFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _iconController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    // Text: fade + slide up
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );

    // Pulse glow on the icon
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _pulseScale = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    _iconController.forward();

    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    _textController.forward();

    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _iconController.dispose();
    _textController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Scaffold(
      backgroundColor: c.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated icon
            AnimatedBuilder(
              animation: Listenable.merge([_iconController, _pulseController]),
              builder: (context, child) {
                return FadeTransition(
                  opacity: _iconFade,
                  child: ScaleTransition(
                    scale: _iconScale,
                    child: ScaleTransition(
                      scale: _pulseScale,
                      child: child,
                    ),
                  ),
                );
              },
              child: _SplashIcon(primary: c.primary, background: c.background),
            ),

            const SizedBox(height: 28),

            // App name
            SlideTransition(
              position: _textSlide,
              child: FadeTransition(
                opacity: _textFade,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Synapse Finance',
                      style: TextStyle(
                        color: c.textPrimary,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Smart Money Management',
                      style: TextStyle(
                        color: c.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Stylized app icon — layered circles with a finance icon
class _SplashIcon extends StatelessWidget {
  final Color primary;
  final Color background;

  const _SplashIcon({required this.primary, required this.background});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer glow ring
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  primary.withValues(alpha: 0.15),
                  primary.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
          // Main circle
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  primary,
                  primary.withValues(alpha: 0.7),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: primary.withValues(alpha: 0.35),
                  blurRadius: 28,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Center(
              child: Transform.rotate(
                angle: -math.pi / 12,
                child: Icon(
                  Icons.account_balance_wallet_rounded,
                  size: 40,
                  color: background,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
