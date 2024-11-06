import 'package:flutter/material.dart';
import 'package:karanda/common/global_properties.dart';

class CustomBase extends StatefulWidget {
  final List<Widget> children;

  const CustomBase({super.key, required this.children});

  @override
  State<CustomBase> createState() => _CustomBaseState();
}

class _CustomBaseState extends State<CustomBase> {
  final ScrollController controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final padding = GlobalProperties.scrollViewHorizontalPadding(width);
    return Center(
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: padding),
        children: widget.children,
      ),
    );
  }
}
