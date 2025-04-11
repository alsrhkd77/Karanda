import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karanda/enums/font.dart';
import 'package:karanda/ui/core/ui/karanda_app_bar.dart';
import 'package:karanda/ui/core/ui/page_base.dart';
import 'package:karanda/ui/core/ui/section.dart';
import 'package:karanda/ui/settings/controller/settings_controller.dart';
import 'package:provider/provider.dart';

class StyleSettingsPage extends StatelessWidget {
  const StyleSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: KarandaAppBar(
        icon: Icons.palette_outlined,
        title: context.tr("settings.style"),
      ),
      body: Consumer(
        builder: (context, SettingsController controller, child) {
          return PageBase(children: [
            Section(
              icon: Icons.brightness_medium,
              title: context.tr("settings.theme brightness"),
              child: Column(
                children: ThemeMode.values
                    .map((mode) => RadioListTile(
                          value: mode,
                          groupValue: controller.appSettings.themeMode,
                          onChanged: controller.setThemeMode,
                          title: Text(context.tr("theme mode.${mode.name}")),
                        ))
                    .toList(),
              ),
            ),
            Section(
              icon: Icons.font_download_outlined,
              title: context.tr("settings.font"),
              child: Column(
                children: [
                  RadioListTile(
                    value: Font.maplestory,
                    title: Text(
                      context.tr("font.${Font.maplestory.name}"),
                      style: const TextStyle(fontFamily: "Maplestory"),
                    ),
                    groupValue: controller.font,
                    onChanged: controller.setFont,
                  ),
                  RadioListTile(
                    value: Font.notoSansKR,
                    title: Text(
                      context.tr("font.${Font.notoSansKR.name}"),
                      style: GoogleFonts.notoSansKr(),
                    ),
                    groupValue: controller.font,
                    onChanged: controller.setFont,
                  ),
                  RadioListTile(
                    value: Font.nanumGothic,
                    title: Text(
                      context.tr("font.${Font.nanumGothic.name}"),
                      style: GoogleFonts.nanumGothic(),
                    ),
                    groupValue: controller.font,
                    onChanged: controller.setFont,
                  ),
                  RadioListTile(
                    value: Font.jua,
                    title: Text(
                      context.tr("font.${Font.jua.name}"),
                      style: GoogleFonts.jua(),
                    ),
                    groupValue: controller.font,
                    onChanged: controller.setFont,
                  ),
                ],
              ),
            ),
          ]);
        },
      ),
    );
  }
}
