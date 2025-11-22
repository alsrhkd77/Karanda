import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:karanda/enums/overlay_features.dart';
import 'package:karanda/ui/core/ui/karanda_app_bar.dart';
import 'package:karanda/ui/core/ui/loading_indicator.dart';
import 'package:karanda/ui/core/ui/page_base.dart';
import 'package:karanda/ui/overlay/controllers/overlay_controller.dart';
import 'package:karanda/ui/overlay/widgets/opacity_slider.dart';
import 'package:provider/provider.dart';

class OverlayWidgetSettingsPage extends StatelessWidget {
  final OverlayController overlayController;
  final OverlayFeatures feature;

  const OverlayWidgetSettingsPage({
    super.key,
    required this.overlayController,
    required this.feature,
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
              return LoadingIndicator();
            }
            return PageBase(children: [
              SwitchListTile(
                title: Text(context.tr("overlay.use overlay")),
                value: controller.overlaySettings!.activatedFeatures
                    .contains(feature),
                onChanged: (value) {
                  controller.switchActivation(
                    feature,
                    value,
                  );
                },
              ),
              OpacitySlider(
                  opacity: controller.overlaySettings?.opacity[feature] ?? 0,
                  onChanged: (value) => controller.setOpacity(feature, value)),
            ]);
          },
        ),
      ),
    );
  }
}
