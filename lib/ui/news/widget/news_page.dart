import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:karanda/ui/core/theme/features_icon.dart';
import 'package:karanda/ui/core/ui/karanda_app_bar.dart';
import 'package:karanda/ui/core/ui/loading_indicator.dart';
import 'package:karanda/ui/news/controller/news_controller.dart';
import 'package:karanda/ui/news/widget/news_filter_bar.dart';
import 'package:karanda/ui/news/widget/news_list.dart';
import 'package:provider/provider.dart';

class NewsPage extends StatelessWidget {
  const NewsPage({super.key});

  /// 넓은 화면에서 텍스트 줄 길이가 과도하게 늘어나지 않도록 하는 목록 최대 폭
  static const double _contentsMaxWidth = 960.0;

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
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _contentsMaxWidth),
            child: Consumer(
              builder: (context, NewsController controller, child) {
                return Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 4.0,
                      ),
                      child: NewsFilterBar(),
                    ),
                    const Divider(height: 1.0),
                    Expanded(
                      child: controller.loading
                          ? const LoadingIndicator()
                          : controller.failed
                              ? _Failed(onRetry: controller.loadNews)
                              : Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                  ),
                                  child: NewsList(
                                    newsList: controller.newsList,
                                    appRegion: controller.appRegion,
                                    onRefresh: controller.loadNews,
                                  ),
                                ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
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
