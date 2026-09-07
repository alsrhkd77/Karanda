import 'dart:ui' show Locale;

import 'package:flutter/material.dart' show Colors;
import 'package:flutter_test/flutter_test.dart';
import 'package:karanda/model/lightstone_combination/combination.dart';
import 'package:karanda/model/lightstone_combination/effect.dart';
import 'package:karanda/model/lightstone_combination/lightstone.dart';
import 'package:karanda/ui/lightstone_combination/controller/lightstone_combination_controller.dart';

import 'support/fake_lightstone_combination_repository.dart';

/// 광명석 조합식 검색·필터 회귀 방지 테스트.
///
/// 검색 규칙: 키워드와 비교 대상 모두 **공백을 제거**하고, 영문은 **소문자로 통일**해 부분 일치시킨다.
/// 조합식 이름 / 조합 효과 / 광명석 이름 / 광명석 효과 네 경로 중 하나라도 맞으면 일치로 본다.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Effect effect({
    required String kr,
    required String en,
    String unitKR = "",
    String unitEN = "",
    double value = 1,
  }) {
    return Effect(
      nameKR: kr,
      nameEN: en,
      unitKR: unitKR,
      unitEN: unitEN,
      value: value,
    );
  }

  Lightstone stone({
    required int code,
    required String kr,
    required String en,
    required Effect stoneEffect,
  }) {
    return Lightstone(
      code: code,
      nameKR: kr,
      nameEN: en,
      effect: stoneEffect,
      color: Colors.red,
    );
  }

  Combination combination({
    required String kr,
    required String en,
    List<Effect> effects = const [],
    List<Lightstone> lightstones = const [],
    bool isAmplified = false,
  }) {
    // 컨트롤러가 `lightstones`를 정렬하므로 수정 가능한 리스트로 넘긴다.
    return Combination(
      nameKR: kr,
      nameEN: en,
      effects: List.of(effects),
      totalEffects: List.of(effects),
      lightstones: List.of(lightstones),
      isAmplified: isAmplified,
    );
  }

  final attackPower = effect(kr: "공격력", en: "Attack Power");
  final criticalDamage =
      effect(kr: "치명타 피해량", en: "Critical Hit Damage", unitKR: "%", unitEN: "%");

  final blazeStone = stone(
    code: 1,
    kr: "광명석 : 불꽃",
    en: "Lightstone of Fire: Blaze",
    stoneEffect: attackPower,
  );

  /// 조합 효과가 겹치도록 구성해 AND / OR 필터 차이를 드러낸다.
  /// - 화염의 각인: 공격력
  /// - 대지의 결의: 공격력 + 치명타 피해량
  /// - 바람의 속삭임: 치명타 피해량
  List<Combination> buildData() {
    return [
      combination(
        kr: "화염의 각인",
        en: "Mark of Flame",
        effects: [attackPower],
        lightstones: [blazeStone],
      ),
      combination(
        kr: "대지의 결의",
        en: "Earth Resolve",
        effects: [attackPower, criticalDamage],
      ),
      combination(
        kr: "바람의 속삭임",
        en: "Whisper of Wind",
        effects: [criticalDamage],
      ),
      combination(
        kr: "증폭된 화염의 각인",
        en: "Amplified Mark of Flame",
        effects: [attackPower],
        isAmplified: true,
      ),
      combination(
        kr: "증폭된 바람의 속삭임",
        en: "Amplified Whisper of Wind",
        effects: [criticalDamage],
        isAmplified: true,
      ),
    ];
  }

  Future<LightstoneCombinationController> build() async {
    final controller = LightstoneCombinationController(
      repository: FakeLightstoneCombinationRepository(buildData()),
    );
    await controller.getData();
    return controller;
  }

  List<String> namesOf(LightstoneCombinationController controller) {
    return controller.combination.map((e) => e.nameKR).toList();
  }

  group('Effect.match', () {
    test('한글 이름은 공백을 무시하고 부분 일치한다', () {
      expect(criticalDamage.match("치명타피해량"), isTrue);
      expect(criticalDamage.match("치명타"), isTrue);
      expect(criticalDamage.match("피해량"), isTrue);
    });

    test('영문 이름은 소문자 기준으로 부분 일치한다', () {
      expect(attackPower.match("attackpower"), isTrue);
      expect(attackPower.match("attack"), isTrue);
      // 대문자가 섞인 키워드는 호출 측에서 소문자로 정규화해 넘겨야 한다.
      expect(attackPower.match("Attack"), isFalse);
    });

    test('단위로도 일치한다', () {
      expect(criticalDamage.match("%"), isTrue);
    });

    test('어디에도 없으면 일치하지 않는다', () {
      expect(attackPower.match("회피"), isFalse);
    });
  });

  group('Lightstone.match', () {
    test('광명석 이름으로 일치한다', () {
      expect(blazeStone.match("불꽃"), isTrue);
      expect(blazeStone.match("lightstoneoffire:blaze"), isTrue);
    });

    test('이름이 다르면 광명석 효과로 판정한다', () {
      expect(blazeStone.match("공격력"), isTrue);
      expect(blazeStone.match("치명타"), isFalse);
    });
  });

  group('Combination.match', () {
    test('조합식 이름(한/영)으로 일치한다', () {
      final data = buildData().first;
      expect(data.match("화염"), isTrue);
      expect(data.match("markofflame"), isTrue);
    });

    test('조합 효과로 일치한다', () {
      final data = buildData()[2];
      expect(data.match("치명타"), isTrue);
    });

    test('포함된 광명석으로 일치한다', () {
      final data = buildData().first;
      expect(data.match("불꽃"), isTrue);
    });

    test('네 경로 어디에도 없으면 일치하지 않는다', () {
      final data = buildData()[2];
      expect(data.match("불꽃"), isFalse);
    });
  });

  group('LightstoneCombinationController 필터', () {
    test('기본값은 증폭 조합식만 보여준다', () async {
      final controller = await build();

      expect(controller.viewAmplified, isTrue);
      expect(namesOf(controller), ["증폭된 화염의 각인", "증폭된 바람의 속삭임"]);
    });

    test('증폭 보기를 끄면 일반 조합식만 보여준다', () async {
      final controller = await build();

      controller.setViewAmplified(false);

      expect(namesOf(controller), ["화염의 각인", "대지의 결의", "바람의 속삭임"]);
    });

    test('null이 들어오면 증폭 보기 설정을 바꾸지 않는다', () async {
      final controller = await build();

      controller.setViewAmplified(null);

      expect(controller.viewAmplified, isTrue);
    });

    test('OR 필터는 키워드 중 하나라도 맞는 조합식을 모두 보여준다', () async {
      final controller = await build();
      controller.setViewAmplified(false);

      controller.addKeyword("공격력");
      controller.addKeyword("치명타");

      expect(controller.useAndFilter, isFalse);
      expect(
        namesOf(controller).toSet(),
        {"화염의 각인", "대지의 결의", "바람의 속삭임"},
      );
    });

    test('AND 필터는 모든 키워드를 만족하는 조합식만 남긴다', () async {
      final controller = await build();
      controller.setViewAmplified(false);
      controller.setAndFilter(true);

      controller.addKeyword("공격력");
      controller.addKeyword("치명타");

      expect(namesOf(controller), ["대지의 결의"]);
    });

    test('필터 방식을 바꾸면 즉시 다시 계산한다', () async {
      final controller = await build();
      controller.setViewAmplified(false);
      controller.addKeyword("공격력");
      controller.addKeyword("치명타");

      expect(namesOf(controller).length, 3);

      controller.setAndFilter(true);

      expect(namesOf(controller), ["대지의 결의"]);
    });

    test('키워드를 지우면 결과가 복구된다', () async {
      final controller = await build();
      controller.setViewAmplified(false);
      controller.setAndFilter(true);
      controller.addKeyword("공격력");
      controller.addKeyword("치명타");

      controller.removeKeyword("치명타");

      expect(namesOf(controller).toSet(), {"화염의 각인", "대지의 결의"});

      controller.removeKeyword("공격력");

      expect(namesOf(controller).length, 3);
    });

    test('빈 키워드는 무시한다', () async {
      final controller = await build();
      controller.setViewAmplified(false);

      controller.addKeyword("");

      expect(controller.keywords, isEmpty);
      expect(namesOf(controller).length, 3);
    });

    test('키워드의 공백과 대소문자를 정규화한다', () async {
      final controller = await build();
      controller.setViewAmplified(false);

      controller.addKeyword("Attack Power");

      expect(namesOf(controller).toSet(), {"화염의 각인", "대지의 결의"});
    });

    test('증폭 조합식에도 같은 키워드 필터가 적용된다', () async {
      final controller = await build();

      controller.addKeyword("치명타");

      expect(namesOf(controller), ["증폭된 바람의 속삭임"]);
    });

    test('일치하는 조합식이 없으면 빈 목록이 된다', () async {
      final controller = await build();
      controller.setViewAmplified(false);

      controller.addKeyword("존재하지않는효과");

      expect(controller.combination, isEmpty);
    });
  });

  group('buildOptions (자동완성)', () {
    test('첫 항목은 항상 입력한 키워드다', () async {
      final controller = await build();

      expect(controller.buildOptions("아무거나", const Locale("ko")).first, "아무거나");
      expect(controller.buildOptions("anything", const Locale("en")).first,
          "anything");
    });

    test('한국어 로케일에서는 한글 후보를 제안한다', () async {
      final controller = await build();

      final options = controller.buildOptions("화염", const Locale("ko"));

      expect(options, contains("화염의 각인"));
      expect(options, isNot(contains("Mark of Flame")));
    });

    test('그 외 로케일에서는 영문 후보를 대소문자 무시로 제안한다', () async {
      final controller = await build();

      final options = controller.buildOptions("mark", const Locale("en"));

      expect(options, contains("Mark of Flame"));
      expect(options, isNot(contains("화염의 각인")));
    });

    test('공백을 무시하고 후보를 찾는다', () async {
      final controller = await build();

      expect(
        controller.buildOptions("화염의각인", const Locale("ko")),
        contains("화염의 각인"),
      );
      expect(
        controller.buildOptions("attack power", const Locale("en")),
        contains("Attack Power"),
      );
    });

    test('광명석 이름과 효과도 후보에 포함된다', () async {
      final controller = await build();

      expect(
        controller.buildOptions("불꽃", const Locale("ko")),
        contains("광명석 : 불꽃"),
      );
      expect(
        controller.buildOptions("공격", const Locale("ko")),
        contains("공격력"),
      );
    });

    test('증폭 조합식 이름은 후보에 넣지 않는다', () async {
      final controller = await build();

      expect(
        controller.buildOptions("증폭", const Locale("ko")),
        ["증폭"],
      );
    });
  });
}
