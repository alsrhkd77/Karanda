import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:karanda/enums/overlay_features.dart';
import 'package:karanda/ui/core/ui/karanda_app_bar.dart';
import 'package:karanda/ui/core/ui/loading_indicator.dart';
import 'package:karanda/ui/core/ui/page_base.dart';
import 'package:karanda/ui/overlay/controllers/overlay_controller.dart';
import 'package:provider/provider.dart';

class WorldBossOverlaySettingsPage extends StatelessWidget {
  final OverlayController overlayController;

  const WorldBossOverlaySettingsPage({
    super.key,
    required this.overlayController,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: overlayController,
      child: Scaffold(
        appBar: KarandaAppBar(
          icon: FontAwesomeIcons.layerGroup,
          title: context.tr("overlay.overlay"),
        ),
        body: Consumer(
          builder: (context, OverlayController controller, child) {
            if (controller.overlaySettings == null) {
              return const LoadingIndicator();
            }
            return PageBase(
              children: [
                SwitchListTile(
                  title: Text(context.tr("overlay.use overlay")),
                  value: controller.overlaySettings!.activatedFeatures
                      .contains(OverlayFeatures.worldBoss),
                  onChanged: (value) {
                    controller.switchActivation(
                      OverlayFeatures.worldBoss,
                      value,
                    );
                  },
                ),
                SwitchListTile(
                  title: Text(context.tr("overlay.display name")),
                  value: controller.overlaySettings!.showWorldBossName,
                  onChanged: controller.showWorldBossName,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
