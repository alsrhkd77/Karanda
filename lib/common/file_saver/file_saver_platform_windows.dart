import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:win32/win32.dart';
import 'dart:developer' as developer;

class FileSaverPlatform {
  void saveImage(Uint8List data, String fileName) {
    try {
      final dir = _getPath(FOLDERID_Downloads);
      if(dir == null){
        throw Exception("Cannot find path. FOLDERID: $FOLDERID_Downloads");
      }
      final file = File("$dir/$fileName");
      file.writeAsBytesSync(data);
    } catch (e) {
      developer.log("Failed to save image file.\n$e");
    }
  }

  String? _getPath(String folderID) {
    final Pointer<Pointer<Utf16>> pathPtrPtr = calloc<Pointer<Utf16>>();
    final Pointer<GUID> knownFolderID = calloc<GUID>()..ref.setGUID(folderID);

    try {
      final int hr = SHGetKnownFolderPath(
        knownFolderID,
        KNOWN_FOLDER_FLAG.KF_FLAG_DEFAULT,
        NULL,
        pathPtrPtr,
      );

      if (FAILED(hr)) {
        if (hr == E_INVALIDARG || hr == E_FAIL) {
          throw WindowsException(hr);
        }
        return null;
      }

      final String path = pathPtrPtr.value.toDartString();
      return path;
    } finally {
      calloc.free(pathPtrPtr);
      calloc.free(knownFolderID);
    }
  }
}