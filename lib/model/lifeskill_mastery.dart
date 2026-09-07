/// 생활 숙련도 구간 한 줄.
///
/// 원본 표는 생활마다 열 구성이 다르다(요리는 대량요리 확률, 가공은 처리량 등).
/// 계산에 공통으로 쓰는 값만 담고 나머지는 원본 그대로 [extra]에 남긴다.
class LifeskillMasteryRow {
  final int mastery;

  /// 결과물 수량 증가율. 산출 배율은 `1 + productAmountIncrease`다.
  /// 가공처럼 이 열이 없는 생활은 0이다.
  final double productAmountIncrease;

  /// 황실 납품 은화 보너스.
  final double royalTradeSilverBonus;

  final Map<String, dynamic> extra;

  const LifeskillMasteryRow({
    required this.mastery,
    this.productAmountIncrease = 0.0,
    this.royalTradeSilverBonus = 0.0,
    this.extra = const {},
  });

  /// 결과물 산출 배율.
  double get outputMultiplier => 1 + productAmountIncrease;

  factory LifeskillMasteryRow.fromJson(Map json) {
    return LifeskillMasteryRow(
      mastery: json["mastery"] ?? 0,
      productAmountIncrease:
          (json["product amount increase"] as num?)?.toDouble() ?? 0.0,
      royalTradeSilverBonus:
          (json["royal trade silver bonus"] as num?)?.toDouble() ?? 0.0,
      extra: Map<String, dynamic>.from(json),
    );
  }
}
