import 'dart:developer' as developer;
import 'package:karanda/common/overlay_utils/karanda_overlay_utils.dart'
  if (dart.library.io) 'package:karanda/common/overlay_utils/windows_overlay_utils.dart';

void setOverlay({required String windowTitle}) {
  try {
    //int mainHandle = getMainWindowHandle();
    int subHandle = getOverlayWindowHandle(title: windowTitle);
    //setParent(child: subHandle, parent: mainHandle);
    setIgnoreMouseEvents(subHandle);
    setAsFrameless(subHandle);
    setOpacity(subHandle);
    setAlwaysOnTop(subHandle);
  } on UnsupportedError catch (e) {
    developer.log('Unsupported ${e.message}', name: 'overlay utils');
  }
}
