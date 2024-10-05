import 'dart:developer' as developer;
import 'package:karanda/overlay/utils/karanda_overlay_utils.dart'
  if (dart.library.io) 'package:karanda/overlay/utils/windows_overlay_utils.dart';

void setOverlayMode({required double width, required double height}) {
  try {
    int handle = getOverlayWindowHandle();
    setOverlay(handle, width, height);
  } on UnsupportedError catch (e) {
    developer.log('Unsupported ${e.message}', name: 'overlay utils');
  }
}

void enableEditMode(){
  try {
    int handle = getOverlayWindowHandle();
    enableClick(handle);
  } on UnsupportedError catch (e) {
    developer.log('Unsupported ${e.message}', name: 'overlay utils');
  }
}

void disableEditMode(){
  try {
    int handle = getOverlayWindowHandle();
    disableClick(handle);
  } on UnsupportedError catch (e) {
    developer.log('Unsupported ${e.message}', name: 'overlay utils');
  }
}
