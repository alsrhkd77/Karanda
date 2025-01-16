import 'dart:typed_data';

class FileSaverPlatform {
  void saveImage(Uint8List data, String fileName) =>
      throw UnsupportedError('Failed to save. Platform unsupported.');
}
