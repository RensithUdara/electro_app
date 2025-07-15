import 'dart:math';

import 'package:flutter/material.dart';

class ParticleAnimation extends StatefulWidget {
  final int particleCount;
  final Color particleColor;
  final double maxRadius;

  const ParticleAnimation({
    super.key,
    this.particleCount = 20,
    this.particleColor = Colors.white,
    this.maxRadius = 3.0,
  });

  @override
  State<ParticleAnimation> createState() => _ParticleAnimationState();
}

class _ParticleAnimationState extends State<ParticleAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Particle> particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();

    particles = List.generate(
      widget.particleCount,
      (index) => Particle(
        maxRadius: widget.maxRadius,
        color: widget.particleColor,
      ),
    );
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
      builder: (context, child) {
        return CustomPaint(
          painter: ParticlePainter(
            particles: particles,
            animation: _controller.value,
          ),
          size: const Size(400, 400),
        );
      },
    );
  }
}

class Particle {
  final double initialX;
  final double initialY;
  final double radius;
  final double speed;
  final double direction;
  final Color color;
  final double opacity;

  Particle({
    required double maxRadius,
    required Color color,
  })  : initialX = Random().nextDouble() * 400,
        initialY = Random().nextDouble() * 400,
        radius = Random().nextDouble() * maxRadius + 1,
        speed = Random().nextDouble() * 50 + 20,
        direction = Random().nextDouble() * 2 * pi,
        color = color,
        opacity = Random().nextDouble() * 0.8 + 0.2;

  Offset getPosition(double animationValue) {
    final progress = (animationValue * speed) % 400;
    final x = (initialX + cos(direction) * progress) % 400;
    final y = (initialY + sin(direction) * progress) % 400;
    return Offset(x, y);
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double animation;

  ParticlePainter({
    required this.particles,
    required this.animation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    for (final particle in particles) {
      final position = particle.getPosition(animation);
      paint.color = particle.color.withOpacity(particle.opacity * 0.6);

      // Add a glow effect
      paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      canvas.drawCircle(position, particle.radius * 1.5, paint);

      // Draw the main particle
      paint.maskFilter = null;
      paint.color = particle.color.withOpacity(particle.opacity);
      canvas.drawCircle(position, particle.radius, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
