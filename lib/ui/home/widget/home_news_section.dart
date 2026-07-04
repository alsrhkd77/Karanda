import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:karanda/model/bdo_news.dart';
import 'package:karanda/enums/bdo_region.dart';
import 'package:karanda/ui/core/theme/features_icon.dart';
import 'package:karanda/ui/home/controller/home_news_controller.dart';
import 'package:karanda/utils/extension/go_router_extension.dart';
import 'package:karanda/utils/launch_url.dart';
import 'package:provider/provider.dart';

/// 홈 화면 뉴스 섹션 — 이벤트 카드(상위 5건 캐러셀) + 주요/연구소 업데이트 카드
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
            childAspectRatio: 1.25,
            children: [
              _EventCard(
                events: controller.events ?? [],
                appRegion: controller.appRegion,
              ),
              _HighlightsCard(
                highlights: controller.highlights,
                appRegion: controller.appRegion,
              ),
            ],
          );
        },
      ),
    );
  }
}

/// 진행 중 이벤트 캐러셀 카드
class _EventCard extends StatefulWidget {
  final List<BdoNews> events;
  final BDORegion appRegion;

  const _EventCard({required this.events, required this.appRegion});

  @override
  State<_EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<_EventCard> {
  final PageController pageController = PageController(initialPage: 0);

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () => context.goWithGa('/news'),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ListTile(
              leading: const Icon(Icons.celebration_outlined),
              title: Text(
                context.tr("news.event"),
                style: TextTheme.of(context).titleMedium,
              ),
              trailing: const Icon(Icons.keyboard_arrow_right),
            ),
            Expanded(
              child: widget.events.isEmpty
                  ? Center(child: Text(context.tr("news.empty")))
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        child: PageView.builder(
                          controller: pageController,
                          itemCount: widget.events.length,
                          itemBuilder: (context, index) {
                            return _EventCardContent(
                              event: widget.events[index],
                              appRegion: widget.appRegion,
                            );
                          },
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 12.0),
          ],
        ),
      ),
    );
  }
}

class _EventCardContent extends StatelessWidget {
  final BdoNews event;
  final BDORegion appRegion;

  const _EventCardContent({required this.event, required this.appRegion});

  @override
  Widget build(BuildContext context) {
    final days = event.daysUntilDeadline;
    return InkWell(
      onTap: () => launchURL(event.resolveUrl(appRegion)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          event.thumbnail == null
              ? Container(color: Theme.of(context).colorScheme.surfaceDim)
              : Image.network(
                  event.thumbnail!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Theme.of(context).colorScheme.surfaceDim,
                  ),
                ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8.0),
              color: Colors.black.withValues(alpha: 0.6),
              child: Text(
                event.title,
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
              child: Chip(
                label: Text("D-$days"),
                visualDensity: VisualDensity.compact,
              ),
            ),
        ],
      ),
    );
  }
}

/// 주요 업데이트 + 연구소 업데이트 카드 (highlights)
class _HighlightsCard extends StatelessWidget {
  final BdoNewsHighlights? highlights;
  final BDORegion appRegion;

  const _HighlightsCard({required this.highlights, required this.appRegion});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () => context.goWithGa('/news'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: Icon(FeaturesIcon.news),
              title: Text(
                context.tr("news.news"),
                style: TextTheme.of(context).titleMedium,
              ),
              trailing: const Icon(Icons.keyboard_arrow_right),
            ),
            if (highlights?.latestMajorUpdate != null)
              _HighlightTile(
                label: context.tr("news.majorUpdate"),
                news: highlights!.latestMajorUpdate!,
                appRegion: appRegion,
              ),
            if (highlights?.latestLabUpdate != null)
              _HighlightTile(
                label: context.tr("news.labUpdate"),
                news: highlights!.latestLabUpdate!,
                appRegion: appRegion,
              ),
          ],
        ),
      ),
    );
  }
}

class _HighlightTile extends StatelessWidget {
  final String label;
  final BdoNews news;
  final BDORegion appRegion;

  const _HighlightTile({
    required this.label,
    required this.news,
    required this.appRegion,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => launchURL(news.resolveUrl(appRegion)),
      title: Text(label, style: TextTheme.of(context).labelMedium),
      subtitle: Text(
        news.title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        DateFormat('yyyy.MM.dd').format(news.publishedAt),
        style: TextTheme.of(context).bodySmall,
      ),
    );
  }
}
