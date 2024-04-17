import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:karanda/common/global_properties.dart';
import 'package:karanda/widgets/default_app_bar.dart';
import 'package:karanda/widgets/title_text.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:developer' as developer;

class KarandaInfoPage extends StatefulWidget {
  const KarandaInfoPage({super.key});

  @override
  State<KarandaInfoPage> createState() => _KarandaInfoPageState();
}

class _KarandaInfoPageState extends State<KarandaInfoPage> {
  String currentVersion = '';
  String currentBuildNumber = '';
  String currentPlatform = 'unknown';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getCurrentVersion();
      getCurrentPlatform();
    });
  }

  Future<void> getCurrentVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      currentVersion = packageInfo.version;
      currentBuildNumber = packageInfo.buildNumber;
    });
  }

  void getCurrentPlatform() {
    String? platform;
    if (kIsWeb) {
      platform = 'WEB';
    } else {
      try {
        platform = Platform.operatingSystem.toUpperCase();
      } catch (e) {
        developer.log('Cannot get current operating system');
      }
    }
    setState(() {
      currentPlatform = platform ?? currentPlatform;
    });
  }

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
                  title: TitleText('정보', bold: true),
                ),
                const Divider(),
                ListTile(
                  title: const Text('플랫폼'),
                  subtitle: Text(currentPlatform),
                ),
                ListTile(
                  title: const Text('Karanda 버전'),
                  subtitle: Text(currentVersion),
                ),
                ListTile(
                  title: const Text('빌드 번호'),
                  subtitle: Text(currentBuildNumber),
                ),
                const ListTile(
                  title: Text('Flutter 버전'),
                  subtitle: Text('3.16.5'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
