import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show toBeginningOfSentenceCase;
import 'package:karanda/common/api.dart';
import 'package:karanda/settings/settings_notifier.dart';
import 'package:provider/provider.dart';

class ClassSymbolWidget extends StatefulWidget {
  final double size;
  final String className;

  const ClassSymbolWidget({super.key, this.size = 32.0, required this.className});

  @override
  State<ClassSymbolWidget> createState() => _ClassSymbolWidgetState();
}

class _ClassSymbolWidgetState extends State<ClassSymbolWidget> {
  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: toBeginningOfSentenceCase(widget.className),
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Image.network(
          "${Api.classSymbol}/${widget.className}.png",
          fit: BoxFit.fill,
          color: context.watch<SettingsNotifier>().darkMode ? null : Colors.black,
        ),
      ),
    );
  }
}
