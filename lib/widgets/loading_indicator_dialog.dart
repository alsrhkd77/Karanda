import 'package:flutter/material.dart';
import 'package:karanda/widgets/loading_indicator.dart';

class LoadingIndicatorDialog extends StatelessWidget {
  final String title;
  final double size;

  const LoadingIndicatorDialog({
    Key? key,
    this.title = 'Processing',
    this.size = 90,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [LoadingIndicator(size: size)],
      ),
      contentPadding: const EdgeInsets.all(24.0),
    );
  }
}
