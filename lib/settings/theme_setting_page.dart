import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karanda/common/global_properties.dart';
import 'package:karanda/settings/settings_notifier.dart';
import 'package:karanda/widgets/default_app_bar.dart';
import 'package:provider/provider.dart';

import '../widgets/title_text.dart';

class ThemeSettingPage extends StatelessWidget {
  const ThemeSettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DefaultAppBar(),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(12.0),
            constraints: BoxConstraints(
              maxWidth: GlobalProperties.widthConstrains,
            ),
            child: Column(
              children: [
                const ListTile(
                  title: TitleText('테마 설정', bold: true),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.dark_mode_outlined),
                  title: const Text('어두운 테마'),
                  trailing: Switch(
                    value: Provider.of<SettingsNotifier>(context).darkMode,
                    onChanged: (value) {
                      Provider.of<SettingsNotifier>(context, listen: false)
                          .setDarkMode(value);
                    },
                  ),
                ),
                ExpansionTile(
                  //initiallyExpanded: true,
                  leading: const Icon(Icons.font_download_outlined),
                  title: const Text('폰트'),
                  children:
                      FONT.values.map((e) => _FontRadioTile(font: e)).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FontRadioTile extends StatelessWidget {
  final FONT font;

  _FontRadioTile({super.key, required this.font});

  final Map<FONT, String> fontList = {
    FONT.maplestory: '메이플스토리체',
    FONT.notoSansKR: 'Noto Sans Korean',
    FONT.nanumGothic: '나눔 고딕',
    FONT.jua: '주아체',
  };

  TextStyle getStyle() {
    switch (font) {
      case (FONT.notoSansKR):
        return GoogleFonts.notoSansKr();
      case (FONT.nanumGothic):
        return GoogleFonts.nanumGothic();
      case (FONT.jua):
        return GoogleFonts.jua();
      default:
        return const TextStyle(fontFamily: 'Maplestory');
    }
  }

  @override
  Widget build(BuildContext context) {
    return RadioListTile(
        title: Text(fontList[font]!, style: getStyle()),
        value: font,
        groupValue: Provider.of<SettingsNotifier>(context).fontFamily,
        onChanged: (value) {
          Provider.of<SettingsNotifier>(context, listen: false)
              .setFontFamily(font);
        });
  }
}
