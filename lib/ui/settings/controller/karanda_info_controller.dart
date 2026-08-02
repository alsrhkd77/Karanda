import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:karanda/repository/version_repository.dart';

/// 앱 정보 페이지 컨트롤러.
///
/// 버전 정보는 `VersionRepository`에서 받는다. 이 페이지는 Web·Android에서도 열리므로
/// Windows 전용인 `VersionService`에 의존하면 안 된다.
class KarandaInfoController extends ChangeNotifier {
  final VersionRepository _versionRepository;

  String? _version;
  String? _buildNumber;

  KarandaInfoController({required VersionRepository versionRepository})
      : _versionRepository = versionRepository;

  bool get isLoading => _version == null;

  String get version => _version ?? "unknown";

  String get buildNumber => _buildNumber ?? "unknown";

  /// 실행 플랫폼 표기는 UI 관심사라 여기에 남긴다.
  String get platform =>
      kIsWeb ? "WEB" : Platform.operatingSystem.toUpperCase();

  Future<void> load() async {
    _version = (await _versionRepository.getCurrentVersion()).text;
    _buildNumber = await _versionRepository.getBuildNumber();
    notifyListeners();
  }
}
