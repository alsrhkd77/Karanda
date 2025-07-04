import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class UnregisterDialog extends StatefulWidget {
  const UnregisterDialog({super.key});

  @override
  State<UnregisterDialog> createState() => _UnregisterDialogState();
}

class _UnregisterDialogState extends State<UnregisterDialog> {
  final formKey = GlobalKey<FormState>();
  final String targetText = 'UNREGISTER';

  String? validator(String? value) {
    if (value == null || value.isEmpty) {
      return context.tr("validator.empty");
    } else if (value != targetText) {
      return context.tr("validator.fillWith", args: ["'$targetText'"]);
    }
    return null;
  }

  void confirm() {
    if (formKey.currentState?.validate() ?? false) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Unregister"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Form(
            key: formKey,
            child: TextFormField(
              maxLines: 1,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: InputDecoration(
                hintText: targetText,
              ),
              validator: validator,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.tr("cancel")),
        ),
        TextButton(
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          onPressed: confirm,
          child: Text(context.tr("confirm")),
        ),
      ],
    );
  }
}
