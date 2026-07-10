// easy_localization이 재수출하는 intl의 TextDirection이 Flutter enum을 가리므로 숨긴다.
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:karanda/enums/bdo_news_category.dart';
import 'package:karanda/ui/core/theme/dimens.dart';
import 'package:karanda/ui/core/theme/features_icon.dart';
import 'package:karanda/ui/core/ui/karanda_app_bar.dart';
import 'package:karanda/ui/core/ui/loading_indicator.dart';
import 'package:karanda/ui/news/controller/news_controller.dart';
import 'package:karanda/ui/news/widget/news_list_item.dart';
import 'package:provider/provider.dart';

class NewsPage extends StatelessWidget {
  const NewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => NewsController(
        bdoNewsRepository: context.read(),
        appSettingsRepository: context.read(),
      )..loadNews(),
      child: Scaffold(
        appBar: KarandaAppBar(
          icon: FeaturesIcon.news,
          title: context.tr("news.news"),
        ),
        body: Consumer(
          builder: (context, NewsController controller, child) {
            if (controller.loading) {
              return const LoadingIndicator();
            } else if (controller.failed) {
              return _Failed(onRetry: controller.loadNews);
            }
            final pageWidth = MediaQuery.sizeOf(context).width;
            final horizontalPadding =
                Dimens.pageHorizontalPaddingValue(pageWidth);
            final layout =
                NewsListLayout.byWidth(pageWidth - horizontalPadding * 2);
            return RefreshIndicator(
              onRefresh: controller.loadNews,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: Dimens.constrainedPagePadding(pageWidth),
                    sliver: SliverList.list(
                      children: _sections(context, controller, layout),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  List<Widget> _sections(
    BuildContext context,
    NewsController controller,
    NewsListLayout layout,
  ) {
    final appRegion = controller.appRegion;
    final events = controller.events;
    return [
      // 주요 업데이트 (없으면 섹션 숨김)
      if (controller.majorUpdate != null) ...[
        const _Header(category: BdoNewsCategory.update),
        const Divider(),
        NewsListItem(
          news: controller.majorUpdate!,
          appRegion: appRegion,
          layout: layout,
        ),
      ],
      // 연구소 (없으면 섹션 숨김)
      if (controller.labUpdate != null) ...[
        const _Header(category: BdoNewsCategory.lab),
        const Divider(),
        NewsListItem(
          news: controller.labUpdate!,
          appRegion: appRegion,
          layout: layout,
        ),
      ],
      // 이벤트 목록
      const _Header(category: BdoNewsCategory.event),
      const Divider(),
      if (events.isEmpty)
        Padding(
          padding: const EdgeInsets.all(48.0),
          child: Center(child: Text(context.tr("news.empty"))),
        )
      else
        for (int i = 0; i < events.length; i++) ...[
          //if (i > 0) const Divider(height: 1.0),
          NewsListItem(
            news: events[i],
            appRegion: appRegion,
            layout: layout,
          ),
        ],
    ];
  }
}

class _Failed extends StatelessWidget {
  final Future<void> Function() onRetry;

  const _Failed({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(context.tr("requestFailed")),
          const SizedBox(height: 12.0),
          ElevatedButton(
            onPressed: onRetry,
            child: Text(context.tr("news.retry")),
          ),
        ],
      ),
    );
  }
}

/// 카테고리 섹션 제목 (이벤트 섹션에만 정렬·필터 메뉴)
class _Header extends StatelessWidget {
  final BdoNewsCategory category;

  const _Header({required this.category});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        context.tr("news.${category.name}"),
        style: TextTheme.of(context).titleMedium,
      ),
      trailing: category == BdoNewsCategory.event ? const _Menu() : null,
    );
  }
}

/// 이벤트 정렬·필터 메뉴 (등록일순 / 마감일순 / 상시 포함)
class _Menu extends StatelessWidget {
  const _Menu();

  static const ButtonStyle _itemStyle = ButtonStyle(
    padding: WidgetStatePropertyAll<EdgeInsetsGeometry>(
      EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final controller = context.read<NewsController>();
    // 필터 버튼이 오른쪽에 있으므로 메뉴를 버튼 오른쪽 기준(왼쪽 하단)으로 펼친다.
    // MenuAnchor는 LTR에서 왼쪽 기준으로만 펼쳐지므로, RTL로 감싸 오른쪽 정렬을 얻고
    // 각 항목은 LTR로 되돌려 아이콘·텍스트 배치를 정상 유지한다.
    return Directionality(
      textDirection: TextDirection.rtl,
      child: MenuAnchor(
        menuChildren: [
          _ltr(MenuItemButton(
            style: _itemStyle,
            leadingIcon: _radio(controller.eventSort == EventSort.registered),
            onPressed: () => controller.setEventSort(EventSort.registered),
            child: Text(context.tr("news.sortRegistered")),
          )),
          _ltr(MenuItemButton(
            style: _itemStyle,
            leadingIcon: _radio(controller.eventSort == EventSort.deadline),
            onPressed: () => controller.setEventSort(EventSort.deadline),
            child: Text(context.tr("news.sortDeadline")),
          )),
          _ltr(MenuItemButton(
            style: _itemStyle,
            // 체크 상태를 바로 확인할 수 있도록 선택 후에도 메뉴를 닫지 않는다.
            closeOnActivate: false,
            leadingIcon: Icon(
              controller.includeAlways
                  ? Icons.check_box_outlined
                  : Icons.check_box_outline_blank,
            ),
            onPressed: controller.toggleIncludeAlways,
            child: Text(context.tr("news.includeOngoing")),
          )),
        ],
        builder: (context, menuController, child) {
          return IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => menuController.isOpen
                ? menuController.close()
                : menuController.open(),
          );
        },
      ),
    );
  }

  Widget _ltr(Widget child) =>
      Directionality(textDirection: TextDirection.ltr, child: child);

  Widget _radio(bool selected) => Icon(
        selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
      );
}
