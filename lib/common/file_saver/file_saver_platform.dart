import 'dart:typed_data';

class FileSaverPlatform {
  /// Save [Uint8List] to image in platform default download folder.
  void saveImage(Uint8List data, String fileName) =>
      throw UnsupportedError('Failed to save. Platform unsupported.');
}
