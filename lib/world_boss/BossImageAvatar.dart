import 'package:flutter/material.dart';
import 'package:karanda/common/api.dart';

class BossImageAvatar extends StatelessWidget {
  final String name;

  const BossImageAvatar({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        foregroundImage: NetworkImage(
          '${Api.worldBossPortrait}/$name.png',
        ),
      ),
    );
  }
}