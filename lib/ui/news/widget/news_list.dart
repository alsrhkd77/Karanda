import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:karanda/model/bdo_news.dart';
import 'package:karanda/enums/bdo_region.dart';
import 'package:karanda/ui/news/widget/news_list_item.dart';

/// 반응형 뉴스 리스트 본체 — 행 사이 구분선으로 항목을 구분하는 리스트 스타일
class NewsList extends StatelessWidget {
  final List<BdoNews> newsList;
  final BDORegion appRegion;
  final Future<void> Function() onRefresh;

  const NewsList({
    super.key,
    required this.newsList,
    required this.appRegion,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final layout = NewsListLayout.byWidth(constraints.maxWidth);
        return RefreshIndicator(
          onRefresh: onRefresh,
          child: newsList.isEmpty
              ? ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(48.0),
                      child: Center(child: Text(context.tr("news.empty"))),
                    ),
                  ],
                )
              : ListView.separated(
                  itemCount: newsList.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1.0),
                  itemBuilder: (context, index) {
                    return NewsListItem(
                      news: newsList[index],
                      appRegion: appRegion,
                      layout: layout,
                    );
                  },
                ),
        );
      },
    );
  }
}
