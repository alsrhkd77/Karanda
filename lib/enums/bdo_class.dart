enum BDOClass {
  unknown,
  warrior,
  ranger,
  sorceress,
  berserker,
  tamer,
  musa,
  maehwa,
  valkyrie,
  kunoichi,
  ninja,
  wizard,
  witch,
  striker,
  mystic,
  lahn,
  archer,
  darkKnight,
  shai,
  guardian,
  hashashin,
  nova,
  sage,
  corsair,
  drakania,
  woosa,
  maegu,
  scholar,
  dosa,
  deadeye,
  wukong;

  /// 서버는 mainClass를 자유 문자열로 내려주므로(신규 클래스 추가 등) 이 enum에 없는 값이 올 수 있다.
  /// 그때 로그인 전체가 막히지 않도록 미지 값은 [unknown]으로 폴백한다.
  static BDOClass fromName(String? value) =>
      values.firstWhere((e) => e.name == value, orElse: () => unknown);
}
