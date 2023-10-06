import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:karanda/auth/auth_notifier.dart';
import 'package:karanda/common/api.dart';
import 'package:karanda/common/bdo_world_time_notifier.dart';
import 'package:karanda/widgets/bdo_clock.dart';
import 'package:provider/provider.dart';

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
    //Provider.of<AuthNotifier>(context, listen: false).authorization();
  }

  Widget singleIconTile(
      {required String name, required IconData icon, var onTap}) {
    return Container(
      margin: const EdgeInsets.all(4.0),
      constraints: const BoxConstraints(
        maxWidth: 400,
      ),
      child: ListTile(
        title: Text(
          name,
          style: const TextStyle(fontSize: 15.0),
        ),
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
        title: Text(
          name,
          style: const TextStyle(fontSize: 15.0),
        ),
        leading: Image.asset(
          icon,
          height: 25,
          width: 25,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.low,
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

  Widget bdoClock() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(14.0, 4.0, 0, 0),
      child: BdoClock(),
    );
  }

  Widget loginButton() {
    ButtonStyle buttonStyle = OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        padding: const EdgeInsets.all(16.0));
    if (Provider.of<AuthNotifier>(context).waitResponse) {
      return const SpinKitThreeBounce(
        size: 15.0,
        color: Colors.blue,
      );
    }
    if (Provider.of<AuthNotifier>(context).authenticated) {
      String _username =
          Provider.of<AuthNotifier>(context, listen: false).username;
      String _avatar = Provider.of<AuthNotifier>(context, listen: false).avatar;
      return OutlinedButton.icon(
        style: buttonStyle,
        onPressed: () {
          Get.toNamed('/auth/info');
        },
        icon: CircleAvatar(
          foregroundImage: Image.network('${Api.discordCDN}$_avatar').image,
          radius: 12,
        ),
        label: Text(
          _username,
          style: const TextStyle(fontSize: 16),
        ),
      );
    }
    return OutlinedButton.icon(
      style: buttonStyle,
      onPressed: () {
        Get.toNamed('/auth/authenticate');
      },
      icon: const Icon(Icons.account_circle_outlined, size: 20),
      label: const Text(
        '로그인',
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Karanda',
          style: TextStyle(
              fontFamily: 'NanumSquareRound',
              fontWeight: FontWeight.w700,
              fontSize: 26.0),
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
      body: Center(
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 1520,
          ),
          child: ListView(
            addAutomaticKeepAlives: false,
            addRepaintBoundaries: false,
            padding: const EdgeInsets.all(12.0),
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    bdoClock(),
                    loginButton(),
                  ],
                ),
              ),
              /* Services */
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
                    name: '이벤트 캘린더',
                    //icon: FontAwesomeIcons.calendarCheck,
                    icon: Icons.celebration_outlined,
                    onTap: () {
                      Get.toNamed('/event-calender');
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
                    name: '말 성장치 계산기',
                    icon: FontAwesomeIcons.chessKnight,
                    onTap: () {
                      Get.toNamed('/horse');
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
                    name: '물물교환 계산기',
                    icon: FontAwesomeIcons.arrowRightArrowLeft,
                    onTap: () {
                      Get.toNamed('/trade-calculator');
                    },
                  ),
                  singleIconTile(
                    name: '예약 종료',
                    icon: FontAwesomeIcons.powerOff,
                    onTap: () {
                      Get.toNamed('/shutdown-scheduler');
                    },
                  ),
                  singleIconTile(
                    name: '숙제 체크리스트 (Beta)',
                    icon: FontAwesomeIcons.listCheck,
                    onTap: () {
                      Get.toNamed('/checklist');
                    },
                  ),
                  singleIconTile(
                    name: '시카라키아 컬러 카운터',
                    icon: FontAwesomeIcons.staffSnake,
                    onTap: () {
                      Get.toNamed('/color-counter');
                    },
                  ),
                ],
              ),
              const SizedBox(
                height: 20.0,
              ),
              /* Links */
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
                    onTap: () =>
                        _launchURL('https://www.kr.playblackdesert.com'),
                  ),
                  singleImageTile(
                    name: '검은사막 연구소(테스트 서버)',
                    icon: 'assets/icons/bdo.png',
                    onTap: () => _launchURL(
                        'https://www.global-lab.playblackdesert.com/'),
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
                    name: 'BDOLYTICS',
                    icon: 'assets/icons/bdolytics.png',
                    onTap: () => _launchURL('https://bdolytics.com/ko/KR'),
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
              /* footer */
              Card(
                elevation: 4.0,
                margin: const EdgeInsets.all(24.0),
                child: Container(
                  margin: const EdgeInsets.all(18.0),
                  width: Size.infinite.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Text('불편한 점이 있으신가요?'),
                      FilledButton(
                        onPressed: () =>
                            _launchURL('https://forms.gle/Fyyc8DpcwPVMgsVy6'),
                        child: const Text('문의하기'),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                alignment: Alignment.center,
                child: Text(
                    '본 콘텐츠는 펄어비스의 공식 자료가 아니며,'
                        ' 본 콘텐츠에는 펄어비스가 권리를 보유하고 있는 상표'
                        ' 또는 저작물이 포함되어 있습니다.',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
