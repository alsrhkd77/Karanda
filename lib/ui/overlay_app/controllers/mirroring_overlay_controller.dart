import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/services.dart';
import 'package:flutter_box_transform/flutter_box_transform.dart';
import 'package:karanda/enums/box_sizing_mode.dart';
import 'package:karanda/enums/mirror_crop_mode.dart';
import 'package:karanda/model/mirroring_settings.dart';
import 'package:karanda/model/overlay_settings.dart';
import 'package:karanda/ui/overlay_app/controllers/overlay_widget_controller.dart';
import 'package:karanda/utils/overlay_window_utils/overlay_window_utils.dart';
import 'package:karanda/utils/window_mirror/window_mirror.dart';

/// 미러링 오버레이 컨트롤러.
/// DWM 썸네일의 등록/갱신/해제를 담당하며, 박스 rect(논리 픽셀)를 물리 픽셀로
/// 변환해 썸네일 목적지 영역과 동기화한다.
class MirroringOverlayController extends OverlayWidgetController {
  final WindowMirrorUtils _mirror = WindowMirrorUtils();
  late final StreamSubscription _settings;

  MirroringSettings _mirroringSettings = MirroringSettings();
  int _sourceHandle = 0;
  int _thumbnail = 0;
  double _devicePixelRatio = 1.0;

  MirroringOverlayController({
    required super.service,
    required super.key,
    required super.defaultRect,
    required super.constraints,
  }) {
    /* 박스 크기 조절 방식: 비율 고정 시 종횡비 보존(scale), 아니면 자유(freeform) */
    boxController.setResizeModeResolver(_resolveResizeMode, notify: false);
    _settings = service.settingsStream.listen(_onSettingsUpdate);
    service.registerCallback(key: key.name, callback: _onSourceMessage);
  }

  /// 미러링 소스가 선택되어 있는지 여부
  bool get hasSource => _sourceHandle != 0;

  /// 위젯 build 시점에 주입되는 devicePixelRatio (논리→물리 픽셀 변환용).
  /// 모니터 변경 등으로 값이 바뀌면 썸네일 목적지 영역을 재동기화한다.
  set devicePixelRatio(double value) {
    if (value == _devicePixelRatio) return;
    _devicePixelRatio = value;
    _syncThumbnail();
  }

  ResizeMode _resolveResizeMode() {
    return _mirroringSettings.boxSizingMode == BoxSizingMode.ratio
        ? ResizeMode.scale
        : ResizeMode.freeform;
  }

  /// 메인 창에서 전송한 미러링 소스(HWND) 수신. 세션 한정 값.
  void _onSourceMessage(MethodCall call) {
    try {
      final data = jsonDecode(call.arguments);
      _setSource(data["sourceHandle"] ?? 0);
    } catch (e, s) {
      developer.log("Failed to parse mirroring source message",
          name: "mirroring", error: e, stackTrace: s);
    }
  }

  void _setSource(int handle) {
    if (handle == _sourceHandle && _thumbnail != 0) return;
    if (_thumbnail != 0) {
      _mirror.unregisterThumbnail(_thumbnail);
      _thumbnail = 0;
    }
    _sourceHandle = handle;
    if (handle != 0) {
      final destination = OverlayWindowUtils().getOverlayWindowHandle();
      if (destination != 0) {
        _thumbnail =
            _mirror.registerThumbnail(destination: destination, source: handle);
        if (_thumbnail == 0) {
          developer.log("Failed to register mirroring thumbnail",
              name: "mirroring");
        }
      }
    }
    notifyListeners();
  }

  void _onSettingsUpdate(OverlaySettings value) {
    _mirroringSettings = value.mirroringSettings;
    _applyBoxRatio();
    notifyListeners();
  }

  /// 비율 고정 모드에서 박스 rect를 목표 종횡비로 스냅 (너비 유지, 높이 조정)
  void _applyBoxRatio() {
    if (_mirroringSettings.boxSizingMode != BoxSizingMode.ratio) return;
    if (_mirroringSettings.boxAspectWidth <= 0 ||
        _mirroringSettings.boxAspectHeight <= 0) {
      return;
    }
    final rect = boxController.rect;
    final height = rect.width *
        _mirroringSettings.boxAspectHeight /
        _mirroringSettings.boxAspectWidth;
    if ((rect.height - height).abs() < 0.5) return;
    boxController.setRect(
      Rect.fromLTWH(rect.left, rect.top, rect.width, height),
    );
  }

  /// 상태 변경(활성화·투명도·편집 모드·위치·설정) 시마다 썸네일 속성 동기화
  @override
  void notifyListeners() {
    _syncThumbnail();
    super.notifyListeners();
  }

  void _syncThumbnail() {
    if (_thumbnail == 0) return;
    final rect = boxController.rect;
    _mirror.updateThumbnail(
      _thumbnail,
      destination: Rect.fromLTRB(
        rect.left * _devicePixelRatio,
        rect.top * _devicePixelRatio,
        rect.right * _devicePixelRatio,
        rect.bottom * _devicePixelRatio,
      ),
      source: _computeSourceRect(),
      opacity: opacity,
      visible: activated && !editMode,
    );
  }

  /// 크롭 모드에 따른 소스 영역(소스 창 클라이언트 기준 물리 픽셀) 계산.
  /// DWM은 이전 rcSource를 유지하므로 전체 모드도 명시적으로 전체 영역을 전달한다.
  Rect? _computeSourceRect() {
    final size = _mirror.getClientSize(_sourceHandle);
    if (size == null) return null;
    switch (_mirroringSettings.cropMode) {
      case MirrorCropMode.full:
        return Rect.fromLTWH(0, 0, size.width, size.height);
      case MirrorCropMode.ratio:
        if (_mirroringSettings.cropAspectWidth <= 0 ||
            _mirroringSettings.cropAspectHeight <= 0) {
          return Rect.fromLTWH(0, 0, size.width, size.height);
        }
        final target = _mirroringSettings.cropAspectWidth /
            _mirroringSettings.cropAspectHeight;
        double width = size.width;
        double height = size.height;
        if (size.width / size.height > target) {
          width = size.height * target;
        } else {
          height = size.width / target;
        }
        return Rect.fromLTWH(
          (size.width - width) / 2,
          (size.height - height) / 2,
          width,
          height,
        );
      case MirrorCropMode.custom:
        final region = _mirroringSettings.customRegion;
        if (region == null || region.isEmpty) {
          return Rect.fromLTWH(0, 0, size.width, size.height);
        }
        /* 소스 클라이언트 영역을 벗어나지 않도록 교차 영역 사용 */
        final intersection =
            region.intersect(Rect.fromLTWH(0, 0, size.width, size.height));
        if (intersection.isEmpty) {
          return Rect.fromLTWH(0, 0, size.width, size.height);
        }
        return intersection;
    }
  }

  @override
  void dispose() {
    if (_thumbnail != 0) {
      _mirror.unregisterThumbnail(_thumbnail);
      _thumbnail = 0;
    }
    service.unregisterCallback(key.name);
    _settings.cancel();
    super.dispose();
  }
}
