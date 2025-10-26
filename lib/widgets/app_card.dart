import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets margin;
  final EdgeInsets padding;

  const AppCard({
    super.key,
    required this.child,
    this.margin = const EdgeInsets.all(12),
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: margin,
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}
