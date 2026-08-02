import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:karanda/model/version.dart';
import 'package:karanda/repository/version_repository.dart';
import 'package:karanda/service/desktop_service.dart';
import 'package:logging/logging.dart';

/// 버전 확인·업데이트 운영 로그.
final _log = Logger('version');

enum UpdateState { idle, available, downloading, failed }

/// 실행 중 새 버전을 감지하고, 사용자가 원할 때 업데이트를 수행한다(Windows 전용).
///
/// 앱은 시작할 때 [InitializerService]가 버전을 확인·강제 업데이트하지만, 오버레이·실시간 알림 때문에
/// 며칠씩 켜두는 사용자는 그 경로를 타지 않는다. 이 서비스가 실행 중의 공백을 메운다.
///
/// 자동으로 설치하지 않는다. 감지해서 알리기만 하고, 실제 실행은 사용자의 명시적 클릭을 기다린다.
class VersionService extends ChangeNotifier {
  /// 폴링 주기. 새 버전은 자주 나오지 않으므로 짧게 잡을 이유가 없다.
  static const Duration _checkInterval = Duration(hours: 6);

  final VersionRepository _versionRepository;
  final DesktopService _desktopService;

  Timer? _timer;
  UpdateState _state = UpdateState.idle;
  Version? _latestVersion;
  double _progress = 0;

  UpdateState get state => _state;

  /// 감지된 새 버전. [state]가 [UpdateState.idle]이면 의미 없다.
  Version? get latestVersion => _latestVersion;

  /// 다운로드 진행률(0.0~1.0).
  double get progress => _progress;

  VersionService({
    required VersionRepository versionRepository,
    required DesktopService desktopService,
  })  : _versionRepository = versionRepository,
        _desktopService = desktopService {
    // 앱 시작 직후에는 확인하지 않는다. InitializerService가 스플래시에서 이미 확인·강제 업데이트를
    // 마쳤으므로 기동 직후에는 항상 최신이고, 여기서 또 부르면 중복 네트워크 호출만 된다.
    _timer = Timer.periodic(_checkInterval, (_) => _check());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// 새 버전 여부를 확인한다. 실패는 삼키고 다음 주기에 재시도한다 —
  /// 일시적인 네트워크 장애로 배너가 나타났다 사라지면 안 된다.
  Future<void> _check() async {
    // 이미 사용자가 업데이트를 진행 중이면 상태를 건드리지 않는다.
    if (_state == UpdateState.downloading) return;

    try {
      final current = await _versionRepository.getCurrentVersion();
      final latest = await _versionRepository.getLatestVersion();

      // InitializerService와 동일한 식을 쓴다. Version.isNewerThan은 이름과 달리
      // "최신이거나 같으면 true"라서 두 경로가 다른 식을 쓰면 판단이 갈린다.
      // 조회 실패 시 반환되는 0.0.0도 이 식이 "업데이트 없음"으로 올바르게 처리한다.
      if (!current.isNewerThan(latest)) {
        if (_latestVersion?.text != latest.text) {
          _log.info('New version available: ${latest.text}');
        }
        _latestVersion = latest;
        _state = UpdateState.available;
        notifyListeners();
      }
    } catch (e, s) {
      _log.warning('Failed to check for a new version', e, s);
    }
  }

  /// 사용자가 업데이트를 시작했다. 완료되면 앱이 종료된다.
  Future<void> startUpdate() async {
    // 중복 다운로드를 막는 책임은 UI가 아니라 여기에 있다.
    if (_state == UpdateState.downloading) return;

    _log.info('User started the update to ${_latestVersion?.text}');
    _state = UpdateState.downloading;
    _progress = 0;
    notifyListeners();

    try {
      // dio는 수신 청크마다 진행률을 흘린다. 수십 MB짜리 설치 파일이면 한 번의 다운로드에
      // 수백~수천 번 불리는데, 그때마다 알리면 앱바가 초당 수십 번 다시 그려진다.
      // 화면에는 정수 퍼센트만 보이므로 1% 단위로 변할 때만 알린다.
      int notifiedPercent = 0;
      await for (final progress in downloadAndInstall()) {
        _progress = progress;
        final percent = (progress * 100).floor();
        if (percent != notifiedPercent) {
          notifiedPercent = percent;
          notifyListeners();
        }
      }
    } catch (e, s) {
      _log.warning('Update failed', e, s);
      _state = UpdateState.failed;
      notifyListeners();
    }
  }

  /// 다운로드 → 설치 파일 실행 → 프로세스 종료.
  ///
  /// 다운로드가 실패하면 `yield*`에서 예외가 전파되어 아래 설치 단계가 실행되지 않는다.
  /// 덕분에 성공/실패 플래그 없이도 "실패했으면 설치하지 않는다"가 성립한다.
  /// 같은 이유로 설치 파일 실행이 실패해도 [exit]에 도달하지 않아, 설치도 못 한 채 앱만
  /// 닫히는 상황이 생기지 않는다.
  Stream<double> downloadAndInstall() async* {
    yield* _versionRepository.downloadLatest();

    // 오버레이를 정리하기 전에 설치 파일부터 확인한다. 순서가 반대면 설치가 불가능한 상황에서
    // 오버레이만 없앤 채 앱이 살아남는다.
    final installer = File('${Directory.current.path}/SetupKaranda.exe');
    if (!await installer.exists()) {
      throw Exception('Installer not found: ${installer.path}');
    }

    // 마지막 진행률(100%)이 화면에 남을 시간을 준다.
    // 이 지연이 없으면 100% 알림 직후 곧바로 종료 절차로 들어가, 프레임이 그려지더라도
    // 한두 프레임 만에 창이 닫혀 사용자에게는 99%에서 멈춘 것처럼 보인다.
    await Future.delayed(const Duration(milliseconds: 700));

    // 오버레이 자식 엔진이 살아 있으면 프로세스가 완전히 죽지 않아 인스톨러가 실행 파일을
    // 교체하지 못한다(파일 잠금). 미저장 데이터 확정도 여기서 함께 이뤄진다.
    await _desktopService.prepareShutdown();

    await Process.start(installer.path, ["-t", "-l", "1000", "/silent"]);

    // 메인 창만 닫으면 다른 엔진이 프로세스를 살려둘 수 있으므로 프로세스 전체를 종료한다.
    exit(0);
  }
}
