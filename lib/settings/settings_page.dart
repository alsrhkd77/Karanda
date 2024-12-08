import 'package:flutter/foundation.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:karanda/auth/auth_notifier.dart';
import 'package:karanda/common/api.dart';
import 'package:karanda/common/global_properties.dart';
import 'package:karanda/settings/volume_slider.dart';

import '../common/launch_url.dart';
import '../widgets/default_app_bar.dart';
import '../widgets/title_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Widget socialLogin() {
    if (Provider.of<AuthNotifier>(context).authenticated) {
      String username =
          Provider.of<AuthNotifier>(context, listen: false).username;
      String avatar = Provider.of<AuthNotifier>(context, listen: false).avatar;
      return ListTile(
        leading: CircleAvatar(
          foregroundImage: Image.network(avatar).image,
          radius: 12,
        ),
        title: Text(username),
        trailing: const Icon(FontAwesomeIcons.discord),
        iconColor: const Color.fromRGBO(88, 101, 242, 1),
        onTap: () {
          context.push('/settings/auth/info');
        },
      );
    }
    return ListTile(
      leading: const Icon(Icons.login),
      title: const Text('소셜 로그인'),
      onTap: () {
        context.push('/settings/auth/authenticate');
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
            constraints: BoxConstraints(
              maxWidth: GlobalProperties.widthConstrains,
            ),
            child: Column(
              children: [
                const ListTile(
                  title: TitleText('설정', bold: true),
                ),
                const Divider(),
                socialLogin(),
                kIsWeb
                    ? ListTile(
                        leading: const Icon(Icons.install_desktop),
                        title: const Text('Install Windows desktop'),
                        trailing: const Icon(Icons.open_in_new),
                        onTap: () => launchURL(Api.latestInstaller),
                      )
                    : Container(),
                ListTile(
                  leading: const Icon(Icons.palette_outlined),
                  title: const Text('테마'),
                  onTap: () {
                    context.push('/settings/theme');
                  },
                ),
                const ExpansionTile(
                  //initiallyExpanded: true,
                  leading: Icon(Icons.volume_up),
                  title: Text('음량'),
                  expandedAlignment: Alignment.centerLeft,
                  childrenPadding: EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0,
                  ),
                  children: [
                    VolumeSlider(),
                  ],
                ),
                const ListTile(
                  leading: Icon(Icons.public),
                  title: Text('서버'),
                  trailing: Text(
                    'KR',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                /*
                const ListTile(
                  leading: Icon(Icons.language),
                  title: Text('언어 (Language)'),
                  trailing: Text(
                    '한국어',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                 */
                ListTile(
                  leading: const Icon(Icons.loyalty_outlined),
                  title: const Text('Karanda 후원하기'),
                  onTap: () {
                    context.push('/settings/support-karanda');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.bug_report_outlined),
                  title: const Text('건의 / 버그 제보'),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () => launchURL('https://forms.gle/Fyyc8DpcwPVMgsVy6'),
                ),
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: const Text('패치 내역'),
                  onTap: () {
                    context.push('/settings/change-log');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('정보'),
                  onTap: () {
                    context.push('/settings/karanda-info');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
