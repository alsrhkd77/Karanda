import 'package:flutter/material.dart';
import 'package:karanda/common/launch_url.dart';

class LinkSectionWidget extends StatelessWidget {
  final int count;
  final double childAspectRatio;

  const LinkSectionWidget({
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
      childAspectRatio: childAspectRatio,
      mainAxisSpacing: 2.0,
      crossAxisSpacing: 2.0,
      children: const [
        _LinkTile(
          name: '검은사막 공식 홈페이지',
          imagePath: 'assets/icons/bdo.png',
          url: 'https://www.kr.playblackdesert.com',
        ),
        _LinkTile(
          name: '검은사막 연구소(테스트 서버)',
          imagePath: 'assets/icons/bdo.png',
          url: 'https://www.global-lab.playblackdesert.com',
        ),
        _LinkTile(
          name: '검은사막 인벤',
          imagePath: 'assets/icons/inven.png',
          url: 'https://black.inven.co.kr',
        ),
        _LinkTile(
          name: '검은사막 인벤 지도시뮬레이터',
          imagePath: 'assets/icons/inven.png',
          url: 'https://black.inven.co.kr/dataninfo/map',
        ),
        _LinkTile(
          name: 'Garmoth',
          imagePath: 'assets/icons/garmoth.png',
          url: 'https://garmoth.com',
        ),
        _LinkTile(
          name: 'BDO Codex',
          imagePath: 'assets/icons/bdocodex.png',
          url: 'https://bdocodex.com/kr',
        ),
        _LinkTile(
          name: 'BDOLYTICS',
          imagePath: 'assets/icons/bdolytics.png',
          url: 'https://bdolytics.com/ko/KR',
        ),
        _LinkTile(
          name: 'OnTopReplica',
          imagePath: 'assets/icons/onTopReplica.png',
          url: 'https://github.com/LorenzCK/OnTopReplica',
        ),
      ],
    );
  }
}

class _LinkTile extends StatelessWidget {
  final String name;
  final String imagePath;
  final String url;

  const _LinkTile({
    super.key,
    required this.name,
    required this.imagePath,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ListTile(
        title: Text(name),
        leading: Image.asset(
          imagePath,
          height: 25,
          width: 25,
          fit: BoxFit.contain,
        ),
        onTap: () => launchURL(url),
      ),
    );
  }
}
