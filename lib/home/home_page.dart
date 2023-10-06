import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:karanda/auth/auth_notifier.dart';
import 'package:karanda/common/api.dart';
import 'package:karanda/widgets/bdo_clock.dart';
import 'package:provider/provider.dart';

import '../common/launch_url.dart';
import '../widgets/title_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<_Service> services = [
    _Service(
      '선박 증축',
      FontAwesomeIcons.ship,
      '/ship-extension',
    ),
    _Service(
      '이벤트 캘린더',
      Icons.celebration_outlined,
      '/event-calendar',
    ),
    _Service(
      '광명석 조합식',
      FontAwesomeIcons.splotch,
      '/artifact',
    ),
    _Service(
      '말 성장치 계산기',
      FontAwesomeIcons.chessKnight,
      '/horse',
    ),
    _Service(
      '시카라키아 아홉문장 계산기',
      FontAwesomeIcons.calculator,
      '/sycrakea',
    ),
    _Service(
      '요루나키아 보름달이 뜬 밤 계산기',
      FontAwesomeIcons.calculator,
      '/yolunakea-moon',
    ),
    _Service(
      '물물교환 계산기',
      FontAwesomeIcons.arrowRightArrowLeft,
      '/trade-calculator',
    ),
    _Service(
      '예약 종료',
      FontAwesomeIcons.powerOff,
      '/shutdown-scheduler',
    ),
    _Service(
      '숙제 체크리스트 (Beta)',
      FontAwesomeIcons.listCheck,
      '/checklist',
    ),
    _Service(
      '시카라키아 컬러 카운터',
      FontAwesomeIcons.staffSnake,
      '/color-counter',
    ),
  ];

  final List<_Link> links = [
    _Link(
      '검은사막 공식 홈페이지',
      'assets/icons/bdo.png',
      'https://www.kr.playblackdesert.com',
    ),
    _Link(
      '검은사막 연구소(테스트 서버)',
      'assets/icons/bdo.png',
      'https://www.global-lab.playblackdesert.com',
    ),
    _Link(
      '검은사막 인벤',
      'assets/icons/inven.png',
      'https://black.inven.co.kr',
    ),
    _Link(
      '검은사막 인벤 지도시뮬레이터',
      'assets/icons/inven.png',
      'https://black.inven.co.kr/dataninfo/map',
    ),
    _Link(
      'Garmoth',
      'assets/icons/garmoth.png',
      'https://garmoth.com',
    ),
    _Link(
      'BDO Codex',
      'assets/icons/bdocodex.png',
      'https://bdocodex.com/kr',
    ),
    _Link(
      'BDOLYTICS',
      'assets/icons/bdolytics.png',
      'https://bdolytics.com/ko/KR',
    ),
    _Link(
      'OnTopReplica',
      'assets/icons/onTopReplica.png',
      'https://github.com/LorenzCK/OnTopReplica',
    ),
  ];

  @override
  void initState() {
    super.initState();
    //Provider.of<AuthNotifier>(context, listen: false).authorization();
  }

  Widget singleIconTile(
      {required String name, required IconData icon, required String path}) {
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
        onTap: () => context.go(path),
      ),
    );
  }

  Widget singleImageTile(
      {required String name, required String icon, required String url}) {
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
        onTap: () => launchURL(url),
      ),
    );
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
      String username =
          Provider.of<AuthNotifier>(context, listen: false).username;
      String avatar = Provider.of<AuthNotifier>(context, listen: false).avatar;
      return OutlinedButton.icon(
        style: buttonStyle,
        onPressed: () {
          context.go('/auth/info');
        },
        icon: CircleAvatar(
          foregroundImage: Image.network('${Api.discordCDN}$avatar').image,
          radius: 12,
        ),
        label: Text(
          username,
          style: const TextStyle(fontSize: 16),
        ),
      );
    }
    return OutlinedButton.icon(
      style: buttonStyle,
      onPressed: () {
        context.go('/auth/authenticate');
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
                context.go('/settings');
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
                children: services
                    .map((e) => singleIconTile(
                        name: e.name, icon: e.icon, path: e.path))
                    .toList(),
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
                children: links
                    .map((e) =>
                        singleImageTile(name: e.name, icon: e.icon, url: e.url))
                    .toList(),
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
                            launchURL('https://forms.gle/Fyyc8DpcwPVMgsVy6'),
                        child: const Text('문의하기'),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                alignment: Alignment.center,
                child: const Text(
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

class _Service {
  String name;
  IconData icon;
  String path;

  _Service(this.name, this.icon, this.path);
}

class _Link {
  String name;
  String icon;
  String url;

  _Link(this.name, this.icon, this.url);
}
