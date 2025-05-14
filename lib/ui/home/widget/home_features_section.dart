import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:karanda/utils/extension/build_context_extension.dart';
import 'package:karanda/utils/extension/go_router_extension.dart';

class HomeFeaturesSection extends StatelessWidget {
  final int count;
  final double childAspectRatio;

  const HomeFeaturesSection({
    super.key,
    required this.count,
    required this.childAspectRatio,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: count,
      childAspectRatio: childAspectRatio,
      children: [
        _Tile(
          title: '선박 증축',
          icon: FontAwesomeIcons.ship,
          path: '/ship-upgrading',
        ),
        _Tile(
          title: '이벤트 캘린더',
          icon: Icons.celebration_outlined,
          path: '/event-calendar',
        ),
        _Tile(
          title: '광명석 조합식',
          icon: FontAwesomeIcons.splotch,
          path: '/artifact',
        ),
        /*_Tile(
          title: '말 성장치 계산기',
          icon: FontAwesomeIcons.stickerMule,
          path: '/horse',
        ),
        _Tile(
          title: '시카라키아 아홉문장 계산기',
          icon: FontAwesomeIcons.calculator,
          path: '/sycrakea',
        ),
        _Tile(
          title: '요루나키아 보름달이 뜬 밤 계산기',
          icon: FontAwesomeIcons.calculator,
          path: '/yolunakea-moon',
        ),*/
        _Tile(
          title: '물물교환 계산기',
          icon: FontAwesomeIcons.arrowRightArrowLeft,
          path: '/trade-calculator',
        ),
        _Tile(
          title: '예약 종료',
          icon: FontAwesomeIcons.powerOff,
          path: '/shutdown-scheduler',
          windowsOnly: true,
        ),
        _Tile(
          title: '시카라키아 컬러 카운터',
          icon: FontAwesomeIcons.staffSnake,
          path: '/color-counter',
        ),
        _Tile(
          title: context.tr("trade market.trade market"),
          icon: FontAwesomeIcons.scaleUnbalanced,
          path: '/trade-market',
        ),
        _Tile(
          title: context.tr("world boss.world boss"),
          icon: FontAwesomeIcons.dragon,
          path: '/world-boss',
        ),
        _Tile(
          title: context.tr("overlay.overlay"),
          icon: FontAwesomeIcons.layerGroup,
          path: '/overlay',
          windowsOnly: true,
        ),
        _Tile(
          title: context.tr("adventurer hub.adventurer hub"),
          icon: FontAwesomeIcons.circleNodes,
          path: '/adventurer-hub',
        ),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  final String title;
  final String path;
  final IconData icon;
  final bool windowsOnly;

  const _Tile({
    super.key,
    required this.title,
    required this.path,
    required this.icon,
    this.windowsOnly = false,
  });

  void windowsOnlySnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("run only windows"),
    ));
  }

  @override
  Widget build(BuildContext context) {
    bool enabled = windowsOnly ? !kIsWeb && Platform.isWindows : true;
    return Center(
      child: InkWell(
        onTap: enabled ? null : () => windowsOnlySnackBar(context),
        child: ListTile(
          enabled: enabled,
          leading: Icon(icon),
          title: Text(title),
          onTap: () => context.goWithGa(path),
        ),
      ),
    );
  }
}
