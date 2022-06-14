import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class CannotUseInWeb extends StatelessWidget {
  const CannotUseInWeb({Key? key}) : super(key: key);

  void _launchURL(String url) async {
    Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Get.snackbar('Failed', '해당 링크를 열 수 없습니다. \n $uri ',
          margin: const EdgeInsets.all(24.0));
    }
  }

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
            onPressed: () => _launchURL(
                'https://github.com/HwanSangYeonHwa/Karanda/releases'),
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
