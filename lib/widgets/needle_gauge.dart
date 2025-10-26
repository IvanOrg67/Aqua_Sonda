import 'dart:math' as math;
import 'package:flutter/material.dart';

class NeedleGauge extends StatelessWidget {
  final double value; // 0..1
  final double size;
  final String? label;
  const NeedleGauge({super.key, required this.value, this.size = 220, this.label});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 0.7,
      child: CustomPaint(
        painter: _NeedleGaugePainter(
          value: value,
          baseColor: Theme.of(context).dividerColor,
          needleColor: Theme.of(context).colorScheme.onSurface,
        ),
        child: label == null
            ? null
            : Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(label!, style: const TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
      ),
    );
  }
}

class _NeedleGaugePainter extends CustomPainter {
  final double value;
  final Color baseColor;
  final Color needleColor;
  _NeedleGaugePainter({required this.value, required this.baseColor, required this.needleColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.9);
    final radius = size.width * 0.42;

    final bg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..color = baseColor;

    // arco base
    final start = math.pi; // 180°
    final sweep = math.pi; // semi círculo
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(rect, start, sweep, false, bg);

    // segmentos rojos/amarillos/verdes
    void segment(Color c, double from, double to) {
      final p = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.butt
        ..strokeWidth = 18
        ..color = c;
      canvas.drawArc(rect, start + sweep * from, sweep * (to - from), false, p);
    }

    segment(Colors.red.shade700, 0.00, 0.25);
    segment(Colors.orange.shade700, 0.25, 0.75);
    segment(Colors.green.shade600, 0.75, 1.00);

    // aguja
    final angle = start + sweep * value.clamp(0, 1);
    final needleLen = radius * 0.9;
    final tip = Offset(center.dx + needleLen * math.cos(angle), center.dy + needleLen * math.sin(angle));
    final needle = Paint()
      ..strokeWidth = 3
      ..color = needleColor;
    canvas.drawLine(center, tip, needle);
    canvas.drawCircle(center, 6, Paint()..color = needleColor);
  }

  @override
  bool shouldRepaint(covariant _NeedleGaugePainter oldDelegate) => oldDelegate.value != value;
}
