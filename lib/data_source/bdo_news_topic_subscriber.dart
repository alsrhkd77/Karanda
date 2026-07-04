import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:karanda/enums/bdo_news_category.dart';
import 'package:karanda/enums/bdo_region.dart';

/// FCM 뉴스 토픽 구독/해제 — **Android 전용**.
///
/// Web용 FCM SDK는 `subscribeToTopic`을 지원하지 않으므로 Web 빌드 경로에서
/// 호출하면 안 된다 (Web은 서버가 토큰 기반으로 개별 발송, `kIsWeb` 가드 필수).
class BdoNewsTopicSubscriber {
  /// 리전+카테고리 조합의 토픽명. LAB은 리전 무관 단일 토픽.
  String topicOf(BDORegion region, BdoNewsCategory category) {
    if (category == BdoNewsCategory.lab) {
      return "news_LAB";
    }
    return "news_${region.name}_${category.serverName}";
  }

  Future<void> subscribe(String topic) async {
    await FirebaseMessaging.instance.subscribeToTopic(topic);
  }

  Future<void> unsubscribe(String topic) async {
    await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
  }
}
