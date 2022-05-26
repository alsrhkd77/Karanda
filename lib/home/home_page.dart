import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  Widget singleIconBox(
      {required String name, required IconData icon, required var onTap}) {
    return InkWell(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Card(
              child: Container(
                margin: EdgeInsets.all(18.0),
                child: Icon(icon, size: 50.0),
              ),
            ),
            Text(name),
          ],
        ),
      ),
      onTap: onTap,
    );
  }

  List<Widget> buildMenu() {
    List<Widget> result = [];
    for (int i = 0; i < 12; i++) {
      Widget widget = singleIconBox(
          icon: FontAwesomeIcons.amazon, name: 'app${i + 1}', onTap: () {});
      result.add(widget);
    }
    return result;
  }

  void _launchURL(String url) async {
    Uri uri = Uri.parse(url);
    if (!await launchUrl(uri))
      throw Get.snackbar('Failed', '해당 링크를 열 수 없습니다. \n $uri ',
          margin: const EdgeInsets.all(24.0));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Flutter Demo Home Page'),
        actions: [
          IconButton(
            onPressed: () {
              Get.toNamed('/settings');
            },
            icon: Icon(FontAwesomeIcons.gear),
            tooltip: '설정',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 12.0),
        child: Column(
          children: [
            ListTile(
              title: Text('계산기'),
            ),
            Divider(),
            Wrap(
              runSpacing: 20.0,
              spacing: 20.0,
              children: [
                singleIconBox(
                  name: '말 성장치 계산기',
                  icon: FontAwesomeIcons.horse,
                  onTap: () {
                    Get.toNamed('/horse');
                  },
                ),
                singleIconBox(
                  name: '선원 성장치 계산기',
                  icon: FontAwesomeIcons.anchor,
                  onTap: () {},
                ),
              ],
            ),
            SizedBox(
              height: 12.0,
            ),
            ListTile(
              title: Text('아토락시온'),
            ),
            Divider(),
            Wrap(
              runSpacing: 20.0,
              spacing: 20.0,
              children: buildMenu(),
            ),
            SizedBox(
              height: 12.0,
            ),
            ListTile(
              title: Text('바로가기'),
            ),
            Divider(),
            Wrap(
              runSpacing: 20.0,
              spacing: 20.0,
              children: [
                singleIconBox(
                  name: '공식 홈페이지',
                  icon: FontAwesomeIcons.link,
                  onTap: () => _launchURL('https://www.kr.playblackdesert.com'),
                ),
                singleIconBox(
                  name: '인벤',
                  icon: FontAwesomeIcons.link,
                  onTap: () => _launchURL('https://black.inven.co.kr/'),
                ),
                singleIconBox(
                  name: '인벤 지도 시뮬레이터',
                  icon: FontAwesomeIcons.link,
                  onTap: () => _launchURL('https://black.inven.co.kr/dataninfo/map/'),
                ),
                singleIconBox(
                  name: 'Garmoth',
                  icon: FontAwesomeIcons.link,
                  onTap: () => _launchURL('https://garmoth.com'),
                ),
              ],
            ),
            Divider(),
            Card(
              elevation: 4.0,
              margin: EdgeInsets.all(24.0),
              child: Container(
                margin: EdgeInsets.all(24.0),
                width: Size.infinite.width,
                child: Text(
                  'sadfasdf\nUse Font Awsome Icons',
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
