import 'package:google_fonts/google_fonts.dart';

import '../widgets/title_text.dart';
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

  /* unused */
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
                child: Icon(
                  icon,
                  size: 45.0,
                  color: context.isDarkMode ? null : Colors.black54,
                ),
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

  /* unused */
  Widget singleImageBox(
      {required String name, required String icon, required var onTap}) {
    return InkWell(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Card(
              child: Container(
                margin: const EdgeInsets.all(18.0),
                child: Image.asset(
                  icon,
                  height: 50,
                  width: 50,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
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

  Widget singleIconTile(
      {required String name, required IconData icon, var onTap}) {
    return Container(
      margin: const EdgeInsets.all(4.0),
      constraints: const BoxConstraints(
        maxWidth: 400,
      ),
      child: ListTile(
        title: Text(name),
        leading: Icon(icon),
        onTap: onTap,
      ),
    );
  }

  Widget singleImageTile(
      {required String name, required String icon, var onTap}) {
    return Container(
      margin: const EdgeInsets.all(4.0),
      constraints: const BoxConstraints(
        maxWidth: 400,
      ),
      child: ListTile(
        title: Text(name),
        leading: Image.asset(
          icon,
          height: 25,
          width: 25,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        ),
        onTap: onTap,
      ),
    );
  }

  void _launchURL(String url) async {
    Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Get.snackbar('Failed', '해당 링크를 열 수 없습니다. \n $uri ',
          margin: const EdgeInsets.all(24.0));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Karanda',
          style: GoogleFonts.sourceCodePro(fontSize: 25.0),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 18.0),
            child: IconButton(
              onPressed: () {
                Get.toNamed('/settings');
              },
              icon: const Icon(FontAwesomeIcons.gear),
              tooltip: '설정',
            ),
          ),
        ],
      ),
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
              runSpacing: 2.0,
              spacing: 2.0,
              children: [
                singleIconTile(
                  name: '선박 증축',
                  icon: FontAwesomeIcons.ship,
                  onTap: () {
                    Get.toNamed('/ship-extension');
                  },
                ),
                singleIconTile(
                  name: '물물교환 계산기',
                  icon: FontAwesomeIcons.arrowRightArrowLeft,
                  onTap: () {
                    Get.toNamed('/trade-home');
                  },
                ),
                singleIconTile(
                  name: '말 성장치 계산기',
                  icon: FontAwesomeIcons.chessKnight,
                  onTap: () {
                    Get.toNamed('/horse');
                  },
                ),
                singleIconTile(
                  name: '광명석 조합식',
                  icon: FontAwesomeIcons.splotch,
                  onTap: () {
                    Get.toNamed('/artifact');
                  },
                ),
                singleIconTile(
                  name: '시카라키아 아홉문장 계산기',
                  icon: FontAwesomeIcons.calculator,
                  onTap: () {
                    Get.toNamed('/sycrakea');
                  },
                ),
                singleIconTile(
                  name: '요루나키아 보름달이 뜬 밤 계산기',
                  icon: FontAwesomeIcons.calculator,
                  onTap: () {
                    Get.toNamed('/yolunakea-moon');
                  },
                ),
                singleIconTile(
                  name: '이벤트 캘린더',
                  //icon: FontAwesomeIcons.calendarCheck,
                  icon: Icons.celebration_outlined,
                  onTap: () {
                    Get.toNamed('/event-calender');
                  },
                ),
                singleIconTile(
                  name: '예약 종료',
                  icon: FontAwesomeIcons.powerOff,
                  onTap: () {
                    Get.toNamed('/shutdown-scheduler');
                  },
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
              runSpacing: 2.0,
              spacing: 2.0,
              children: [
                singleImageTile(
                  name: '검은사막 공식 홈페이지',
                  icon: 'assets/icons/bdo.png',
                  onTap: () => _launchURL('https://www.kr.playblackdesert.com'),
                ),
                singleImageTile(
                  name: '검은사막 연구소(테스트 서버)',
                  icon: 'assets/icons/bdo.png',
                  onTap: () =>
                      _launchURL('https://www.global-lab.playblackdesert.com/'),
                ),
                singleImageTile(
                  name: '검은사막 인벤',
                  icon: 'assets/icons/inven.png',
                  onTap: () => _launchURL('https://black.inven.co.kr/'),
                ),
                singleImageTile(
                  name: '검은사막 인벤 지도시뮬레이터',
                  icon: 'assets/icons/inven.png',
                  onTap: () =>
                      _launchURL('https://black.inven.co.kr/dataninfo/map/'),
                ),
                singleImageTile(
                  name: 'Garmoth',
                  icon: 'assets/icons/garmoth.png',
                  onTap: () => _launchURL('https://garmoth.com'),
                ),
                singleImageTile(
                  name: 'BDO Codex',
                  icon: 'assets/icons/bdocodex.png',
                  onTap: () => _launchURL('https://bdocodex.com/kr/'),
                ),
                singleImageTile(
                  name: 'OnTopReplica',
                  icon: 'assets/icons/onTopReplica.png',
                  onTap: () =>
                      _launchURL('https://github.com/LorenzCK/OnTopReplica'),
                ),
                /*
                singleImageBox(
                  name: '환상연화',
                  icon: 'assets/icons/lotus.png',
                  onTap: () => _launchURL('http://검은사막.환상연화.홈페이지.한국'),
                ),
                 */
              ],
            ),
            const Divider(),
            Card(
              elevation: 4.0,
              margin: const EdgeInsets.all(24.0),
              child: Container(
                margin: const EdgeInsets.all(24.0),
                width: Size.infinite.width,
                child: const Text(
                  '해당 소프트웨어는 Dart / Flutter를 사용하여 제작되었습니다\n해당 소프트웨어는 Font Awsome Icons를 사용하여 제작되었습니다',
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
