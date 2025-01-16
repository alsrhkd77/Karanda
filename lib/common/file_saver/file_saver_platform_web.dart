import 'dart:js_interop';
import 'dart:typed_data';

class FileSaverPlatform {
  void saveImage(Uint8List data, String fileName) {
    _saveAsFile(data.toJS, fileName);
  }
}

@JS('saveAsFileJS')
external void _saveAsFile(JSUint8Array bytes, String fileName);
