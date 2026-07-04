enum BDORegion {
  KR,
  NA,
  EU,
  JP,

  /// 뉴스 전용 (검은사막 연구소). 게임 서비스 리전이 아니므로
  /// 리전 선택 UI·라우트 검증 등에는 [gameRegions]를 사용할 것.
  LAB;

  /// 게임 서비스 리전 (LAB 제외)
  static const List<BDORegion> gameRegions = [KR, NA, EU, JP];
}
