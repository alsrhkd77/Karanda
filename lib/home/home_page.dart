import 'package:flutter/foundation.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:karanda/auth/auth_notifier.dart';
import 'package:karanda/common/api.dart';
import 'package:karanda/common/global_properties.dart';
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
      name: '선박 증축',
      icon: FontAwesomeIcons.ship,
      path: '/ship-extension',
    ),
    _Service(
      name: '이벤트 캘린더',
      icon: Icons.celebration_outlined,
      path: '/event-calendar',
    ),
    _Service(
      name: '광명석 조합식',
      icon: FontAwesomeIcons.splotch,
      path: '/artifact',
    ),
    _Service(
      name: '말 성장치 계산기',
      icon: FontAwesomeIcons.chessKnight,
      path: '/horse',
    ),
    _Service(
      name: '시카라키아 아홉문장 계산기',
      icon: FontAwesomeIcons.calculator,
      path: '/sycrakea',
    ),
    _Service(
      name: '요루나키아 보름달이 뜬 밤 계산기',
      icon: FontAwesomeIcons.calculator,
      path: '/yolunakea-moon',
    ),
    _Service(
      name: '물물교환 계산기',
      icon: FontAwesomeIcons.arrowRightArrowLeft,
      path: '/trade-calculator',
    ),
    _Service(
      name: '예약 종료',
      icon: FontAwesomeIcons.powerOff,
      path: '/shutdown-scheduler',
      onlyWindows: true,
    ),
    _Service(
      name: '숙제 체크리스트 (Beta)',
      icon: FontAwesomeIcons.listCheck,
      path: '/checklist',
      needLogin: true,
    ),
    _Service(
      name: '시카라키아 컬러 카운터',
      icon: FontAwesomeIcons.staffSnake,
      path: '/color-counter',
    ),
    _Service(
      name: '거래소 (실험)',
      icon: FontAwesomeIcons.shop,
      path: '/trade-market',
    ),
  ];

  final List<_Link> links = [
    _Link(
      name: '검은사막 공식 홈페이지',
      icon: 'assets/icons/bdo.png',
      url: 'https://www.kr.playblackdesert.com',
    ),
    _Link(
      name: '검은사막 연구소(테스트 서버)',
      icon: 'assets/icons/bdo.png',
      url: 'https://www.global-lab.playblackdesert.com',
    ),
    _Link(
      name: '검은사막 인벤',
      icon: 'assets/icons/inven.png',
      url: 'https://black.inven.co.kr',
    ),
    _Link(
      name: '검은사막 인벤 지도시뮬레이터',
      icon: 'assets/icons/inven.png',
      url: 'https://black.inven.co.kr/dataninfo/map',
    ),
    _Link(
      name: 'Garmoth',
      icon: 'assets/icons/garmoth.png',
      url: 'https://garmoth.com',
    ),
    _Link(
      name: 'BDO Codex',
      icon: 'assets/icons/bdocodex.png',
      url: 'https://bdocodex.com/kr',
    ),
    _Link(
      name: 'BDOLYTICS',
      icon: 'assets/icons/bdolytics.png',
      url: 'https://bdolytics.com/ko/KR',
    ),
    _Link(
      name: 'OnTopReplica',
      icon: 'assets/icons/onTopReplica.png',
      url: 'https://github.com/LorenzCK/OnTopReplica',
    ),
  ];

  Widget singleIconTile(_Service service) {
    bool enabled = true;
    if (service.needLogin) {
      enabled =
          context.select<AuthNotifier, bool>((value) => value.authenticated);
    }
    if (service.onlyWindows) {
      enabled = !kIsWeb;
    }
    return Container(
      margin: const EdgeInsets.all(4.0),
      constraints: const BoxConstraints(
        maxWidth: 400,
      ),
      child: InkWell(
        onTap: enabled
            ? null
            : () {
                String content = '사용할 수 없는 서비스 입니다';
                if (service.needLogin) {
                  content = '로그인이 필요한 서비스입니다';
                }
                if (service.onlyWindows) {
                  content = 'Desktop에서 사용할 수 있습니다';
                }
                _showSnackBar(content: content);
              },
        child: ListTile(
          enabled: enabled,
          title: Text(
            service.name,
            style: const TextStyle(fontSize: 15.0),
          ),
          leading: Icon(service.icon),
          onTap: () => context.go(service.path),
        ),
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

  void _showSnackBar({required String content}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.lock,
              color: Colors.redAccent,
            ),
            const SizedBox(
              width: 8.0,
            ),
            Text(content),
          ],
        ),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: GlobalProperties.snackBarMargin,
        showCloseIcon: true,
        backgroundColor: Theme.of(context).snackBarTheme.backgroundColor,
      ),
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
          context.push('/auth/info');
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
        context.push('/auth/authenticate');
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
                context.push('/settings');
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
                children: services.map((e) => singleIconTile(e)).toList(),
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
              /*
              Container(
                alignment: Alignment.center,
                child: const Text(
                  '본 콘텐츠는 펄어비스의 공식 자료가 아니며,'
                  ' 본 콘텐츠에는 펄어비스가 권리를 보유하고 있는 상표'
                  ' 또는 저작물이 포함되어 있습니다.',
                  style: TextStyle(color: Colors.grey),
                ),
              )
               */
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
  bool needLogin;
  bool onlyWindows;

  _Service(
      {required this.name,
      required this.icon,
      required this.path,
      this.needLogin = false,
      this.onlyWindows = false});
}

class _Link {
  String name;
  String icon;
  String url;

  _Link({required this.name, required this.icon, required this.url});
}
