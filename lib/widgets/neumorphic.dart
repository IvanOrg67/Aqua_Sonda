import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class Neu {
  static BoxDecoration convex({
    double radius = 18,
    Color? base,
    double intensity = 0.18, // 0..1, controla cuánta "profundidad" se dibuja
  }) {
    final bg = base ?? AppColors.surface;
    // Aproximamos tema oscuro por luminancia del color base
    final isDark = bg.computeLuminance() < 0.25;

    // Parámetros adaptados por tema e intensidad
  final double blur = isDark ? 12 + 10 * intensity : 8 + 8 * intensity;
  final Offset lightOffset = const Offset(-3, -3);
  final Offset darkOffset = const Offset(3, 3);
  final double lightAlpha = isDark ? 0.05 + 0.06 * intensity : 0.28 + 0.24 * intensity;
  final double darkAlpha = isDark ? 0.20 + 0.18 * intensity : 0.05 + 0.05 * intensity;

    return BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          color: Colors.white.withValues(alpha: lightAlpha.clamp(0, 1)),
          offset: lightOffset,
          blurRadius: blur,
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: darkAlpha.clamp(0, 1)),
          offset: darkOffset,
          blurRadius: blur + 2,
        ),
      ],
    );
  }

  static BoxDecoration concave({
    double radius = 18,
    Color? base,
  }) {
    final bg = base ?? AppColors.surface;
    return BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          _lighten(bg, 0.06),
          _darken(bg, 0.06),
        ],
      ),
    );
  }

  static Color _lighten(Color c, double amount) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness + amount).clamp(0, 1)).toColor();
  }

  static Color _darken(Color c, double amount) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness - amount).clamp(0, 1)).toColor();
  }
}

class NeumorphicButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final double radius;
  final EdgeInsets padding;
  final bool pressed;

  const NeumorphicButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.radius = 18,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    this.pressed = false,
  });

  @override
  Widget build(BuildContext context) {
    final decoration =
        pressed ? Neu.concave(radius: radius) : Neu.convex(radius: radius);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      decoration: decoration,
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: onPressed,
        child: Padding(padding: padding, child: Center(child: child)),
      ),
    );
  }
}

class NeumorphicCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets margin;
  final EdgeInsets padding;
  final double radius;

  const NeumorphicCard({
    super.key,
    required this.child,
    this.margin = const EdgeInsets.all(12),
    this.padding = const EdgeInsets.all(16),
    this.radius = 18,
  });

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surface;
  final isDark = base.computeLuminance() < 0.25;
  final intensity = isDark ? 0.14 : 0.08; // menos glow en ambos, aún menor en claro
    return Container(
      margin: margin,
      decoration: Neu.convex(radius: radius, base: base, intensity: intensity),
      child: Padding(padding: padding, child: child),
    );
  }
}
