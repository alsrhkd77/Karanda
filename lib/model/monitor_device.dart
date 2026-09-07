import 'dart:ui';

/// 오버레이를 표시할 모니터.
///
/// [rect]는 **물리 픽셀**(가상 데스크톱 좌표, 작업표시줄 포함 모니터 전체 영역)이다.
/// 오버레이 위젯 위치가 논리 픽셀인 것과 구분해야 한다.
///
/// 동등성은 식별자([deviceID], [name])로만 판단한다. [rect]는 해상도·배율 변경으로 얼마든지
/// 바뀌는 기하 정보이지 식별자가 아니다. 저장된 [rect]는 참고용이며, 실제 기준은 항상 로드
/// 시점의 런타임 열거 결과다(`OverlayRepository.loadSettings`).
class MonitorDevice {
  String name;
  String deviceID;
  Rect rect;

  MonitorDevice({
    required this.name,
    required this.deviceID,
    required this.rect,
  });

  factory MonitorDevice.fromJson(Map json) {
    return MonitorDevice(
      name: json["name"],
      deviceID: json["deviceID"],
      rect: Rect.fromLTWH(
        json["left"],
        json["top"],
        json["width"],
        json["height"],
      ),
    );
  }

  Map toJson() {
    return {
      "name": name,
      "deviceID": deviceID,
      "left": rect.left,
      "top": rect.top,
      "width": rect.width,
      "height": rect.height,
    };
  }

  @override
  bool operator ==(Object other) {
    return other is MonitorDevice &&
        runtimeType == other.runtimeType &&
        deviceID == other.deviceID &&
        name == other.name;
  }

  @override
  int get hashCode => Object.hash(deviceID, name);

  @override
  String toString() {
    return "ID: $deviceID, name: $name, rect: ${rect.toString()}";
  }
}
