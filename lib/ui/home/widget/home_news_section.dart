import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:karanda/model/bdo_news.dart';
import 'package:karanda/enums/bdo_region.dart';
import 'package:karanda/ui/home/controller/home_news_controller.dart';
import 'package:karanda/utils/custom_scroll_behavior.dart';
import 'package:karanda/utils/launch_url.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

/// 홈 화면 뉴스 섹션 — 이벤트 캐러셀 + 주요 업데이트 + 연구소 업데이트 카드
class HomeNewsSection extends StatelessWidget {
  final int count;

  const HomeNewsSection({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => HomeNewsController(
        bdoNewsRepository: context.read(),
        appSettingsRepository: context.read(),
      )..load(),
      child: Consumer(
        builder: (context, HomeNewsController controller, child) {
          return GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: count,
            mainAxisSpacing: 8.0,
            crossAxisSpacing: 12.0,
            childAspectRatio: 1.38,
            children: [
              _EventCard(
                events: controller.events ?? [],
                appRegion: controller.appRegion,
                nearDeadline: controller.isNearDeadline,
              ),
              _UpdateCard(
                icon: Icons.update,
                title: "news.update",
                news: controller.highlights?.latestMajorUpdate,
                appRegion: controller.appRegion,
              ),
              _UpdateCard(
                icon: Icons.science_outlined,
                title: "news.lab",
                news: controller.highlights?.latestLabUpdate,
                appRegion: controller.appRegion,
              ),
            ],
          );
        },
      ),
    );
  }
}

/// 진행 중 이벤트 캐러셀 카드.
/// 마감 임박(D-3 이하) 이벤트가 있으면 "마감 임박 이벤트"로 표시한다.
class _EventCard extends StatefulWidget {
  final List<BdoNews> events;
  final BDORegion appRegion;
  final bool nearDeadline;

  const _EventCard({
    required this.events,
    required this.appRegion,
    required this.nearDeadline,
  });

  @override
  State<_EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<_EventCard> {
  final PageController _pageController = PageController(initialPage: 0);
  Timer? _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _scheduleAutoScroll();
  }

  @override
  void didUpdateWidget(covariant _EventCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 이벤트 목록이 갱신되면(실시간/리전 변경) 페이지 보정 후 타이머 재설정
    if (oldWidget.events.length != widget.events.length) {
      if (_currentPage >= widget.events.length) {
        _currentPage = 0;
      }
      _scheduleAutoScroll();
    }
  }

  /// 5초 뒤 다음 페이지로 넘긴다. 페이지가 바뀔 때마다 재설정해 연속 순환.
  void _scheduleAutoScroll() {
    _timer?.cancel();
    if (widget.events.length <= 1) return;
    _timer = Timer(const Duration(seconds: 5), _autoScroll);
  }

  void _autoScroll() {
    if (!mounted || !_pageController.hasClients || widget.events.length <= 1) {
      return;
    }
    final next = (_currentPage + 1) % widget.events.length;
    _pageController.animateToPage(
      next,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasMultiple = widget.events.length > 1;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        ListTile(
          leading: Icon(
            widget.nearDeadline ? Icons.alarm : Icons.celebration_outlined,
          ),
          title: Text(
            context.tr(
              widget.nearDeadline ? "news.nearDeadlineEvents" : "news.event",
            ),
            style: TextTheme.of(context).titleMedium,
          ),
          trailing: hasMultiple
              ? SmoothPageIndicator(
                  controller: _pageController,
                  count: widget.events.length,
                  effect: WormEffect(
                    dotWidth: 8.0,
                    dotHeight: 8.0,
                    spacing: 6.0,
                    dotColor:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    activeDotColor: Theme.of(context).colorScheme.primary,
                  ),
                )
              : null,
        ),
        Expanded(
          child: widget.events.isEmpty
              ? Center(child: Text(context.tr("news.empty")))
              : Card(
                  clipBehavior: Clip.antiAlias,
                  child: PageView.builder(
                    controller: _pageController,
                    scrollBehavior: CustomScrollBehavior(),
                    itemCount: widget.events.length,
                    onPageChanged: (index) {
                      _currentPage = index;
                      _scheduleAutoScroll();
                    },
                    itemBuilder: (context, index) {
                      return _NewsCardContent(
                        news: widget.events[index],
                        appRegion: widget.appRegion,
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }
}

/// 주요 업데이트 / 연구소 업데이트 카드 — 이벤트 카드와 같은 모양의 단일 항목 카드.
/// 한 개만 표시하므로 페이지뷰·인디케이터 없음.
class _UpdateCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final BdoNews? news;
  final BDORegion appRegion;

  const _UpdateCard({
    required this.icon,
    required this.title,
    required this.news,
    required this.appRegion,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        ListTile(
          leading: Icon(icon),
          title: Text(
            context.tr(title),
            style: TextTheme.of(context).titleMedium,
          ),
        ),
        Expanded(
          child: news == null
              ? Center(child: Text(context.tr("news.empty")))
              : Card(
                  clipBehavior: Clip.antiAlias,
                  child: _NewsCardContent(
                    news: news!,
                    appRegion: appRegion,
                  ),
                ),
        ),
      ],
    );
  }
}

/// 카드 공용 콘텐츠 — 썸네일 배경 + 하단 제목 오버레이.
/// 이벤트는 D-N 칩이 표시되고, 업데이트/연구소는 deadline이 없어 칩이 표시되지 않는다.
class _NewsCardContent extends StatelessWidget {
  final BdoNews news;
  final BDORegion appRegion;

  const _NewsCardContent({required this.news, required this.appRegion});

  @override
  Widget build(BuildContext context) {
    final days = news.daysUntilDeadline;
    return InkWell(
      mouseCursor: SystemMouseCursors.click,
      onTap: () => launchURL(news.resolveUrl(appRegion)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          news.thumbnail == null
              ? Container(color: Theme.of(context).colorScheme.surfaceDim)
              : Image.network(
                  news.thumbnail!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Theme.of(context).colorScheme.surfaceDim,
                  ),
                ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(14, 24, 14, 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.5),
                    Colors.black
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
              child: Text(
                news.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          if (days != null && days > 0)
            Positioned(
              right: 8,
              top: 8,
              // 마감 임박(3일 이하)은 빨강 강조 — 뉴스 리스트의 D-N 칩 규칙과 동일
              child: Chip(
                label: Text(
                  "D-$days",
                  style: days <= 3
                      ? TextStyle(
                          color: Theme.of(context).colorScheme.onError,
                        )
                      : null,
                ),
                backgroundColor: days <= 3
                    ? Theme.of(context).colorScheme.error
                    : null,
                side: days <= 3 ? BorderSide.none : null,
                visualDensity: VisualDensity.compact,
              ),
            ),
        ],
      ),
    );
  }
}
