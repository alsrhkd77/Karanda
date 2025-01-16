import 'package:karanda/common/file_saver/file_saver_platform.dart'
    if (dart.library.io) 'package:karanda/common/file_saver/file_saver_platform_windows.dart'
    if (dart.library.js_interop) 'package:karanda/common/file_saver/file_saver_platform_web.dart' show FileSaverPlatform;

class FileSaver extends FileSaverPlatform {}
