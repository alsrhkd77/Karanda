import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:karanda/utils/file_saver/file_save_result.dart';
import 'package:share_plus/share_plus.dart';
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

  /// Windows는 다운로드 폴더에 바로 쓰고, 모바일은 공유 시트로 넘긴다.
  ///
  /// 모바일에 다운로드 폴더 저장을 쓰지 않는 이유: Android는 scoped storage 때문에
  /// 공용 다운로드 폴더에 직접 쓸 수 없고, 앱 전용 폴더에 저장하면 사용자가 파일을
  /// 다시 찾아내기 어렵다. 이 기능의 목적이 "문의에 첨부"이므로 공유 시트가 더 짧은 경로다.
  ///
  /// 실패는 호출 측이 사용자에게 알릴 수 있도록 그대로 전파한다.
  Future<FileSaveResult> saveBytes(Uint8List data, String fileName) async {
    if (Platform.isWindows) {
      final dir = _getPath(FOLDERID_Downloads);
      if (dir == null) {
        throw Exception("Cannot find path. FOLDERID: $FOLDERID_Downloads");
      }
      await File("$dir/$fileName").writeAsBytes(data);
      return FileSaveResult.saved;
    }

    if (Platform.isAndroid || Platform.isIOS) {
      // 공유 시트는 실제 파일 경로를 요구하므로 앱 캐시에 임시 파일을 먼저 쓴다.
      final file = File("${Directory.systemTemp.path}/$fileName");
      await file.writeAsBytes(data);
      await SharePlus.instance.share(ShareParams(files: [XFile(file.path)]));
      return FileSaveResult.shared;
    }

    return FileSaveResult.unsupported;
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
