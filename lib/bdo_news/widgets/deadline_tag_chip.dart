import 'package:flutter/material.dart';

class DeadlineTagChip extends StatelessWidget {
  final int count;

  const DeadlineTagChip({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        count > 0 ? 'D-$count' : 'D-Day',
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: Colors.red.shade600,
      side: BorderSide.none,
    );
  }
}