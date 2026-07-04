import 'package:karanda/enums/bdo_news_category.dart';
import 'package:karanda/enums/bdo_region.dart';

/// 뉴스 알림 설정.
///
/// - Windows: 토스트 표시 필터 기준 (로컬 저장)
/// - Android: FCM 토픽 구독 상태의 로컬 소스 (로컬 저장, [subscribedRegion]으로 재구독 관리)
/// - Web: 서버 저장이 원본이며 로컬 값은 UI 표시용 캐시
class BdoNewsNotificationSettings {
  bool notify;
  final Set<BdoNewsCategory> categories = {};

  /// Android에서 마지막으로 토픽을 구독한 리전 (리전 변경 시 이전 토픽 해제용)
  BDORegion? subscribedRegion;

  BdoNewsNotificationSettings({
    this.notify = false,
    Set<BdoNewsCategory>? categories,
    this.subscribedRegion,
  }) {
    this.categories.addAll(categories ?? {});
  }

  factory BdoNewsNotificationSettings.fromJson(Map json) {
    return BdoNewsNotificationSettings(
      notify: json["notify"] ?? false,
      categories: Set.from(
        (json["categories"] ?? []).map(
          (name) => BdoNewsCategory.values.byName(name),
        ),
      ),
      subscribedRegion: json["subscribedRegion"] == null
          ? null
          : BDORegion.values.byName(json["subscribedRegion"]),
    );
  }

  Map toJson() {
    return {
      "notify": notify,
      "categories": categories.map((value) => value.name).toList(),
      "subscribedRegion": subscribedRegion?.name,
    };
  }
}
