import 'package:flutter/material.dart';

class NewTagChip extends StatelessWidget {
  const NewTagChip({super.key});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: const Text(
        'NEW',
        style: TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: Colors.green.shade400,
      side: BorderSide.none,
    );
  }
}