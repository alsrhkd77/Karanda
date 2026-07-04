import 'package:karanda/enums/bdo_news_action.dart';
import 'package:karanda/enums/bdo_news_category.dart';
import 'package:karanda/enums/bdo_region.dart';

class BdoNews {
  final String id;
  final BDORegion region;
  final BdoNewsCategory category;
  final String title;

  /// 원본 링크 (LAB은 ko-KR 기준 URL — [resolveUrl]로 언어 치환)
  final String url;
  final String? thumbnail;
  final DateTime publishedAt;

  /// 주요 업데이트 여부. UPDATE / LAB 카테고리에서만 의미 있음
  final bool isMajor;

  /// 이벤트 마감일. EVENT 카테고리 전용, null = 상시 이벤트.
  /// 이벤트 연장(UPDATED) 수신 시 갱신된다.
  DateTime? deadline;

  BdoNews({
    required this.id,
    required this.region,
    required this.category,
    required this.title,
    required this.url,
    this.thumbnail,
    required this.publishedAt,
    this.isMajor = false,
    this.deadline,
  });

  factory BdoNews.fromJson(Map json) {
    return BdoNews(
      id: json["id"],
      region: BDORegion.values.byName(json["region"]),
      category: BdoNewsCategory.byServerName(json["category"]),
      title: json["title"],
      url: json["url"],
      thumbnail: (json["thumbnail"] as String?)?.isEmpty ?? true
          ? null
          : json["thumbnail"],
      publishedAt: DateTime.parse(json["publishedAt"]),
      isMajor: json["isMajor"] ?? false,
      deadline:
          json["deadline"] == null ? null : DateTime.parse(json["deadline"]),
    );
  }

  /// FCM data payload(모든 값이 문자열)에서 변환
  factory BdoNews.fromFcmData(Map<String, dynamic> data) {
    return BdoNews(
      id: data["id"],
      region: BDORegion.values.byName(data["region"]),
      category: BdoNewsCategory.byServerName(data["category"]),
      title: data["title"],
      url: data["url"],
      thumbnail:
          (data["thumbnail"] as String?)?.isEmpty ?? true ? null : data["thumbnail"],
      publishedAt: DateTime.parse(data["publishedAt"]),
      isMajor: data["isMajor"] == "true",
      deadline: (data["deadline"] as String?)?.isEmpty ?? true
          ? null
          : DateTime.parse(data["deadline"]!),
    );
  }

  /// 앱 설정 리전에 맞는 URL 반환.
  /// LAB 뉴스는 ko-KR 기준으로 저장되므로 KR 외 리전은 en-US로 치환한다.
  String resolveUrl(BDORegion appRegion) {
    if (region != BDORegion.LAB) return url;
    final locale = appRegion == BDORegion.KR ? 'ko-KR' : 'en-US';
    return url.replaceFirst('/ko-KR/', '/$locale/');
  }

  /// 마감까지 남은 일수. 상시 이벤트(null)는 null, 오늘 마감은 0, 지났으면 음수.
  int? get daysUntilDeadline {
    if (deadline == null) return null;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(deadline!.year, deadline!.month, deadline!.day);
    return target.difference(today).inDays;
  }

  /// 진행 중 여부 (상시 이벤트 포함)
  bool get inProgress {
    final days = daysUntilDeadline;
    return days == null || days > 0;
  }
}

class BdoNewsHighlights {
  final BdoNews? latestMajorUpdate;
  final BdoNews? latestLabUpdate;

  BdoNewsHighlights({this.latestMajorUpdate, this.latestLabUpdate});

  factory BdoNewsHighlights.fromJson(Map json) {
    return BdoNewsHighlights(
      latestMajorUpdate: json["latestMajorUpdate"] == null
          ? null
          : BdoNews.fromJson(json["latestMajorUpdate"]),
      latestLabUpdate: json["latestLabUpdate"] == null
          ? null
          : BdoNews.fromJson(json["latestLabUpdate"]),
    );
  }
}

/// 실시간(STOMP·FCM) 뉴스 메시지
class BdoNewsMessage {
  final BdoNewsAction action;
  final BdoNews news;

  BdoNewsMessage({required this.action, required this.news});

  factory BdoNewsMessage.fromJson(Map json) {
    return BdoNewsMessage(
      action: BdoNewsAction.byServerName(json["action"]),
      news: BdoNews.fromJson(json),
    );
  }

  factory BdoNewsMessage.fromFcmData(Map<String, dynamic> data) {
    return BdoNewsMessage(
      action: BdoNewsAction.byServerName(data["action"]),
      news: BdoNews.fromFcmData(data),
    );
  }
}
