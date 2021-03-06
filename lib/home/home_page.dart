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

  void _launchURL(String url) async {
    Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Get.snackbar('Failed', '?????? ????????? ??? ??? ????????????. \n $uri ',
          margin: const EdgeInsets.all(24.0));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Karanda', style: GoogleFonts.sourceCodePro(fontSize: 25.0),),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 18.0),
            child: IconButton(
              onPressed: () {
                Get.toNamed('/settings');
              },
              icon: const Icon(FontAwesomeIcons.gear),
              tooltip: '??????',
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
              runSpacing: 20.0,
              spacing: 20.0,
              children: [
                singleIconBox(
                  name: '?????? ??????',
                  icon: FontAwesomeIcons.ship,
                  onTap: () {
                    Get.toNamed('/ship-extension');
                  },
                ),
                singleIconBox(
                  name: '???????????? ?????????',
                  icon: FontAwesomeIcons.arrowRightArrowLeft,
                  onTap: () {
                    Get.toNamed('/trade-home');
                  },
                ),
                singleIconBox(
                  name: '??? ????????? ?????????',
                  icon: FontAwesomeIcons.chessKnight,
                  onTap: () {
                    Get.toNamed('/horse');
                  },
                ),
                singleIconBox(
                  name: '????????? ?????????',
                  icon: FontAwesomeIcons.splotch,
                  onTap: () {
                    Get.toNamed('/artifact');
                  },
                ),singleIconBox(
                  name: '???????????????\n???????????? ?????????',
                  icon: FontAwesomeIcons.calculator,
                  onTap: () {
                    Get.toNamed('/sikarakia');
                  },
                ),
                singleIconBox(
                  name: '????????? ?????????',
                  //icon: FontAwesomeIcons.calendarCheck,
                  icon: Icons.celebration_outlined,
                  onTap: () {
                    Get.toNamed('/event-calender');
                  },
                ),
                singleIconBox(
                  name: '?????? ??????',
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
              runSpacing: 20.0,
              spacing: 20.0,
              children: [
                singleImageBox(
                  name: '?????? ????????????',
                  icon: 'assets/icons/bdo.png',
                  onTap: () => _launchURL('https://www.kr.playblackdesert.com'),
                ),
                singleImageBox(
                  name: '?????????',
                  icon: 'assets/icons/bdo.png',
                  onTap: () =>
                      _launchURL('https://www.global-lab.playblackdesert.com/'),
                ),
                singleImageBox(
                  name: '??????',
                  icon: 'assets/icons/inven.png',
                  onTap: () => _launchURL('https://black.inven.co.kr/'),
                ),
                singleImageBox(
                  name: '??????\n?????????????????????',
                  icon: 'assets/icons/inven.png',
                  onTap: () =>
                      _launchURL('https://black.inven.co.kr/dataninfo/map/'),
                ),
                singleImageBox(
                  name: 'Garmoth',
                  icon: 'assets/icons/garmoth.png',
                  onTap: () => _launchURL('https://garmoth.com'),
                ),
                singleImageBox(
                  name: 'BDO Codex',
                  icon: 'assets/icons/bdocodex.png',
                  onTap: () => _launchURL('https://bdocodex.com/kr/'),
                ),
                singleImageBox(
                  name: 'OnTopReplica',
                  icon: 'assets/icons/onTopReplica.png',
                  onTap: () => _launchURL('https://github.com/LorenzCK/OnTopReplica'),
                ),
                /*
                singleImageBox(
                  name: '????????????',
                  icon: 'assets/icons/lotus.png',
                  onTap: () => _launchURL('http://????????????.????????????.????????????.??????'),
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
                  '?????? ?????????????????? Dart / Flutter??? ???????????? ?????????????????????\n?????? ?????????????????? Font Awsome Icons??? ???????????? ?????????????????????',
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
