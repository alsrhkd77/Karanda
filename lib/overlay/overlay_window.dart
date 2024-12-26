import 'dart:async';

import 'package:flutter/material.dart';
import 'package:karanda/overlay/overlay_data_controller.dart';
import 'package:karanda/overlay/widgets/adventurer_hub_overlay_widget.dart';
import 'package:karanda/overlay/widgets/boss_hp_scale_indicator_overlay_widget.dart';
import 'package:karanda/overlay/widgets/clock_overlay_widget.dart';
import 'package:karanda/overlay/widgets/world_boss_overlay_widget.dart';

class OverlayWindow extends StatefulWidget {
  const OverlayWindow({super.key});

  @override
  State<OverlayWindow> createState() => _OverlayWindowState();
}

class _OverlayWindowState extends State<OverlayWindow> {
  final OverlayDataController _dataController = OverlayDataController();
  StreamSubscription? streamSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((timestamp) => registerListener());
  }

  void registerListener() {
    streamSubscription =
        _dataController.notificationStream.listen(showNotification);
  }

  void showNotification(String data) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            vertical: 4,
            horizontal: 16,
          ),
          leading: Image.asset(
            "assets/brand/karanda_shape.png",
            height: 30,
            width: 30,
          ),
          title: Text(
            data,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        padding: EdgeInsets.zero,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _dataController.editModeStream,
      builder: (context, editMode) {
        return StreamBuilder(
          stream: _dataController.overlayStatusStream,
          builder: (context, status) {
            if (!editMode.hasData || !status.hasData) {
              return const _OverlayLoadingScaffold();
            }
            return Scaffold(
              backgroundColor: editMode.requireData
                  ? Colors.white.withOpacity(0.25)
                  : Colors.transparent,
              body: Stack(
                fit: StackFit.expand,
                alignment: Alignment.center,
                children: [
                  ClockOverlayWidget(
                    editMode: editMode.requireData,
                    enabled: status.requireData["clock"] ?? false,
                  ),
                  //AdventurerHubOverlayWidget(editMode: editMode.requireData, enabled: status.requireData["adventurerHub"] ?? false,),
                  AdventurerHubOverlayWidget(editMode: editMode.requireData, enabled: true,),
                  WorldBossOverlayWidget(
                    editMode: editMode.requireData,
                    enabled: status.requireData["worldBoss"] ?? false,
                    showAlways:
                        status.requireData["worldBossShowAlways"] ?? false,
                  ),
                  BossHpScaleIndicatorOverlayWidget(
                    editMode: editMode.requireData,
                    enabled:
                        status.requireData["bossHpScaleIndicator"] ?? false,
                  ),
                  Positioned(
                    width: 200,
                    height: 80,
                    child: Opacity(
                      opacity: editMode.requireData ? 1.0 : 0.0,
                      child: ElevatedButton(
                        onPressed: _dataController.disableEditMode,
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            backgroundColor: Colors.indigoAccent),
                        child: Text(
                          "완료",
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    streamSubscription?.cancel();
    super.dispose();
  }
}

class _OverlayLoadingScaffold extends StatelessWidget {
  const _OverlayLoadingScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.transparent,
      body: _OverlayLoadingWidget(),
    );
  }
}

class _OverlayLoadingWidget extends StatelessWidget {
  const _OverlayLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
          width: 170,
          right: 10,
          bottom: 12,
          child: Card(
            color: Colors.black.withOpacity(0.8),
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: ListTile(
                leading: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(),
                ),
                title: Text(
                  "Karanda\nOverlay",
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
