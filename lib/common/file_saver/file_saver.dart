import 'package:karanda/common/file_saver/file_saver_platform.dart'
    if (dart.library.io) 'package:karanda/common/file_saver/file_saver_platform_io.dart'
    if (dart.library.js_interop) 'package:karanda/common/file_saver/file_saver_platform_web.dart' show FileSaverPlatform;

export 'package:karanda/common/file_saver/file_save_result.dart';

class FileSaver extends FileSaverPlatform {}
