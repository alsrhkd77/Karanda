import 'package:flutter/material.dart';
import 'package:karanda/ui/core/theme/dimes.dart';

class PageBase extends StatelessWidget {
  final List<Widget> children;
  final double? width;

  const PageBase({super.key, required this.children, this.width});

  @override
  Widget build(BuildContext context) {
    final pageWidth = width ?? MediaQuery.sizeOf(context).width;
    return Center(
      child: ListView(
        padding: Dimens.constrainedPagePadding(pageWidth),
        children: children,
      ),
    );
  }
}

