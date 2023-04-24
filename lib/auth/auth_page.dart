import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:karanda/auth/auth_notifier.dart';
import 'package:karanda/common/api.dart';
import 'package:karanda/widgets/default_app_bar.dart';
import 'package:provider/provider.dart';

import 'package:url_launcher/url_launcher.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  @override
  void initState() {
    super.initState();
    checkParam();
  }

  Future<void> checkParam() async {
    String? token = Get.parameters['token'];
    String? accessToken = Get.parameters['access_token'];
    String? refreshToken = Get.parameters['refresh_token'];
    if (token != null && accessToken != null && refreshToken != null) {
      await Provider.of<AuthNotifier>(context, listen: false)
          .saveToken(token, accessToken, refreshToken);
      _launchUrl(Api.host, newTab: false);
    }
  }

  Future<void> _launchUrl(String url, {bool newTab = true}) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, webOnlyWindowName: newTab ? '_blank' : '_self')) {
      throw Exception('Could not launch $uri');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DefaultAppBar(),
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
                Container(
                  child: Image.asset(
                    'assets/brand/karanda_mix.png',
                    filterQuality: FilterQuality.high,
                  ),
                  constraints: BoxConstraints(
                    maxWidth: 400.0,
                    maxHeight: 400.0,
                  ),
                  margin: EdgeInsets.all(40.0),
                ),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 40.0, vertical: 12.0),
                  child: ChangeNotifierProvider.value(
                    value: AuthNotifier(),
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        fixedSize: Size.fromWidth(480),
                      ),
                      icon: Image.asset(
                        'assets/icons/discord.png',
                        width: 25,
                        height: 25,
                      ),
                      onPressed: () {
                        Provider.of<AuthNotifier>(context, listen: false)
                            .authenticate();
                      },
                      label: Text('디스코드로 로그인'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
