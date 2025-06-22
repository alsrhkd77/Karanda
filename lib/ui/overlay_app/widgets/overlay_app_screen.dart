import 'package:flutter/material.dart';
import 'package:karanda/ui/overlay_app/controllers/overlay_app_controller.dart';
import 'package:karanda/ui/overlay_app/widgets/party_finder_overlay_widget.dart';
import 'package:karanda/ui/overlay_app/widgets/boss_hp_scale_indicator_overlay_widget.dart';
import 'package:karanda/ui/overlay_app/widgets/clock_overlay_widget.dart';
import 'package:karanda/ui/overlay_app/widgets/exit_edit_mode_button.dart';
import 'package:karanda/ui/overlay_app/widgets/world_boss_overlay_widget.dart';
import 'package:provider/provider.dart';

class OverlayAppScreen extends StatelessWidget {
  const OverlayAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Consumer(
      builder: (context, OverlayAppController controller, child) {
        if(controller.loading){
          return const _LoadingIndicator();
        }
        return Scaffold(
          backgroundColor: controller.editMode
              ? Colors.white.withAlpha(64)
              : Colors.transparent,
          body: child,
        );
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClockOverlayWidget(width: size.width,),
          BossHpScaleIndicatorOverlayWidget(width: size.width),
          PartyFinderOverlayWidget(height: size.height),
          WorldBossOverlayWidget(height: size.height),
          const ExitEditModeButton(),
        ],
      ),
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    const padding = EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0);
    return Scaffold(
      backgroundColor: Colors.black.withAlpha(64),
      body: const Align(
        alignment: Alignment.bottomRight,
        child: Card(
          margin: padding,
          child: Padding(
            padding: padding,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: padding,
                  child: CircularProgressIndicator(),
                ),
                Padding(
                  padding: padding,
                  child: Text("Karanda\nOverlay", textAlign: TextAlign.center),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

