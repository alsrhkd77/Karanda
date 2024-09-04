import 'dart:developer' as developer;
import 'package:karanda/overlay/utils/karanda_overlay_utils.dart'
  if (dart.library.io) 'package:karanda/overlay/utils/windows_overlay_utils.dart';

void setOverlay({required String windowTitle}) {
  try {
    int handle = getWindowHandle(title: windowTitle);
    hideFrame(handle);
  } on UnsupportedError catch (e) {
    developer.log('Unsupported ${e.message}', name: 'overlay utils');
  }
}

void setFrame({required String windowTitle}) {
  try {
    int handle = getWindowHandle(title: windowTitle);
    showFrame(handle);
  } on UnsupportedError catch (e) {
    developer.log('Unsupported ${e.message}', name: 'overlay utils');
  }
}

void showOverlay({required String windowTitle}){
  try {
    int handle = getWindowHandle(title: windowTitle);
    showWindow(handle);
  } on UnsupportedError catch (e) {
    developer.log('Unsupported ${e.message}', name: 'overlay utils');
  }
}

void hideOverlay({required String windowTitle}){
  try {
    int handle = getWindowHandle(title: windowTitle);
    hideWindow(handle);
  } on UnsupportedError catch (e) {
    developer.log('Unsupported ${e.message}', name: 'overlay utils');
  }
}

void setOverlayTopMost({required String windowTitle}){
  try {
    int handle = getWindowHandle(title: windowTitle);
    setTopMost(handle);
  } on UnsupportedError catch (e) {
    developer.log('Unsupported ${e.message}', name: 'overlay utils');
  }
}
