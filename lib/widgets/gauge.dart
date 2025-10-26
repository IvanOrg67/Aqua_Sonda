import 'package:flutter/material.dart';

class Gauge extends StatelessWidget {
  final double value; // 0..1
  final String centerText; // ej "27°C"
  final double size;

  const Gauge({
    super.key,
    required this.value,
    required this.centerText,
    this.size = 180,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final trackColor = cs.onSurface.withValues(alpha: 0.14);
    final gradColors = <Color>[cs.primary, cs.secondary];
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _GaugePainter(
          value: value,
          trackColor: trackColor,
          gradientColors: gradColors,
        ),
        child: Center(
          child: Text(centerText,
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface)),
        ),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double value;
  final Color trackColor;
  final List<Color> gradientColors;
  _GaugePainter({
    required this.value,
    required this.trackColor,
    required this.gradientColors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width * 0.42;

    // Fondo
    final bg = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), 3.14 * 0.75,
        3.14 * 1.5, false, bg);

    // Progreso (degradado azul)
    final gradient = SweepGradient(
      startAngle: 3.14 * 0.75,
      endAngle: 3.14 * (0.75 + 1.5 * value.clamp(0, 1)),
      colors: gradientColors,
    );
    final fg = Paint()
      ..shader =
          gradient.createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), 3.14 * 0.75,
        3.14 * 1.5 * value.clamp(0, 1), false, fg);
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) =>
      oldDelegate.value != value;
}
