/// 물물교환 계산기의 게임 사양 상수와 입력 한계.
///
/// 계산 규칙 자체는 `docs/features/bartering.md`가 계약이며, 여기 값들은 그 문서와 함께 유지한다.
/// 게임 패치로 값이 바뀌면 이 파일만 고치면 되도록 컨트롤러·위젯에 흩어져 있던 매직 넘버를 모았다.
abstract final class BarteringConstants {
  /// 보유 파레이 기본값.
  static const int defaultParley = 1000000;

  /// 교역 증서 1장이 주는 파레이.
  static const int tradeVoucherParley = 250000;

  /// 교역 증서 보유 상한(장).
  static const int maxTradeVoucher = 99;

  /// 교환처·교역품 수량 상한(개).
  static const int maxCount = 999;

  /// 보유 파레이 입력 자릿수 상한.
  static const int parleyInputLength = 7;

  /// 수량 입력 자릿수 상한. [maxCount]와 함께 유지한다.
  static const int countInputLength = 3;

  /// 배 과적 한계(적재율 170%). 무게 탭 진행 바의 상한이자 색상 경계다.
  static const double shipOverloadLimit = 1.7;
}
