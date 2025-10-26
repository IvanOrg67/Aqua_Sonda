import 'package:flutter/material.dart';

class MetricTile extends StatelessWidget {
  final Widget leading;
  final String primary;
  final String secondary;
  final Color? valueColor;

  const MetricTile({
    super.key,
    required this.leading,
    required this.primary,
    required this.secondary,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 42, height: 42, child: leading),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  primary,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: valueColor ?? Theme.of(context).colorScheme.onSurface,
                      ) ?? TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: valueColor ?? Theme.of(context).colorScheme.onSurface,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  secondary,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
