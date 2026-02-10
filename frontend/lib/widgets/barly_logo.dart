import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class BarlyLogo extends StatelessWidget {
  const BarlyLogo({super.key, this.size = 64});

  final double size;

  @override
  Widget build(BuildContext context) {
    final bubbles = <_Bubble>[
      const _Bubble(x: 0.30, y: 0.08, s: 0.31, o: 0.95),
      const _Bubble(x: 0.52, y: 0.12, s: 0.24, o: 0.88),
      const _Bubble(x: 0.19, y: 0.27, s: 0.25, o: 0.92),
      const _Bubble(x: 0.45, y: 0.31, s: 0.28, o: 0.90),
      const _Bubble(x: 0.14, y: 0.50, s: 0.31, o: 0.96),
      const _Bubble(x: 0.52, y: 0.52, s: 0.27, o: 0.86),
      const _Bubble(x: 0.05, y: 0.20, s: 0.15, o: 0.75),
      const _Bubble(x: 0.62, y: 0.03, s: 0.16, o: 0.72),
      const _Bubble(x: 0.68, y: 0.27, s: 0.13, o: 0.68),
      const _Bubble(x: 0.68, y: 0.42, s: 0.12, o: 0.64),
      const _Bubble(x: 0.33, y: 0.67, s: 0.16, o: 0.60),
    ];

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (final bubble in bubbles)
            Positioned(
              left: size * bubble.x,
              top: size * bubble.y,
              child: _BubbleCircle(size: size * bubble.s, opacity: bubble.o),
            ),
        ],
      ),
    );
  }
}

class _BubbleCircle extends StatelessWidget {
  const _BubbleCircle({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.violet800.withValues(alpha: opacity),
            AppTheme.violet600.withValues(alpha: opacity),
            AppTheme.violet500.withValues(alpha: opacity * 0.9),
          ],
        ),
      ),
    );
  }
}

class _Bubble {
  const _Bubble({
    required this.x,
    required this.y,
    required this.s,
    required this.o,
  });

  final double x;
  final double y;
  final double s;
  final double o;
}
