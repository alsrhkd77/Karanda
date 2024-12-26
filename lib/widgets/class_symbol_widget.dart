import 'package:flutter/material.dart';
import 'package:karanda/common/api.dart';

class ClassSymbolWidget extends StatefulWidget {
  final double size;
  final String className;

  const ClassSymbolWidget(
      {super.key, this.size = 32.0, required this.className});

  @override
  State<ClassSymbolWidget> createState() => _ClassSymbolWidgetState();
}

class _ClassSymbolWidgetState extends State<ClassSymbolWidget> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Image.network(
        "${Api.classSymbol}/${widget.className}.png",
        fit: BoxFit.fill,
        color: Theme.of(context).brightness == Brightness.dark
            ? null
            : Colors.black,
      ),
    );
  }
}
