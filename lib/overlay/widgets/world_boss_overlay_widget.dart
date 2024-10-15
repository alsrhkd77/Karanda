import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_box_transform/flutter_box_transform.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:karanda/common/real_time.dart';
import 'package:karanda/common/server_time.dart';
import 'package:karanda/common/time_of_day_extension.dart';
import 'package:karanda/overlay/overlay_data_controller.dart';
import 'package:karanda/overlay/utils/box_utils.dart';
import 'package:karanda/widgets/custom_angular_handle.dart';
import 'package:karanda/widgets/loading_indicator.dart';

class WorldBossOverlayWidget extends StatefulWidget {
  final bool editMode;
  final bool enabled;

  const WorldBossOverlayWidget(
      {super.key, required this.editMode, required this.enabled});

  @override
  State<WorldBossOverlayWidget> createState() => _WorldBossOverlayWidgetState();
}

class _WorldBossOverlayWidgetState extends State<WorldBossOverlayWidget> {
  double opacity = 0.0;
  Timer? timer;
  ServerTime serverTime = ServerTime();
  RealTime realTime = RealTime();
  final key = "world boss overlay";
  final OverlayDataController _dataController = OverlayDataController();
  final _boxController = TransformableBoxController();

  @override
  void initState() {
    super.initState();
    loadBoxProperties();
    WidgetsBinding.instance
        .addPostFrameCallback((timeStamp) => registerCallback());
  }

  void registerCallback() {
    _dataController.registerCallback(
        method: "alert world boss",
        callback: () {
          setState(() {
            opacity = 1.0;
          });
          if (timer != null && timer!.isActive) {
            timer!.cancel();
          }
          timer = Timer(const Duration(seconds: 10), () {
            setState(() {
              opacity = 0.0;
            });
          });
        });
  }

  Future<void> loadBoxProperties() async {
    Rect rect = await BoxUtils.loadBoxRect(key) ??
        Rect.fromLTWH(
          _dataController.screenSize.width - 380,
          _dataController.screenSize.height - 200,
          320,
          140,
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
          duration: const Duration(milliseconds: 500),
          opacity: widget.editMode
              ? 1.0
              : widget.enabled
                  ? opacity
                  : 0.0,
          child: Card(
            color: Colors.black.withOpacity(0.8),
            elevation: 0.0,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
              child: StreamBuilder(
                stream: _dataController.nextBossStream,
                builder: (context, nextBoss) {
                  if (!nextBoss.hasData) {
                    return const LoadingIndicator(
                      size: 40,
                    );
                  }
                  DateTime spawnTime =
                      DateTime.parse(nextBoss.requireData["spawnTime"]);
                  String names = nextBoss.requireData["names"];
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: const Icon(FontAwesomeIcons.dragon),
                        title: Text(
                          '월드 보스',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        trailing: StreamBuilder(
                          stream: realTime.stream,
                          builder: (context, realTimeSnapshot) {
                            return Text(
                              realTimeSnapshot.hasData
                                  ? TimeOfDay.fromDateTime(
                                          realTimeSnapshot.requireData)
                                      .timeWithoutPeriod()
                                  : '',
                              style: Theme.of(context).textTheme.titleMedium,
                            );
                          },
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: StreamBuilder(
                              stream: serverTime.stream,
                              builder: (context, serverTimeSnapshot) {
                                if (!serverTimeSnapshot.hasData) {
                                  return const Text("");
                                }
                                Duration diff = spawnTime
                                    .difference(serverTimeSnapshot.requireData);
                                TextStyle? style =
                                    Theme.of(context).textTheme.titleLarge;
                                return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    /*
                                  Text(
                                    timeOfDay.timeWithoutPeriod(),
                                    style: style,
                                  ),
                                   */
                                    /*
                                    SizedBox(
                                      width: 200,
                                      child: AutoSizeText(
                                        '$names',
                                        maxLines: 2,
                                        textAlign: TextAlign.center,
                                        style: style,
                                      ),
                                    ),
                                     */
                                    Text(
                                      names,
                                      //'불가살, 우투리\n누베르, 오핀',
                                      style: style,
                                      textAlign: TextAlign.center,
                                    ),
                                    Text(
                                      diff.isNegative
                                          ? '출현!'
                                          : '${diff.inMinutes + 1}분 뒤',
                                      style: style,
                                    )
                                  ],
                                );
                              }),
                        ),
                      ),
                    ],
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
