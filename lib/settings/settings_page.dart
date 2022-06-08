import '../settings/settings_notifier.dart';
import '../widgets/default_app_bar.dart';
import '../widgets/title_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DefaultAppBar(),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(12.0),
            width: Size.infinite.width,
            constraints: const BoxConstraints(
              maxWidth: 1080,
            ),
            child: Column(
              children: [
                const ListTile(
                  title: TitleText('설정', bold: true),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(FontAwesomeIcons.circleHalfStroke),
                  title: const Text('다크 모드'),
                  trailing: ChangeNotifierProvider.value(
                    value: SettingsNotifier(),
                    child: Switch(
                      value: Provider.of<SettingsNotifier>(context).darkMode,
                      onChanged: (value) {
                        Provider.of<SettingsNotifier>(context, listen: false)
                            .setDarkMode(value);
                        if(value){
                          Get.snackbar('다크 모드', '다크 모드 활성화', margin: EdgeInsets.all(24.0));
                        }else{
                          Get.snackbar('다크 모드', '다크 모드 비활성화', margin: EdgeInsets.all(24.0));
                        }
                      },
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
