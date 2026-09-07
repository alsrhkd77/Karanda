import 'dart:typed_data';

import 'package:karanda/utils/file_saver/file_save_result.dart';

class FileSaverPlatform {
  /// Save [Uint8List] to image in platform default download folder.
  void saveImage(Uint8List data, String fileName) =>
      throw UnsupportedError('Failed to save. Platform unsupported.');

  /// Export [Uint8List] as a file. The actual behaviour differs per platform —
  /// see [FileSaveResult].
  Future<FileSaveResult> saveBytes(Uint8List data, String fileName) async =>
      FileSaveResult.unsupported;
}
