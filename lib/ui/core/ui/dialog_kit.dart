import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'loading_indicator.dart';

class DialogKit {
  BuildContext context;

  DialogKit.of(this.context);

  Future<void> loadingIndicator({
    String title = "Processing",
    double size = 90,
  }) async {
    return await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [LoadingIndicator(size: size)],
          ),
          contentPadding: const EdgeInsets.all(24.0),
        );
      },
    );
  }

  Future<bool?> doubleCheck({
    Widget? icon,
    required Widget title,
    required Widget content,
  }) async {
    return await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          icon: icon,
          title: title,
          content: content,
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(context.tr("cancel")),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(context.tr("confirm")),
            ),
          ],
        );
      },
    );
  }
}
