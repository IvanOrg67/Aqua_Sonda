import 'package:flutter/material.dart';

class Thermometer extends StatelessWidget {
  final double value; // 0..1
  final String label;
  const Thermometer({super.key, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final borderColor = Theme.of(context).dividerColor;
    final fillColor = Theme.of(context).colorScheme.primary;
    return Column(
      children: [
        SizedBox(
           width: 28,
          height: 120,
          child: CustomPaint(painter: _ThermoPainter(value, borderColor, fillColor)),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ThermoPainter extends CustomPainter {
  final double v;
  final Color borderColor;
  final Color fillColor;
  _ThermoPainter(this.v, this.borderColor, this.fillColor);
  @override
  void paint(Canvas canvas, Size size) {
    final r = 10.0;
    final bulb = Offset(size.width/2, size.height - r);
    final tubeTop = 6.0;
    final tubeRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width/2 - 6, tubeTop, 12, size.height - r*2),
      const Radius.circular(6),
    );
    final border = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = borderColor;
    canvas.drawRRect(tubeRect, border);
    canvas.drawCircle(bulb, r, border);

    final fill = Paint()..color = fillColor;
    final h = (size.height - r*2 - tubeTop) * v.clamp(0,1);
    final y = size.height - r*2 - h + tubeTop;
    canvas.clipRRect(tubeRect);
    canvas.drawRect(Rect.fromLTWH(0, y, size.width, h + 2), fill);
    canvas.restore();
    canvas.drawCircle(bulb, r-2, fill);
  }
  @override
  bool shouldRepaint(covariant _ThermoPainter oldDelegate) => oldDelegate.v != v;
}
