import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:karanda/enums/bdo_news_category.dart';
import 'package:karanda/ui/core/theme/features_icon.dart';
import 'package:karanda/ui/core/ui/section.dart';
import 'package:karanda/ui/news/controller/news_notification_settings_controller.dart';
import 'package:provider/provider.dart';

/// 뉴스 알림 설정 섹션.
///
/// UI는 플랫폼 공통이며 값 변경 시 동작만 다르다:
/// Windows=로컬 저장(토스트 필터) / Android=FCM 토픽 구독 / Web=서버 저장.
/// Windows는 설정-알림 페이지, Web·Android는 푸시 알림 페이지에 포함된다.
class NewsNotificationSettingsSection extends StatelessWidget {
  const NewsNotificationSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => NewsNotificationSettingsController(
        bdoNewsService: context.read(),
        bdoNewsRepository: context.read(),
        appSettingsService: context.read(),
      ),
      child: Consumer(
        builder: (context, NewsNotificationSettingsController controller,
            child) {
          final settings = controller.settings;
          if (settings == null) {
            return const SizedBox();
          }
          return Section(
            title: context.tr("news.news"),
            icon: FeaturesIcon.news,
            child: Column(
              children: [
                SwitchListTile(
                  value: settings.notify,
                  onChanged: controller.setNotify,
                  title: Text(context.tr("settings.activate notifications")),
                ),
                ...BdoNewsCategory.values.map((category) {
                  return CheckboxListTile(
                    enabled: settings.notify,
                    value: settings.categories.contains(category),
                    onChanged: (_) => controller.toggleCategory(category),
                    title: Text(context.tr("news.${category.name}")),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}
