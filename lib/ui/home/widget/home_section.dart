import 'package:flutter/material.dart';

class HomeSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const HomeSection({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
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
          ),
          const Divider(),
          child,
        ],
      ),
    );
  }
}
