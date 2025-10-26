import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget {
  final bool online;
  final String titulo;
  final DateTime hora;

  const AppHeader({
    super.key,
    required this.online,
    required this.titulo,
    required this.hora,
  });

  String _fmt(DateTime t) =>
      "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}";

  @override
  Widget build(BuildContext context) {
  final cs = Theme.of(context).colorScheme;
  final Color bgColor = online ? cs.tertiaryContainer : cs.errorContainer;
  final Color fgColor = online ? cs.onTertiaryContainer : cs.onErrorContainer;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
      Icon(online ? Icons.battery_charging_full : Icons.battery_alert,
        color: fgColor, size: 20),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                online ? 'ONLINE' : 'OFFLINE',
                style: TextStyle(color: fgColor, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          titulo,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
                color: cs.onSurface,
              ) ?? const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Theme.of(context).dividerColor, width: 1.4),
          ),
          child: Text(
            _fmt(hora),
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 22,
              letterSpacing: 2,
              color: cs.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
