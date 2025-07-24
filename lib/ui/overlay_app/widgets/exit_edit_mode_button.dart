import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:karanda/ui/overlay_app/controllers/overlay_app_controller.dart';
import 'package:provider/provider.dart';

class ExitEditModeButton extends StatelessWidget {
  const ExitEditModeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      width: 200,
      height: 80,
      child: Consumer(
        builder: (context, OverlayAppController controller, child) {
          return AnimatedOpacity(
            opacity: controller.editMode ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: child,
          );
        },
        child: ElevatedButton(
          onPressed: context.read<OverlayAppController>().exitEditMode,
          child: Text(
            context.tr("finish"),
            style: Theme.of(context).textTheme.displaySmall,
          ),
        ),
      ),
    );
  }
}
