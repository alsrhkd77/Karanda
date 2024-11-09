import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:karanda/common/global_properties.dart';
import 'package:karanda/common/go_router_extension.dart';

class ServiceSectionWidget extends StatelessWidget {
  final int count;
  final double childAspectRatio;

  const ServiceSectionWidget({
    super.key,
    required this.count,
    required this.childAspectRatio,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      crossAxisCount: count,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 2.0,
      crossAxisSpacing: 2.0,
      childAspectRatio: childAspectRatio,
      children: const [
        _ServiceTile(
          title: '선박 증축',
          icon: FontAwesomeIcons.ship,
          path: '/ship-upgrading',
        ),
        _ServiceTile(
          title: '이벤트 캘린더',
          icon: Icons.celebration_outlined,
          path: '/event-calendar',
        ),
        _ServiceTile(
          title: '광명석 조합식',
          icon: FontAwesomeIcons.splotch,
          path: '/artifact',
        ),
        _ServiceTile(
          title: '말 성장치 계산기',
          icon: FontAwesomeIcons.stickerMule,
          path: '/horse',
        ),
        _ServiceTile(
          title: '시카라키아 아홉문장 계산기',
          icon: FontAwesomeIcons.calculator,
          path: '/sycrakea',
        ),
        _ServiceTile(
          title: '요루나키아 보름달이 뜬 밤 계산기',
          icon: FontAwesomeIcons.calculator,
          path: '/yolunakea-moon',
        ),
        _ServiceTile(
          title: '물물교환 계산기',
          icon: FontAwesomeIcons.arrowRightArrowLeft,
          path: '/trade-calculator',
        ),
        _ServiceTile(
          title: '예약 종료',
          icon: FontAwesomeIcons.powerOff,
          path: '/shutdown-scheduler',
          windowsOnly: true,
        ),
        _ServiceTile(
          title: '시카라키아 컬러 카운터',
          icon: FontAwesomeIcons.staffSnake,
          path: '/color-counter',
        ),
        _ServiceTile(
          title: '통합 거래소',
          icon: FontAwesomeIcons.scaleUnbalanced,
          path: '/trade-market',
        ),
        _ServiceTile(
          title: '월드 보스 (Beta)',
          icon: FontAwesomeIcons.dragon,
          path: '/world-boss',
        ),
        _ServiceTile(
          title: '오버레이 (Beta)',
          icon: FontAwesomeIcons.layerGroup,
          path: '/overlay',
          windowsOnly: true,
        ),
        _ServiceTile(
          title: '인증 센터', //Verification Center Family Verification
          icon: FontAwesomeIcons.idCard,
          path: '/verification-center',
        ),
      ],
    );
  }
}

class _ServiceTile extends StatelessWidget {
  final String title;
  final String path;
  final IconData icon;
  final bool needLogin;
  final bool windowsOnly;
  final bool devOnly;

  const _ServiceTile({
    super.key,
    required this.title,
    required this.path,
    required this.icon,
    this.needLogin = false,
    this.windowsOnly = false,
    this.devOnly = false,
  });

  void showError(context) {
    String content = '사용할 수 없는 서비스 입니다';
    if (windowsOnly) {
      content = 'Desktop 버전에서 이용할 수 있습니다';
    }
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

  @override
  Widget build(BuildContext context) {
    bool enabled = true;
    if(windowsOnly && kIsWeb){
      enabled = false;
    }
    return Center(
      child: InkWell(
        onTap: enabled ? null : () => showError(context),
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
