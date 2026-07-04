enum BdoNewsCategory {
  notice,
  update,
  event,
  lab;

  /// 서버(API·FCM·STOMP)에서 사용하는 대문자 이름
  String get serverName => name.toUpperCase();

  static BdoNewsCategory byServerName(String value) {
    return BdoNewsCategory.values.byName(value.toLowerCase());
  }
}
