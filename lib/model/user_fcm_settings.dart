import 'package:karanda/enums/bdo_news_category.dart';
import 'package:karanda/enums/bdo_region.dart';

class UserFcmSettings {
  String token;
  BDORegion region;
  bool partyFinder;

  /// 뉴스 알림 설정 (Web 전용 — 서버가 토큰 개별 발송 대상 판단에 사용).
  /// 갱신은 `PATCH /fcm/settings/news`로만 하며 [toJson]에는 포함하지 않는다
  /// (기존 save API는 뉴스 설정을 덮어쓰지 않도록 서버와 계약됨).
  bool newsNotify;
  final Set<BdoNewsCategory> newsCategories = {};

  UserFcmSettings({
    required this.token,
    required this.region,
    this.partyFinder = false,
    this.newsNotify = false,
    Set<BdoNewsCategory>? newsCategories,
  }) {
    this.newsCategories.addAll(newsCategories ?? {});
  }

  factory UserFcmSettings.fromJson(Map json) {
    return UserFcmSettings(
      token: json["token"],
      region: BDORegion.values.byName(json["region"]),
      partyFinder: json["partyFinder"] ?? false,
      newsNotify: json["newsNotify"] ?? false,
      newsCategories: Set.from(
        (json["newsCategories"] ?? []).map(
          (name) => BdoNewsCategory.byServerName(name),
        ),
      ),
    );
  }

  Map toJson() {
    return {
      "token": token,
      "region": region.name,
      "partyFinder": partyFinder,
    };
  }
}
