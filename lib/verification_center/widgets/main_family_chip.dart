import 'package:flutter/material.dart';

class MainFamilyChip extends StatelessWidget {
  const MainFamilyChip({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.0),
      child: Chip(
        label: Text('메인'),
        padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        backgroundColor: Colors.blueAccent,
        side: BorderSide.none,
      ),
    );
  }
}