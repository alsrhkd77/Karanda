import 'dart:js_interop';
import 'dart:typed_data';

import 'package:karanda/common/file_saver/file_save_result.dart';

class FileSaverPlatform {
  void saveImage(Uint8List data, String fileName) {
    _saveAsFile(data.toJS, fileName);
  }

  /// `web/index.html`의 `saveAsFileJS`가 Blob 다운로드를 처리한다. 이미지 전용이 아니라
  /// 바이트를 그대로 Blob으로 감싸므로 텍스트 파일에도 그대로 쓸 수 있다.
  Future<FileSaveResult> saveBytes(Uint8List data, String fileName) async {
    _saveAsFile(data.toJS, fileName);
    return FileSaveResult.saved;
  }
}

@JS('saveAsFileJS')
external void _saveAsFile(JSUint8Array bytes, String fileName);
