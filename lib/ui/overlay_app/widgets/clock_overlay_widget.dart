import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:karanda/enums/overlay_features.dart';
import 'package:karanda/ui/overlay_app/controllers/clock_overlay_controller.dart';
import 'package:karanda/ui/overlay_app/widgets/overlay_widget.dart';
import 'package:provider/provider.dart';

class ClockOverlayWidget extends StatelessWidget {
  final double width;

  const ClockOverlayWidget({super.key, required this.width});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ClockOverlayController(
        service: context.read(),
        key: OverlayFeatures.clock,
        defaultRect: Rect.fromLTWH(width - 320, 70, 260, 100),
        constraints: const BoxConstraints(minWidth: 130, minHeight: 50),
        timeRepository: context.read(),
      ),
      child: Consumer(
        builder: (context, ClockOverlayController controller, child) {
          return OverlayWidget(
            feature: controller.key,
            boxController: controller.boxController,
            resizable: controller.editMode,
            show: controller.show,
            contentBuilder: (context, rect, flip) {
              return Padding(
                padding: const EdgeInsets.all(10),
                child: FittedBox(
                  child: Column(
                    children: [
                      _Time(currentTime: controller.now),
                      _Date(now: controller.now),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _Time extends StatelessWidget {
  final DateTime currentTime;

  const _Time({super.key, required this.currentTime});

  @override
  Widget build(BuildContext context) {
    return Text(
      DateFormat('HH:mm:ss').format(currentTime),
      style: TextTheme.of(context).headlineLarge,
    );
  }
}

class _Date extends StatelessWidget {
  final DateTime now;

  const _Date({super.key, required this.now});

  @override
  Widget build(BuildContext context) {
    final locale = context.locale.toStringWithSeparator();
    return Text(
      DateFormat.yMMMEd(locale).format(now),
      style: TextTheme.of(context).bodySmall?.copyWith(color: Colors.grey),
    );
  }
}
