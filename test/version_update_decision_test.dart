import 'package:flutter_test/flutter_test.dart';
import 'package:karanda/model/version.dart';

/// 업데이트 필요 여부 판정식.
///
/// `InitializerService`(시작 시)와 `VersionService`(실행 중)가 **같은 식**을 써야 두 경로의 판단이
/// 갈리지 않는다. 이 헬퍼는 그 식을 한 곳에 고정해 두기 위한 테스트용 표현이다.
bool updateNeeded(Version current, Version latest) => !current.isNewerThan(latest);

Version v(String text) => Version.fromString(text);

void main() {
  group('Version.isNewerThan', () {
    test('같은 버전은 true (이름과 달리 "최신이거나 같으면")', () {
      expect(v('2.18.1').isNewerThan(v('2.18.1')), isTrue);
    });

    test('major 비교', () {
      expect(v('3.0.0').isNewerThan(v('2.99.99')), isTrue);
      expect(v('2.99.99').isNewerThan(v('3.0.0')), isFalse);
    });

    test('minor 비교', () {
      expect(v('2.19.0').isNewerThan(v('2.18.9')), isTrue);
      expect(v('2.18.9').isNewerThan(v('2.19.0')), isFalse);
    });

    test('patch 비교', () {
      expect(v('2.18.2').isNewerThan(v('2.18.1')), isTrue);
      expect(v('2.18.1').isNewerThan(v('2.18.2')), isFalse);
    });
  });

  group('업데이트 필요 판정', () {
    test('최신이 더 높으면 업데이트가 필요하다', () {
      expect(updateNeeded(v('2.18.1'), v('2.19.0')), isTrue);
      expect(updateNeeded(v('2.18.1'), v('3.0.0')), isTrue);
      expect(updateNeeded(v('2.18.1'), v('2.18.2')), isTrue);
    });

    test('같은 버전이면 업데이트가 필요 없다', () {
      expect(updateNeeded(v('2.18.1'), v('2.18.1')), isFalse);
    });

    test('로컬이 더 높아도 업데이트하지 않는다(개발 빌드)', () {
      expect(updateNeeded(v('2.19.0'), v('2.18.1')), isFalse);
    });

    test(
        'getLatestVersion 실패 시 반환되는 0.0.0은 "업데이트 없음"이다 '
        '— 별도 가드 없이 이 식만으로 성립한다는 전제를 고정한다', () {
      final failed = Version(major: 0, minor: 0, patch: 0, text: "");
      expect(updateNeeded(v('2.18.1'), failed), isFalse);
    });
  });
}
