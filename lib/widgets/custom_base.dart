import 'package:flutter/material.dart';
import 'package:karanda/common/global_properties.dart';

class CustomBase extends StatelessWidget {
  final List<Widget> children;

  const CustomBase({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return Center(
      child: ListView(
        padding: GlobalProperties.constrainedScrollViewPadding(width),
        children: children,
      ),
    );
  }
}

