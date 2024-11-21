import 'dart:math';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karanda/auth/auth_notifier.dart';
import 'package:karanda/bdo_news/bdo_news_data_controller.dart';
import 'package:karanda/bdo_news/widgets/bdo_event_widget.dart';
import 'package:karanda/bdo_news/widgets/bdo_update_widget.dart';
import 'package:karanda/common/api.dart';
import 'package:karanda/common/launch_url.dart';
import 'package:karanda/home/chzzk_banner.dart';
import 'package:karanda/home/widgets/link_section_widget.dart';
import 'package:karanda/home/widgets/service_section_widget.dart';
import 'package:karanda/widgets/bdo_clock.dart';
import 'package:karanda/widgets/title_text.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:developer' as developer;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WindowListener {
  final BdoNewsDataController _newsDataController = BdoNewsDataController();
  final widthConstrains = 1520;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _newsDataController.subscribeEvents();
      _newsDataController.subscribeLabUpdates();
      _newsDataController.subscribeUpdates();
    });
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  Future<void> onWindowResized() async {
    Size size = await windowManager.getSize();
    final sharedPreferences = await SharedPreferences.getInstance();
    if (!kDebugMode) {
      sharedPreferences.setDouble("width", size.width);
      sharedPreferences.setDouble("height", size.height);
    }
  }

  @override
  Future<void> onWindowMoved() async {
    Offset position = await windowManager.getPosition();
    final sharedPreferences = await SharedPreferences.getInstance();
    if (!kDebugMode) {
      sharedPreferences.setDouble("x", position.dx);
      sharedPreferences.setDouble("y", position.dy);
    }
  }

  @override
  Future<void> onWindowClose() async {
    try {
      final subWindowIds = await DesktopMultiWindow.getAllSubWindowIds();
      for (final windowId in subWindowIds) {
        WindowController controller = WindowController.fromWindowId(windowId);
        await controller.close();
      }
    } catch (e) {
      developer.log('Failed to get SubWindowIds\n$e', name: 'overlay');
    }
    await windowManager.hide();
    await windowManager.destroy();
  }

  Widget bdoClock() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(10.0, 4.0, 0, 0),
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
    double width = MediaQuery.sizeOf(context).width;
    int count = max(min(width ~/ 400, 3), 1);
    double childAspectRatio = (min(width, widthConstrains) / count) / 54;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Karanda',
          style: GoogleFonts.dongle(fontSize: 46),
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
      body: ListView(
        padding: EdgeInsets.symmetric(
            vertical: 12.0,
            horizontal: width > widthConstrains + 12
                ? (width - widthConstrains) / 2
                : 12),
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
          const Center(child: ChzzkBanner()),

          /* Services */
          const ListTile(
            leading: Icon(FontAwesomeIcons.code),
            title: TitleText(
              'Services',
              bold: true,
            ),
          ),
          const Divider(),
          ServiceSectionWidget(
            count: count,
            childAspectRatio: childAspectRatio,
          ),
          const SizedBox(
            height: 12.0,
          ),

          /* News */
          const ListTile(
            leading: Icon(FontAwesomeIcons.newspaper),
            title: TitleText('News', bold: true),
          ),
          const Divider(),
          _News(
            count: count,
            //childAspectRatio: (min(width, widthConstrains) / count) / 380,
            childAspectRatio: width < 400 ? 1.2 : 1.3,
          ),
          const SizedBox(
            height: 12.0,
          ),

          /* Links */
          const ListTile(
            leading: Icon(FontAwesomeIcons.link),
            title: TitleText('Links', bold: true),
          ),
          const Divider(),
          LinkSectionWidget(
            count: count,
            childAspectRatio: childAspectRatio,
          ),
          const SizedBox(
            height: 12.0,
          ),

          /* Footer */
          const Divider(),
          _Footer(
            children: [
              Container(
                width: Size.infinite.width,
                child: Card(
                  margin: const EdgeInsets.all(12.0),
                  elevation: 4.0,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Text('Karanda의 후원자가 되어주세요!'),
                      FilledButton(
                        onPressed: () =>
                            {context.push('/settings/support-karanda')},
                        child: const Text('후원하기'),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                width: Size.infinite.width,
                child: Card(
                  margin: const EdgeInsets.all(12.0),
                  elevation: 4.0,
                  child: Column(
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
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
              alignment: Alignment.center,
              child: const Text(
                '본 콘텐츠는 펄어비스의 공식 자료가 아니며,'
                ' 본 콘텐츠에는 펄어비스가 권리를 보유하고 있는 상표'
                ' 또는 저작물이 포함되어 있습니다.',
                style: TextStyle(color: Colors.grey, fontSize: 10.5),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: const _FAB(),
    );
  }
}

class _FAB extends StatefulWidget {
  const _FAB({super.key});

  @override
  State<_FAB> createState() => _FABState();
}

class _FABState extends State<_FAB> {
  bool extended = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (_) {
        setState(() {
          extended = true;
        });
      },
      onExit: (_) {
        setState(() {
          extended = false;
        });
      },
      child: FloatingActionButton.extended(
        onPressed: () => launchURL(Api.karandaDiscordServer),
        icon: const Icon(
          FontAwesomeIcons.discord,
          color: Colors.white,
        ),
        label: AnimatedSwitcher(
          duration: const Duration(milliseconds: 150),
          transitionBuilder: (Widget child, Animation<double> animation) =>
              FadeTransition(
            opacity: animation,
            child: SizeTransition(
              sizeFactor: animation,
              axis: Axis.horizontal,
              child: child,
            ),
          ),
          child: extended
              ? const Padding(
                  padding: EdgeInsets.only(left: 8.6, right: 0.8, bottom: 0.6),
                  child: Text(
                    'Discord',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                )
              : Container(),
        ),
        backgroundColor: const Color.fromRGBO(88, 101, 242, 1),
        extendedIconLabelSpacing: 1.2,
      ),
    );
  }
}

class _News extends StatelessWidget {
  final int count;
  final double childAspectRatio;

  const _News({
    super.key,
    required this.count,
    required this.childAspectRatio,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: count,
      childAspectRatio: childAspectRatio,
      mainAxisSpacing: 2.0,
      crossAxisSpacing: 2.0,
      children: const [BdoEventWidget(), BdoUpdateWidget()],
    );
  }
}

class _Footer extends StatelessWidget {
  final List<Widget> children;

  const _Footer({super.key, required this.children});

  final double iconSize = 32;

  @override
  Widget build(BuildContext context) {
    bool isVertical = MediaQuery.of(context).size.width < 800;
    return SizedBox(
      height: isVertical ? 200 : 100,
      child: Flex(
        direction: isVertical ? Axis.vertical : Axis.horizontal,
        children: [
          Expanded(
            child: SizedBox(
              width: isVertical ? Size.infinite.width : null,
              child: Card(
                margin: const EdgeInsets.all(8.0),
                elevation: 4.0,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Text('Karanda의 후원자가 되어주세요!'),
                      FilledButton(
                        onPressed: () =>
                        {context.push('/settings/support-karanda')},
                        child: const Text('후원하기'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: SizedBox(
              width: isVertical ? Size.infinite.width : null,
              child: Card(
                margin: const EdgeInsets.all(8.0),
                elevation: 4.0,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
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
            ),
          ),
        ],
      ),
    );
  }
}
