import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddNotificationTimeDialog extends StatefulWidget {
  final List<int> notificationTimes;

  const AddNotificationTimeDialog({super.key, required this.notificationTimes});

  @override
  State<AddNotificationTimeDialog> createState() =>
      _AddNotificationTimeDialogState();
}

class _AddNotificationTimeDialogState extends State<AddNotificationTimeDialog> {
  final TextEditingController textEditingController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  String? validate(String? value) {
    if (value?.isEmpty ?? true) {
      return context.tr("validator.empty");
    }
    final parsed = int.parse(value!);
    if (parsed == 0) {
      return context.tr("validator.zero");
    } else if (widget.notificationTimes.contains(parsed)) {
      return context.tr("world boss.already set");
    }
    return null;
  }

  void increase() {
    final parsed = int.tryParse(textEditingController.text);
    if (parsed == null) {
      textEditingController.text = 1.toString();
    } else if (parsed >= 99) {
      textEditingController.text = 99.toString();
    } else {
      textEditingController.text = (parsed + 1).toString();
    }
  }

  void decrease() {
    final parsed = int.tryParse(textEditingController.text);
    if (parsed == null) {
      textEditingController.text = 1.toString();
    } else if (parsed <= 1) {
      textEditingController.text = 1.toString();
    } else {
      textEditingController.text = (parsed - 1).toString();
    }
  }

  void confirm() {
    if (formKey.currentState?.validate() ?? false) {
      final parsed = int.parse(textEditingController.text);
      Navigator.of(context).pop(parsed);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.tr("world boss.add")),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              key: formKey,
              child: TextFormField(
                controller: textEditingController,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^(\d{0,2})')),
                ],
                decoration: const InputDecoration(suffixText: "minutes"),
                autovalidateMode: AutovalidateMode.always,
                validator: validate,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                onPressed: decrease,
                icon: const Icon(Icons.exposure_minus_1),
              ),
              IconButton(
                onPressed: increase,
                icon: const Icon(Icons.plus_one),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.tr("cancel")),
        ),
        TextButton(
          onPressed: confirm,
          child: Text(context.tr("confirm")),
        ),
      ],
    );
  }
}
