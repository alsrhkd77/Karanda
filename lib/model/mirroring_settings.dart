import 'dart:ui';

import 'package:karanda/enums/box_sizing_mode.dart';
import 'package:karanda/enums/mirror_crop_mode.dart';
import 'package:karanda/utils/extension/rect_extension.dart';

/// 미러링 오버레이의 영속 설정.
/// 미러링 소스(HWND)는 세션 한정이므로 여기에 포함하지 않는다.
class MirroringSettings {
  /// 소스 크롭 방식
  MirrorCropMode cropMode;

  /// 비율 크롭 시 사용할 종횡비 (기본 16:9)
  double cropAspectWidth;
  double cropAspectHeight;

  /// 직접 지정 크롭 영역 (소스 창 클라이언트 기준 물리 픽셀)
  Rect? customRegion;

  /// 표시 영역(오버레이 박스) 크기 조절 방식
  BoxSizingMode boxSizingMode;

  /// 박스 비율 고정 시 사용할 종횡비 (기본 16:9)
  double boxAspectWidth;
  double boxAspectHeight;

  MirroringSettings({
    this.cropMode = MirrorCropMode.full,
    this.cropAspectWidth = 16,
    this.cropAspectHeight = 9,
    this.customRegion,
    this.boxSizingMode = BoxSizingMode.free,
    this.boxAspectWidth = 16,
    this.boxAspectHeight = 9,
  });

  factory MirroringSettings.fromJson(Map json) {
    return MirroringSettings(
      cropMode: MirrorCropMode.values.byName(json["cropMode"] ?? "full"),
      cropAspectWidth: json["cropAspectWidth"]?.toDouble() ?? 16,
      cropAspectHeight: json["cropAspectHeight"]?.toDouble() ?? 9,
      customRegion: json["customRegion"] == null
          ? null
          : Rect.fromLTWH(
              json["customRegion"]["left"],
              json["customRegion"]["top"],
              json["customRegion"]["width"],
              json["customRegion"]["height"],
            ),
      boxSizingMode: BoxSizingMode.values.byName(json["boxSizingMode"] ?? "free"),
      boxAspectWidth: json["boxAspectWidth"]?.toDouble() ?? 16,
      boxAspectHeight: json["boxAspectHeight"]?.toDouble() ?? 9,
    );
  }

  Map toJson() {
    return {
      "cropMode": cropMode.name,
      "cropAspectWidth": cropAspectWidth,
      "cropAspectHeight": cropAspectHeight,
      "customRegion": customRegion?.toJson(),
      "boxSizingMode": boxSizingMode.name,
      "boxAspectWidth": boxAspectWidth,
      "boxAspectHeight": boxAspectHeight,
    };
  }
}
