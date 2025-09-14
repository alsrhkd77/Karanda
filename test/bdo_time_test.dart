import 'package:flutter_test/flutter_test.dart';
import 'package:karanda/utils/bdo_time.dart';

void main(){
  test('BDO time test', (){
    final testTimes = <DateTime>[
      DateTime.utc(2025, 8, 28, 3, 39),
      DateTime.utc(2025, 8, 28, 8, 0),
      DateTime.utc(2025, 8, 28, 23, 50),
      DateTime.utc(2025, 8, 28, 0, 19, 40),  // 밤 시간대 (UTC)
      DateTime.utc(2025, 8, 28, 0, 19, 50),  // 밤 시간대 (UTC)
      DateTime.utc(2025, 8, 28, 0, 19, 55),  // 밤 시간대 (UTC)
      DateTime.utc(2025, 8, 28, 0, 19, 59),  // 밤 시간대 (UTC)
      DateTime.utc(2025, 8, 28, 7, 39),   // 낮 시간대 (UTC)
      //DateTime.now(),                    // 현재 로컬 시각
    ];

    for (final time in testTimes) {
      final bdo = BdoTime(time);

      print('============================');
      print('테스트 시각 (입력값): $time');
      print('UTC 변환: ${time.toUtc()}');
      print('인게임 시각: ${bdo.bdoTime.hour.toString().padLeft(2, '0')}:${bdo.bdoTime.minute.toString().padLeft(2, '0')}');
      print('밤 여부: ${bdo.isNight ? '🌙 밤' : '☀ 낮'}');
      print('마지막 전환 시각(UTC): ${bdo.lastTransition}');
      print('다음 전환 시각(UTC): ${bdo.nextTransition}');
      print('진행률: ${(bdo.progress * 100).toStringAsFixed(1)}%');
    }
  });
}