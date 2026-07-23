import 'dart:ffi' hide Size;
import 'dart:ui' show Rect, Size;

import 'package:ffi/ffi.dart';
import 'package:karanda/model/window_info.dart';
import 'package:win32/win32.dart';

/* ---------- dwmapi.dll 수동 FFI 바인딩 (win32 패키지 미포함 API) ---------- */

final DynamicLibrary _dwmapi = DynamicLibrary.open('dwmapi.dll');

/// DWM_THUMBNAIL_PROPERTIES 구조체
base class _DwmThumbnailProperties extends Struct {
  @Uint32()
  external int dwFlags;
  external RECT rcDestination;
  external RECT rcSource;
  @Uint8()
  external int opacity;
  @Int32()
  external int fVisible;
  @Int32()
  external int fSourceClientAreaOnly;
}

const _dwmTnpRectDestination = 0x1;
const _dwmTnpRectSource = 0x2;
const _dwmTnpOpacity = 0x4;
const _dwmTnpVisible = 0x8;
const _dwmTnpSourceClientAreaOnly = 0x10;

final _dwmRegisterThumbnail = _dwmapi.lookupFunction<
    Int32 Function(IntPtr hwndDest, IntPtr hwndSrc, Pointer<IntPtr> phThumb),
    int Function(int, int, Pointer<IntPtr>)>('DwmRegisterThumbnail');

final _dwmUnregisterThumbnail = _dwmapi.lookupFunction<
    Int32 Function(IntPtr hThumb), int Function(int)>('DwmUnregisterThumbnail');

final _dwmUpdateThumbnailProperties = _dwmapi.lookupFunction<
    Int32 Function(IntPtr hThumb, Pointer<_DwmThumbnailProperties> props),
    int Function(
        int, Pointer<_DwmThumbnailProperties>)>('DwmUpdateThumbnailProperties');

/* ---------- 창 열거 콜백 ---------- */

final List<WindowInfo> _enumeratedWindows = [];
int _ownProcessId = 0;

int _enumWindowsProc(int hWnd, int lParam) {
  if (IsWindowVisible(hWnd) == 0) return TRUE;

  /* 자기 프로세스 창 제외 (오버레이 창 자기 미러링 방지) */
  final processId = calloc<DWORD>();
  GetWindowThreadProcessId(hWnd, processId);
  final isOwnProcess = processId.value == _ownProcessId;
  calloc.free(processId);
  if (isOwnProcess) return TRUE;

  /* 제목 없는 창 제외 */
  final length = GetWindowTextLength(hWnd);
  if (length == 0) return TRUE;

  /* cloaked 창(닫힌 UWP 앱의 유령 창 등) 제외 */
  final cloaked = calloc<DWORD>();
  DwmGetWindowAttribute(
      hWnd, DWMWINDOWATTRIBUTE.DWMWA_CLOAKED, cloaked, sizeOf<DWORD>());
  final isCloaked = cloaked.value != 0;
  calloc.free(cloaked);
  if (isCloaked) return TRUE;

  final buffer = wsalloc(length + 1);
  GetWindowText(hWnd, buffer, length + 1);
  final title = buffer.toDartString();
  free(buffer);

  _enumeratedWindows.add(WindowInfo(handle: hWnd, title: title));
  return TRUE;
}

abstract class WindowMirrorUtilsPlatform {
  List<WindowInfo> getMirrorableWindows() {
    _enumeratedWindows.clear();
    _ownProcessId = GetCurrentProcessId();
    EnumWindows(Pointer.fromFunction<WNDENUMPROC>(_enumWindowsProc, 0), 0);
    return List.unmodifiable(_enumeratedWindows);
  }

  int registerThumbnail({required int destination, required int source}) {
    final phThumb = calloc<IntPtr>();
    final hr = _dwmRegisterThumbnail(destination, source, phThumb);
    final thumbnail = FAILED(hr) ? 0 : phThumb.value;
    calloc.free(phThumb);
    return thumbnail;
  }

  void updateThumbnail(
    int thumbnail, {
    required Rect destination,
    required Rect? source,
    required int opacity,
    required bool visible,
  }) {
    final props = calloc<_DwmThumbnailProperties>();
    props.ref.dwFlags = _dwmTnpRectDestination |
        _dwmTnpOpacity |
        _dwmTnpVisible |
        _dwmTnpSourceClientAreaOnly |
        (source == null ? 0 : _dwmTnpRectSource);
    props.ref.rcDestination.left = destination.left.round();
    props.ref.rcDestination.top = destination.top.round();
    props.ref.rcDestination.right = destination.right.round();
    props.ref.rcDestination.bottom = destination.bottom.round();
    if (source != null) {
      props.ref.rcSource.left = source.left.round();
      props.ref.rcSource.top = source.top.round();
      props.ref.rcSource.right = source.right.round();
      props.ref.rcSource.bottom = source.bottom.round();
    }
    props.ref.opacity = opacity.clamp(0, 255);
    props.ref.fVisible = visible ? TRUE : FALSE;
    props.ref.fSourceClientAreaOnly = TRUE;
    _dwmUpdateThumbnailProperties(thumbnail, props);
    calloc.free(props);
  }

  void unregisterThumbnail(int thumbnail) {
    _dwmUnregisterThumbnail(thumbnail);
  }

  Size? getClientSize(int hWnd) {
    final rect = calloc<RECT>();
    final succeeded = GetClientRect(hWnd, rect) != 0;
    final size = succeeded
        ? Size(
            (rect.ref.right - rect.ref.left).toDouble(),
            (rect.ref.bottom - rect.ref.top).toDouble(),
          )
        : null;
    calloc.free(rect);
    if (size == null || size.width <= 0 || size.height <= 0) return null;
    return size;
  }

  bool isWindowValid(int hWnd) {
    return hWnd != 0 && IsWindow(hWnd) != 0;
  }
}
