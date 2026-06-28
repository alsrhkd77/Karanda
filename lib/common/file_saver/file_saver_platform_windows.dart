import 'dart:io';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';
import 'dart:developer' as developer;

class FileSaverPlatform {
  void saveImage(Uint8List data, String fileName) {
    try {
      final dir = _getDownloadsPath();
      if (dir == null) {
        throw Exception("Cannot find Downloads folder path.");
      }
      final file = File("$dir/$fileName");
      file.writeAsBytesSync(data);
    } catch (e) {
      developer.log("Failed to save image file.\n$e");
    }
  }

  String? _getDownloadsPath() {
    return using((arena) {
      final rfid = FOLDERID_Downloads.toNative(allocator: arena);
      try {
        final pathPtr = SHGetKnownFolderPath(rfid, KF_FLAG_DEFAULT, null);
        final path = pathPtr.toDartString();
        CoTaskMemFree(pathPtr);
        return path;
      } on WindowsException catch (e) {
        developer.log("SHGetKnownFolderPath failed.\n$e");
        return null;
      }
    });
  }
}
