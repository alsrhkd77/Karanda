import 'package:karanda/utils/file_saver/file_saver_platform.dart'
    if (dart.library.io) 'package:karanda/utils/file_saver/file_saver_platform_io.dart'
    if (dart.library.js_interop) 'package:karanda/utils/file_saver/file_saver_platform_web.dart' show FileSaverPlatform;

export 'package:karanda/utils/file_saver/file_save_result.dart';

class FileSaver extends FileSaverPlatform {}
