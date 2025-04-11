import 'package:flutter/material.dart';

class Section extends StatelessWidget {
  final IconData? icon;
  final String title;
  final Widget child;

  const Section({
    super.key,
    this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Column(
        children: [
          ListTile(
            leading: icon == null ? null : Icon(icon),
            title: Text(title),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            clipBehavior: Clip.antiAlias,
            child: child,
          ),
        ],
      ),
    );
  }
}
