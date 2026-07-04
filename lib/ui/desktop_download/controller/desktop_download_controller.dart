import 'package:flutter/foundation.dart';
import 'package:karanda/model/version.dart';
import 'package:karanda/repository/version_repository.dart';
import 'package:karanda/utils/api_endpoints/karanda_api.dart';
import 'package:karanda/utils/launch_url.dart';
import 'package:logging/logging.dart';

/// Karanda Desktop 다운로드 페이지 운영 로그.
final _log = Logger('desktop_download');

/// 웹 전용 데스크톱 설치 파일 다운로드 페이지 컨트롤러.
///
/// 최신 버전 정보를 조회해 표시하고, 최신 `SetupKaranda.exe` 다운로드를 트리거한다.
class DesktopDownloadController extends ChangeNotifier {
  final VersionRepository _versionRepository;

  bool _isLoading = true;
  Version? _latestVersion;

  bool get isLoading => _isLoading;

  /// 최신 버전. 조회에 실패했거나 알 수 없으면 `null`.
  Version? get latestVersion => _latestVersion;

  DesktopDownloadController({required VersionRepository versionRepository})
      : _versionRepository = versionRepository {
    loadLatestVersion();
  }

  Future<void> loadLatestVersion() async {
    _isLoading = true;
    notifyListeners();
    try {
      final version = await _versionRepository.getLatestVersion();
      // 조회 실패 시 빈 문자열의 버전이 반환되므로 null 처리한다.
      _latestVersion = version.text.isEmpty ? null : version;
      _log.fine('Loaded latest desktop version: ${version.text}');
    } catch (e, s) {
      _latestVersion = null;
      _log.fine('Failed to load latest desktop version', e, s);
    }
    _isLoading = false;
    notifyListeners();
  }

  /// 최신 설치 파일 다운로드를 시작한다(웹 브라우저 다운로드).
  void download() {
    _log.info('Desktop installer download requested');
    launchURL(KarandaApi.latestVersionMirrors.first);
  }
}
