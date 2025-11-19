import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:karanda/enums/overlay_features.dart';
import 'package:karanda/ui/overlay_app/controllers/bdo_time_overlay_controller.dart';
import 'package:karanda/ui/overlay_app/widgets/overlay_widget.dart';
import 'package:provider/provider.dart';

class BdoTimeOverlayWidget extends StatelessWidget {
  final double width;

  const BdoTimeOverlayWidget({super.key, required this.width});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => BdoTimeOverlayController(
        service: context.read(),
        key: OverlayFeatures.bdoTime,
        defaultRect: Rect.fromLTWH(width - 580, 70, 240, 100),
        constraints: const BoxConstraints(minWidth: 130, minHeight: 50),
        timeRepository: context.read(),
      ),
      builder: (context, child) {
        return Consumer(
          builder: (context, BdoTimeOverlayController controller, child) {
            return OverlayWidget(
              feature: controller.key,
              boxController: controller.boxController,
              resizable: controller.editMode,
              show: controller.show,
              opacity: controller.opacity,
              contentBuilder: (context, rect, flip) {
                return Padding(
                  padding: const EdgeInsets.all(12),
                  child: FittedBox(
                    child: Row(
                      spacing: 8.0,
                      children: [
                        _Progress(
                          isNight: controller.bdoTime.isNight,
                          progress: controller.bdoTime.progress,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.tr("overlay.nextTransition"),
                              style: TextTheme.of(context)
                                  .bodySmall
                                  ?.copyWith(color: Colors.grey),
                            ),
                            _Time(value: controller.remaining),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _Progress extends StatelessWidget {
  final bool isNight;
  final double progress;

  const _Progress({super.key, required this.isNight, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.passthrough,
      alignment: Alignment.center,
      children: [
        Icon(
          isNight ? Icons.nights_stay : Icons.sunny,
          color: Colors.amberAccent,
        ),
        CircularProgressIndicator(
          strokeWidth: 2.0,
          color: isNight ? Colors.deepPurpleAccent : Colors.orange,
          value: progress,
        ),
      ],
    );
  }
}

class _Time extends StatelessWidget {
  final Duration value;

  const _Time({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    final style = TextTheme.of(context).headlineMedium;
    if (value.inHours > 0) {
      return Text(
        "${value.inHours.toString().padLeft(2, '0')}h ${(value.inMinutes % 60).toString().padLeft(2, '0')}m",
        style: style,
      );
    } else if (value.inMinutes > 0) {
      return Text(
        "${value.inMinutes.toString().padLeft(2, '0')}m ${(value.inSeconds % 60).toString().padLeft(2, '0')}s",
        style: style,
      );
    }
    return Text(
      "${value.inSeconds.toString().padLeft(2, '0')}sec",
      style: style,
    );
  }
}
