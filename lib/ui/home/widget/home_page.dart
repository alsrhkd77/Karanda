import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:karanda/service/desktop_service.dart';
import 'package:karanda/ui/core/theme/dimes.dart';
import 'package:karanda/ui/core/ui/karanda_app_bar.dart';
import 'package:karanda/ui/core/ui/page_base.dart';
import 'package:karanda/ui/home/widget/auth_button_widget.dart';
import 'package:karanda/ui/home/widget/home_features_section.dart';
import 'package:karanda/ui/home/widget/home_links_section.dart';
import 'package:karanda/ui/home/widget/home_news_section.dart';
import 'package:karanda/ui/home/widget/home_section.dart';
import 'package:karanda/utils/extension/go_router_extension.dart';
import 'package:provider/provider.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

import '../../../utils/launch_url.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WindowListener, TrayListener {
  @override
  void initState() {
    super.initState();
    trayManager.addListener(this);
    windowManager.addListener(this);
  }

  @override
  void dispose() {
    trayManager.removeListener(this);
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowResized() {
    context.read<DesktopService>().onWindowResized();
  }

  @override
  void onWindowMoved() {
    context.read<DesktopService>().onWindowMoved();
  }

  @override
  void onWindowClose() {
    context.read<DesktopService>().onWindowClose();
  }

  @override
  void onTrayIconMouseDown() {
    context.read<DesktopService>().onTrayIconMouseUp();
  }

  @override
  void onTrayIconRightMouseDown() {
    context.read<DesktopService>().onTrayIconRightMouseUp();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    context.read<DesktopService>().onTrayMenuItemClick(menuItem);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final contentsWidth = min(
        Dimens.pageMaxWidth - (Dimens.pagePaddingValue * 2),
        width - (Dimens.pagePaddingValue * 2));

    ///(Dimens.pageMaxWidth - (Dimens.pagePaddingValue * 2)) / 3 = 392
    final count = max(contentsWidth ~/ 392, 1);
    final childAspectRatio = (contentsWidth / count) / 55;
    return Scaffold(
      appBar: KarandaAppBar(
        actions: [
          IconButton(
            onPressed: () => context.goWithGa("/settings"),
            icon: const Icon(FontAwesomeIcons.gear),
            tooltip: context.tr("settings.settings"),
          )
        ],
      ),
      body: PageBase(
        width: width,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Spacer(), AuthButtonWidget()],
          ),
          HomeSection(
            icon: FontAwesomeIcons.code,
            title: "Features",
            child: HomeFeaturesSection(
              count: count,
              childAspectRatio: childAspectRatio,
            ),
          ),
          HomeSection(
            title: "News",
            icon: FontAwesomeIcons.newspaper,
            child: HomeNewsSection(count: count),
          ),
          HomeSection(
            icon: FontAwesomeIcons.link,
            title: "Links",
            child: HomeLinksSection(
              count: count,
              childAspectRatio: childAspectRatio,
            ),
          ),
          const Divider(),
          _FooterContainer(
            width: contentsWidth,
            children: [
              Card(
                child: Container(
                  width: Size.infinite.width,
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(context.tr("home.support karanda")),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: FilledButton(
                          onPressed: () {
                            context.push('/settings/support-karanda');
                          },
                          child: Text(context.tr("home.donate")),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                child: Container(
                  width: Size.infinite.width,
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(context.tr("home.contact us text")),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: FilledButton(
                          onPressed: () {
                            launchURL('https://forms.gle/Fyyc8DpcwPVMgsVy6');
                          },
                          child: Text(context.tr("home.contact us")),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              context.tr("home.it's unofficial"),
              style: TextTheme.of(context)
                  .labelSmall
                  ?.copyWith(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          )
        ],
      ),
    );
  }
}

class _FooterContainer extends StatelessWidget {
  final double width;
  final List<Widget> children;

  const _FooterContainer({
    super.key,
    required this.width,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    if (width < 800) {
      return Column(
        children: children,
      );
    }
    return Row(
      children: children.map((widget) => Expanded(child: widget)).toList(),
    );
  }
}
