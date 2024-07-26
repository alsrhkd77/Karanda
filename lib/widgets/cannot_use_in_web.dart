import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:karanda/common/api.dart';

import '../common/launch_url.dart';

class CannotUseInWeb extends StatelessWidget {
  const CannotUseInWeb({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: const EdgeInsets.all(24.0),
            child: const Icon(FontAwesomeIcons.lock, size: 100.0),
          ),
          Container(
            margin: const EdgeInsets.all(24.0),
            alignment: Alignment.center,
            child: const Text(
              '웹 환경에서는 해당 서비스를 이용할 수 없습니다',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              overflow: TextOverflow.clip,
              textAlign: TextAlign.center,
            ),
          ),
          OutlinedButton(
            onPressed: () => launchURL(Api.latestInstaller),
            child: Container(
              margin: const EdgeInsets.all(12.0),
              child: const Text('Download Karanda desktop app'),
            ),
          ),
        ],
      ),
    );
  }
}
