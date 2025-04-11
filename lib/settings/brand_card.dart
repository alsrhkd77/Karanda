import 'package:flutter/material.dart';

class BrandCard extends StatelessWidget {
  final String assetPath;
  final Function onTap;
  final bool hasReverse;

  const BrandCard({
    super.key,
    required this.assetPath,
    required this.onTap,
    this.hasReverse = false,
  });

  @override
  Widget build(BuildContext context) {
    final path = Theme.of(context).brightness == Brightness.dark && hasReverse
        ? assetPath.replaceAll('.', '_reverse.')
        : assetPath;
    return Container(
      constraints: const BoxConstraints(maxWidth: 500),
      child: Card(
        clipBehavior: Clip.antiAlias,
        margin: const EdgeInsets.all(24.0),
        child: InkWell(
          onTap: () => onTap(),
          child: Image.asset(path, fit: BoxFit.cover),
        ),
      ),
    );
  }
}
