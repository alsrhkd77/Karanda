import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_box_transform/flutter_box_transform.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:karanda/common/date_time_extension.dart';
import 'package:karanda/common/real_time.dart';
import 'package:karanda/common/server_time.dart';
import 'package:karanda/overlay/overlay_data_controller.dart';
import 'package:karanda/overlay/utils/box_utils.dart';
import 'package:karanda/overlay/widgets/edit_mode_card_widget.dart';
import 'package:karanda/widgets/custom_angular_handle.dart';
import 'package:karanda/widgets/loading_indicator.dart';

class WorldBossOverlayWidget extends StatefulWidget {
  final bool editMode;
  final bool enabled;
  final bool showAlways;

  const WorldBossOverlayWidget({
    super.key,
    required this.editMode,
    required this.enabled,
    required this.showAlways,
  });

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
    _boxController.setConstraints(const BoxConstraints(
      minWidth: 300,
      minHeight: 120,
    ));
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
        return StreamBuilder(
          stream: _dataController.nextBossStream,
          builder: (context, nextBoss) {
            if (widget.editMode) {
              return const EditModeCardWidget(title: "월드 보스");
            } else if (!nextBoss.hasData) {
              return Opacity(
                opacity: widget.enabled ? 1.0 : 0.0,
                child: const Card(
                  child: LoadingIndicator(
                    size: 40,
                  ),
                ),
              );
            }
            DateTime spawnTime =
                DateTime.parse(nextBoss.requireData["spawnTime"]);
            String names = nextBoss.requireData["names"];
            return AnimatedOpacity(
              opacity: widget.enabled
                  ? widget.showAlways
                      ? 1.0
                      : opacity
                  : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 12.0),
                  child: Column(
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
                        trailing: Text(
                          spawnTime.format('HH:mm'),
                          style: Theme.of(context).textTheme.titleMedium,
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
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
