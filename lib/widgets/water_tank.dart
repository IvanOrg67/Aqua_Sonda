import 'package:flutter/material.dart';

class WaterTank extends StatelessWidget {
  final double value; // 0..1
  final String caption;
  const WaterTank({super.key, required this.value, required this.caption});

  @override
  Widget build(BuildContext context) {
    final borderColor = Theme.of(context).dividerColor;
    final fillColor = Theme.of(context).colorScheme.primary.withValues(alpha: 0.6);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 160,
          height: 120,
          child: CustomPaint(painter: _TankPainter(value, borderColor, fillColor)),
        ),
        const SizedBox(height: 6),
        Text(caption, style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _TankPainter extends CustomPainter {
  final double v;
  final Color borderColor;
  final Color fillColor;
  _TankPainter(this.v, this.borderColor, this.fillColor);
  @override
  void paint(Canvas canvas, Size size) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(12),
    );
    final border = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = borderColor;
    canvas.drawRRect(rect, border);

  final fill = Paint()..color = fillColor;
    final h = size.height * v.clamp(0,1);
    canvas.clipRRect(rect);
    canvas.drawRect(Rect.fromLTWH(0, size.height - h, size.width, h), fill);
  }
  @override
  bool shouldRepaint(covariant _TankPainter oldDelegate) => oldDelegate.v != v;
}
