import 'package:flutter/material.dart';

class StatBar extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  const StatBar({super.key, required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.amberAccent),
        const SizedBox(width: 8),
        Text('$label: $value', style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
