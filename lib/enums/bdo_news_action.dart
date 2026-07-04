/// 실시간 뉴스 메시지(STOMP·FCM)의 action 종류
enum BdoNewsAction {
  created,
  updated;

  static BdoNewsAction byServerName(String value) {
    return BdoNewsAction.values.byName(value.toLowerCase());
  }
}
