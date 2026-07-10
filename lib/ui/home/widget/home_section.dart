import 'package:flutter/material.dart';

class HomeSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final Widget? trailing;

  const HomeSection({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          ListTile(
            leading: Icon(icon),
            title: Text(
              title,
              style: TextTheme.of(context)
                  .titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            trailing: trailing,
          ),
          const Divider(),
          child,
        ],
      ),
    );
  }
}
