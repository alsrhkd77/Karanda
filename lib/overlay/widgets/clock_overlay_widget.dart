import 'package:flutter/material.dart';
import 'package:flutter_box_transform/flutter_box_transform.dart';
import 'package:karanda/common/date_time_extension.dart';
import 'package:karanda/common/real_time.dart';
import 'package:karanda/common/time_of_day_extension.dart';
import 'package:karanda/overlay/overlay_data_controller.dart';
import 'package:karanda/overlay/utils/box_utils.dart';
import 'package:karanda/widgets/custom_angular_handle.dart';
import 'package:karanda/widgets/loading_indicator.dart';

class ClockOverlayWidget extends StatefulWidget {
  final bool editMode;
  final bool enabled;

  const ClockOverlayWidget(
      {super.key, required this.editMode, required this.enabled});

  @override
  State<ClockOverlayWidget> createState() => _ClockOverlayWidgetState();
}

class _ClockOverlayWidgetState extends State<ClockOverlayWidget> {
  final String key = 'clock overlay';
  final OverlayDataController dataController = OverlayDataController();
  final _boxController = TransformableBoxController();
  RealTime realTime = RealTime();

  @override
  void initState() {
    super.initState();
    loadBoxProperties();
  }

  Future<void> loadBoxProperties() async {
    Rect rect = await BoxUtils.loadBoxRect(key) ??
        Rect.fromLTWH(
          dataController.screenSize.width - 320,
          70,
          260,
          100,
        );
    _boxController.setRect(rect);
  }

  @override
  Widget build(BuildContext context) {
    return TransformableBox(
      controller: _boxController,
      resizable: widget.editMode,
      handleAlignment: HandleAlignment.inside,
      onChanged: (event, detail) => BoxUtils.saveRect(key, event.rect),
      cornerHandleBuilder: (context, handle) {
        return CustomAngularHandle(handle: handle);
      },
      sideHandleBuilder: (context, handle) {
        return CustomAngularHandle(handle: handle);
      },
      contentBuilder: (context, rect, flip) {
        return AnimatedOpacity(
          opacity: widget.editMode
              ? 1.0
              : widget.enabled
                  ? 1.0
                  : 0.0,
          duration: const Duration(milliseconds: 500),
          child: Card(
            elevation: 0.0,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: StreamBuilder(
                stream: realTime.stream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const FittedBox(
                      fit: BoxFit.contain,
                      child: LoadingIndicator(),
                    );
                  }
                  TimeOfDay now = TimeOfDay.fromDateTime(snapshot.requireData);
                  return FittedBox(
                    fit: BoxFit.contain,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text.rich(TextSpan(
                          children: [
                            TextSpan(
                                text: '${now.dayPeriod()} ',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                            ),
                            TextSpan(
                              text: now.hourOfPeriod.toString().padLeft(2, '0'),
                            ),
                            TextSpan(
                              text: snapshot.requireData.format(':'),
                              style: snapshot.requireData.second % 2 == 1
                                  ? null
                                  : TextStyle(
                                      color: Colors.grey.withOpacity(0.8)),
                            ),
                            TextSpan(
                                text: now.minute.toString().padLeft(2, '0')),
                          ],
                          style: Theme.of(context)
                              .textTheme
                              .headlineLarge
                              ?.copyWith(letterSpacing: 1.5),
                        )),
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text:
                                    snapshot.requireData.format('yyyy.MM.dd '),
                              ),
                              TextSpan(
                                text: snapshot.requireData.dayOfWeek(),
                              ),
                            ],
                          ),
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.grey.withOpacity(0.6)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
