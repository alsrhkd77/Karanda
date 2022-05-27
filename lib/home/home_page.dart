import 'package:black_tools/widgets/title_text.dart';
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
        title: Text('Home'),
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
        padding: EdgeInsets.all(12.0),
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
                  name: '말 성장치 계산기',
                  icon: FontAwesomeIcons.horse,
                  onTap: () {
                    Get.toNamed('/horse');
                  },
                ),
                singleIconBox(
                  name: '이벤트 캘린더',
                  icon: FontAwesomeIcons.calendarCheck,
                  onTap: () {
                    Get.toNamed('/event-calender');
                  },
                ),
                singleIconBox(
                  name: '시카라키아\n아홉문장 계산기',
                  icon: FontAwesomeIcons.calculator,
                  onTap: () {
                    Get.toNamed('/sikarakia');
                  },
                ),
                singleIconBox(
                  name: '광명석',
                  icon: FontAwesomeIcons.cookie,
                  onTap: () {},
                ),
                singleIconBox(
                  name: '선원',
                  icon: FontAwesomeIcons.personSwimming,
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(
              height: 12.0,
            ),
            const ListTile(
              leading: Icon(FontAwesomeIcons.link),
              title: TitleText('Links', bold: true),
            ),
            const Divider(),
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
                  name: '연구소',
                  icon: FontAwesomeIcons.link,
                  onTap: () =>
                      _launchURL('https://www.global-lab.playblackdesert.com/'),
                ),
                singleIconBox(
                  name: '인벤',
                  icon: FontAwesomeIcons.link,
                  onTap: () => _launchURL('https://black.inven.co.kr/'),
                ),
                singleIconBox(
                  name: '인벤\n지도시뮬레이터',
                  icon: FontAwesomeIcons.link,
                  onTap: () =>
                      _launchURL('https://black.inven.co.kr/dataninfo/map/'),
                ),
                singleIconBox(
                  name: 'Garmoth',
                  icon: FontAwesomeIcons.link,
                  onTap: () => _launchURL('https://garmoth.com'),
                ),
                singleIconBox(
                  name: '환상연화',
                  icon: FontAwesomeIcons.link,
                  onTap: () => _launchURL('http://검은사막.환상연화.홈페이지.한국'),
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
