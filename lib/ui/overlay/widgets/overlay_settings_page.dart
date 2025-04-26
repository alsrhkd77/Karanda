import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:karanda/ui/core/ui/karanda_app_bar.dart';
import 'package:karanda/ui/core/ui/loading_indicator.dart';
import 'package:karanda/ui/core/ui/page_base.dart';
import 'package:karanda/ui/overlay/controllers/overlay_settings_controller.dart';
import 'package:provider/provider.dart';

class OverlaySettingsPage extends StatelessWidget {
  const OverlaySettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => OverlaySettingsController(
        overlayRepository: context.read(),
      )..getMonitorList(),
      child: Scaffold(
        appBar: KarandaAppBar(
          icon: FontAwesomeIcons.layerGroup,
          title: context.tr("overlay.overlay"),
        ),
        body: Consumer(
          builder: (context, OverlaySettingsController controller, child) {
            if (controller.monitorList == null ||
                controller.overlaySettings == null) {
              return const LoadingIndicator();
            }
            return PageBase(children: [
              ExpansionTile(
                title: Text(context.tr("overlay.settings.select display")),
                children: controller.monitorList!.map((display) {
                  return RadioListTile(
                    title: Text(display.name.split(r"\").last),
                    value: display,
                    groupValue: controller.overlaySettings!.monitorDevice,
                    onChanged: controller.selectMonitor,
                  );
                }).toList(),
              ),
              /*ExpansionTile(
                title: Text(context.tr("overlay.settings.select display")),
                children: [
                  ListTile(
                    title: Text("left"),
                    onTap: () {
                      controller.selectMonitor(
                        MonitorDevice(
                          name: "name",
                          deviceID: "deviceID",
                          rect: Rect.fromLTWH(0, 0, 1720, 1440),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    title: Text("right"),
                    onTap: () {
                      controller.selectMonitor(
                        MonitorDevice(
                          name: "name",
                          deviceID: "deviceID",
                          rect: Rect.fromLTWH(1720, 0, 1720, 1440),
                        ),
                      );
                    },
                  )
                ],
              ),*/
              ListTile(
                title: Text(context.tr("overlay.settings.reset widgets")),
                onTap: controller.resetOverlayWidgets,
              )
            ]);
          },
        ),
      ),
    );
  }
}
