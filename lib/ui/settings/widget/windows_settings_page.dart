import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:karanda/ui/core/ui/karanda_app_bar.dart';
import 'package:karanda/ui/core/ui/loading_indicator.dart';
import 'package:karanda/ui/core/ui/page_base.dart';
import 'package:karanda/ui/settings/controller/windows_settings_controller.dart';
import 'package:karanda/utils/launch_url.dart';
import 'package:provider/provider.dart';

class WindowsSettingsPage extends StatelessWidget {
  const WindowsSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => WindowsSettingsController(
        settingsService: context.read(),
      ),
      child: Scaffold(
        appBar: KarandaAppBar(
          icon: Icons.desktop_windows_outlined,
          title: context.tr("settings.windows settings"),
        ),
        body: Consumer(
          builder: (context, WindowsSettingsController controller, child) {
            if (controller.appSettings == null) {
              return const LoadingIndicator();
            }
            return PageBase(
              children: [
                SwitchListTile(
                  title: Text(context.tr("settings.windows start minimized")),
                  value: controller.startMinimized,
                  onChanged: controller.setStartMinimized,
                ),
                SwitchListTile(
                  title: Text(context.tr("settings.windows use tray")),
                  value: controller.useTrayMode,
                  onChanged: controller.setUseTrayMode,
                ),
                /*ListTile(
                  title: Text(context.tr("settings.windows auto start")),
                  subtitle: Text(
                    context.tr("settings.windows auto start hint"),
                  ),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () => launchURL(
                    "ms-settings:startupapps",
                    newTab: false,
                  ),
                ),*/
              ],
            );
          },
        ),
      ),
    );
  }
}
