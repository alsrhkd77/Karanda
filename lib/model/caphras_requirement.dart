/// 카프라스 돌파 20단계까지의 누적 개수를 장비 그룹별로 담는다.
///
/// 그룹 판정은 두 방식이다.
/// - `prefixes`: `mainCategory` 안에서 이름 prefix로 판정(우두머리 무기 계열).
///   **반드시 `mainCategory`로 좁힐 것** — 안 그러면 `쿠툼의 심장` 같은 동명 재료가 섞인다.
/// - `codes`: 이름 규칙이 없는 방어구용 명시 목록.
class CaphrasRequirementGroup {
  final String id;
  final List<int> mainCategories;
  final List<String> prefixes;
  final List<int> codes;

  /// 강화 단계(앱 표기 18=고Ⅲ / 19=유Ⅳ / 20=동Ⅴ)별 누적 카프라스 개수.
  final Map<int, int> cumulative;

  const CaphrasRequirementGroup({
    required this.id,
    this.mainCategories = const [],
    this.prefixes = const [],
    this.codes = const [],
    this.cumulative = const {},
  });

  bool matches({
    required int code,
    required int mainCategory,
    required String name,
  }) {
    if (mainCategories.isNotEmpty && !mainCategories.contains(mainCategory)) {
      return false;
    }
    if (codes.isNotEmpty) {
      return codes.contains(code);
    }
    if (prefixes.isNotEmpty) {
      return prefixes.any(name.startsWith);
    }
    return false;
  }

  int? countOf(int enhancementLevel) => cumulative[enhancementLevel];

  factory CaphrasRequirementGroup.fromJson(Map json) {
    return CaphrasRequirementGroup(
      id: json["id"] ?? "",
      mainCategories: (json["main category"] as List?)?.cast<int>() ?? const [],
      prefixes: (json["prefixes"] as List?)?.cast<String>() ?? const [],
      codes: (json["codes"] as List?)?.cast<int>() ?? const [],
      cumulative: ((json["cumulative"] as Map?) ?? {}).map(
        (key, value) => MapEntry(int.parse(key.toString()), value as int),
      ),
    );
  }
}
