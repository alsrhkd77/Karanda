import 'package:flutter/material.dart';
import 'package:karanda/ui/core/theme/dimes.dart';

class PageBase extends StatelessWidget {
  final List<Widget> children;
  final double? width;
  final double? itemExtent;
  final double? cacheExtent;

  const PageBase({
    super.key,
    required this.children,
    this.width,
    this.itemExtent,
    this.cacheExtent,
  });

  @override
  Widget build(BuildContext context) {
    final pageWidth = width ?? MediaQuery.sizeOf(context).width;
    return Center(
      child: ListView(
        padding: Dimens.constrainedPagePadding(pageWidth),
        itemExtent: itemExtent,
        cacheExtent: cacheExtent,
        children: children,
      ),
    );
  }
}
