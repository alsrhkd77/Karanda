import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:karanda/widgets/default_app_bar.dart';

import '../widgets/title_text.dart';

class ExperimentalFunctionPage extends StatefulWidget {
  const ExperimentalFunctionPage({Key? key}) : super(key: key);

  @override
  State<ExperimentalFunctionPage> createState() => _ExperimentalFunctionPageState();
}

class _ExperimentalFunctionPageState extends State<ExperimentalFunctionPage> {

  Widget singleIconBox(
      {required String name, required IconData icon, required var onTap}) {
    return InkWell(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Card(
              child: Container(
                margin: const EdgeInsets.all(18.0),
                child: Icon(icon, size: 45.0, color: context.isDarkMode ? null : Colors.black54,),
              ),
            ),
            SizedBox(
              width: 115,
              child: Text(name, textAlign: TextAlign.center),
            ),
          ],
        ),
      ),
      onTap: onTap,
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DefaultAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            const ListTile(
              leading: Icon(FontAwesomeIcons.code),
              title: TitleText(
                'Services',
                bold: true,
              ),
            ),
            const Divider(),
            Wrap(
              runSpacing: 20.0,
              spacing: 20.0,
              children: [
                singleIconBox(
                  name: '길드 관리',
                  icon: Icons.manage_accounts,
                  onTap: () {
                    Get.toNamed('/guild-manager');
                  },
                ),
              ],
            ),
            const SizedBox(
              height: 12.0,
            ),
            const Divider(),
            Card(
              elevation: 4.0,
              margin: const EdgeInsets.all(24.0),
              child: Container(
                margin: const EdgeInsets.all(24.0),
                width: Size.infinite.width,
                child: const Text(
                  '현재 페이지의 서비스들은 아직 개발중인 서비스 입니다',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
