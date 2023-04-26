import 'package:flutter/foundation.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:karanda/auth/auth_notifier.dart';
import 'package:karanda/common/api.dart';
import 'package:url_launcher/url_launcher.dart';

import '../settings/settings_notifier.dart';
import '../widgets/default_app_bar.dart';
import '../widgets/title_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  void _launchURL(String url) async {
    Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Get.snackbar('Failed', '해당 링크를 열 수 없습니다. \n $uri ',
          margin: const EdgeInsets.all(24.0));
    }
  }

  Widget socialLogin(){
    if(Provider.of<AuthNotifier>(context).authenticated){
      String _username = Provider.of<AuthNotifier>(context, listen: false).username;
      String _avatar = Provider.of<AuthNotifier>(context, listen: false).avatar;
      return ListTile(
        leading: CircleAvatar(
          foregroundImage: Image.network('${Api.discordCDN}$_avatar').image,
          radius: 12,
        ),
        title: Text(_username),
        trailing: const Icon(FontAwesomeIcons.discord),
        iconColor: const Color.fromRGBO(88, 101, 242, 1),
        onTap: (){
          Get.toNamed('/auth/info');
        },
      );
    }
    return ListTile(
      leading: const Icon(Icons.login),
      title: const Text('소셜 로그인'),
      onTap: () {
        Get.toNamed('/auth/authenticate');
      },
    );
  }

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
                socialLogin(),
                /*
                ListTile(
                  leading: const Icon(FontAwesomeIcons.route),
                  title: const Text('실험적 서비스'),
                  onTap: () {
                    Get.toNamed('/experimental-function');
                  },
                ),
                 */
                kIsWeb
                    ? ListTile(
                        leading: const Icon(Icons.install_desktop),
                        title: const Text('Install Windows desktop'),
                        trailing:
                            const Icon(Icons.open_in_new),
                        onTap: () => _launchURL(
                            'https://github.com/HwanSangYeonHwa/Karanda/releases'),
                      )
                    : ListTile(
                        leading: const Icon(Icons.system_update_alt_rounded),
                        title: const Text('업데이트'),
                        onTap: () {
                          Get.toNamed('/desktop-app');
                        },
                      ),
                ListTile(
                  leading: const Icon(Icons.dark_mode_outlined),
                  title: const Text('다크 모드'),
                  trailing: Switch(
                    value: Provider.of<SettingsNotifier>(context).darkMode,
                    onChanged: (value) {
                      Provider.of<SettingsNotifier>(context, listen: false)
                          .setDarkMode(value);
                    },
                  ),
                ),
                const ListTile(
                  leading: Icon(Icons.public),
                  title: Text('서버'),
                  trailing: Text('KR', style: TextStyle(fontWeight: FontWeight.bold),),
                ),
                ListTile(
                  leading: const Icon(Icons.reviews_outlined),
                  title: const Text('건의하기 / 버그 제보'),
                  trailing:
                  const Icon(Icons.open_in_new),
                  onTap: () => _launchURL(
                      'https://forms.gle/Fyyc8DpcwPVMgsVy6'),
                ),
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: const Text('패치 내역'),
                  trailing:
                  const Icon(Icons.open_in_new),
                  onTap: () => _launchURL(
                      'https://github.com/HwanSangYeonHwa/Karanda/releases'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
