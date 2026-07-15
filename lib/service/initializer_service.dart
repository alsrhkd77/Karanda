import 'dart:async';
import 'dart:io';

import 'package:app_links/app_links.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:karanda/model/initializer_status.dart';
import 'package:karanda/repository/app_settings_repository.dart';
import 'package:karanda/repository/audio_player_repository.dart';
import 'package:karanda/repository/auth_repository.dart';
import 'package:karanda/repository/overlay_repository.dart';
import 'package:karanda/repository/version_repository.dart';
import 'package:karanda/service/operation_log_service.dart';
import 'package:karanda/utils/command_line_arguments.dart';
import 'package:karanda/utils/extension/go_router_extension.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

/// 앱 초기화 운영 로그.
final _log = Logger('initializer');

class InitializerService {
  final AppSettingsRepository _appSettingsRepository;
  final OverlayRepository _overlayRepository;
  final VersionRepository _versionRepository;
  final AuthRepository _authRepository;
  final AudioPlayerRepository _audioPlayerRepository;
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey;
  final GoRouter _router;
  final _status =
      BehaviorSubject<InitializerStatus>.seeded(InitializerStatus());

  /// 임계 초기화 단계(네트워크·설정 로드) 타임아웃. 초과 시 실패로 처리해 스플래시가
  /// 무한 대기하지 않게 한다.
  static const Duration _criticalStepTimeout = Duration(seconds: 10);

  /// 임계 경로 중복 실행 방지(재시도 재진입 안전).
  bool _windowsCriticalPhaseRunning = false;

  InitializerService({
    required AppSettingsRepository appSettingsRepository,
    required OverlayRepository overlayRepository,
    required VersionRepository versionRepository,
    required AuthRepository authRepository,
    required AudioPlayerRepository audioPlayerRepository,
    required GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey,
    required GoRouter router,
  })  : _appSettingsRepository = appSettingsRepository,
        _overlayRepository = overlayRepository,
        _versionRepository = versionRepository,
        _authRepository = authRepository,
        _audioPlayerRepository = audioPlayerRepository,
        _scaffoldMessengerKey = scaffoldMessengerKey,
        _router = router {
    OperationLogService.instance.initialize().then((_) {
      if (kIsWeb) {
        initializeForWeb();
      } else if (Platform.isWindows) {
        initializeForWindows();
      } else if (Platform.isAndroid) {
        initializeForAndroid();
      }
    });
  }

  Stream<InitializerStatus> get initializerStatus => _status.stream;

  Future<void> initializeForWindows() async {
    await Future.delayed(const Duration(seconds: 1));
    await _runWindowsCriticalPhase();
  }

  /// Windows 초기화. 로딩 화면이 떠 있는 동안 **모든 단계를 직렬로** 실행한 뒤 첫 화면으로 넘어간다.
  /// (백그라운드 워밍업 없이 직렬화 — 동시성 최소화로 다중 엔진 레이스·auth 상태 깜빡임을 줄인다.)
  /// 임계 단계(설정 로드 등) 실패 시 **무한 로딩 대신** 재시도 가능한 에러 상태를 emit하고, 부수
  /// 단계(오버레이·로그인·오디오)는 각자 격리·타임아웃으로 실패해도 진입을 막지 않는다.
  /// 재진입 안전(스플래시의 재시도 버튼에서 `retryForWindows`로 다시 호출).
  Future<void> _runWindowsCriticalPhase() async {
    if (_windowsCriticalPhaseRunning) return;
    _windowsCriticalPhaseRunning = true;
    try {
      _status.sink.add(InitializerStatus(progress: 0.0, message: "check update"));
      if (CommandLineArguments.forceUpdate) {
        await update();
        return;
      }
      if (!CommandLineArguments.skipUpdate) {
        try {
          final currentVersion = await _versionRepository.getCurrentVersion();
          // 최신 버전 조회는 네트워크 호출 → 타임아웃으로 무한 대기를 막는다.
          final latestVersion = await _versionRepository
              .getLatestVersion()
              .timeout(_criticalStepTimeout);
          if (!currentVersion.isNewerThan(latestVersion)) {
            await update();
            return;
          }
        } catch (e, s) {
          _log.severe('Failed to check version and update', e, s);
          _status.sink.add(InitializerStatus(
            progress: 0,
            message: "failed to update",
          ));
          await Future.delayed(const Duration(seconds: 3));
        }
      }
      _status.sink.add(InitializerStatus(progress: 0.3, message: "get settings"));
      // 설정 로드는 로컬 캐시 기반이며, 실패 시 Repository가 기본 설정으로 폴백한다
      // (앱 진입을 막지 않음). 따라서 타임아웃/에러로 임계 경로를 중단하지 않는다.
      final welcome = await _appSettingsRepository.getAppSettings();

      // 오버레이 엔진(두 번째 Flutter 엔진)은 로딩 화면이 떠 있는 이 시점에 **단독으로** 생성한다.
      // 로그인·오디오와 뒤섞어 생성하면 다중 엔진 초기화가 겹쳐 Windows에서 간헐 크래시(다중 엔진
      // `is_finalized` VM 어서션 → 프로세스 abort)를 유발하므로, 생성 시점을 앞당기고 이어지는
      // 트레이·창 세팅·500ms 대기 동안 서브 엔진이 초기화를 마칠 시간을 벌어준다.
      _status.sink.add(InitializerStatus(progress: 0.5, message: "start overlay"));
      await _prepareOverlaySafely();

      // 트레이는 트레이 모드(최소화 시작) UX에서 창 복원 수단이므로 미리 준비한다.
      _status.sink.add(InitializerStatus(progress: 0.6, message: "start tray"));
      await _startTraySafely();
      // 오버레이 엔진(위에서 생성)이 조용한 로딩 화면 동안 초기화를 마칠 시간을 주는 의도적 지연.
      // (오버레이 "ready" 대기로 바꿔봤으나, 메인의 무거운 작업을 오버레이 렌더 시점에 동기화시켜
      //  다중 엔진 크래시가 오히려 늘어 고정 지연을 유지한다.)
      await Future.delayed(const Duration(milliseconds: 500));

      // Windows는 로딩 화면이 있으므로, 부수 작업도 백그라운드(warmUp) 대신 여기서 **직렬로** 마친 뒤
      // 첫 화면으로 넘어간다. 동시성을 최소화해 다중 엔진 레이스와 auth 상태 깜빡임을 줄이는 것이 목적.
      // 로그인·오디오는 위 오버레이 부팅 창 이후에 실행되며, 각자 격리·타임아웃으로 실패해도 진입을 막지 않는다.
      _status.sink.add(InitializerStatus(progress: 0.8, message: "authenticate"));
      await _loginSafely();
      _status.sink.add(InitializerStatus(progress: 0.9, message: "mount audio"));
      await _initAudioSafely();

      // 진행 바를 100%로 채우고, 채워지는 애니메이션(약 500ms)이 끝날 시간을 준 뒤 화면을 전환한다.
      _status.sink.add(InitializerStatus(progress: 1.0, message: "startup"));
      await Future.delayed(const Duration(milliseconds: 600));

      // 창 크기/위치 적용은 홈 전환 **직전**에 한다. 로딩 스플래시(작은 창)를 계속 보여주다가
      // 홈과 함께 정식 크기로 바꿔, 리사이즈된 뒤에도 로딩 화면이 남아 보이는 문제를 없앤다.
      await _setWindowsSafely();

      // 오버레이 설정값(활성 기능·위치·투명도 등)은 오버레이 창이 켜져 안정화된 뒤인
      // 초기화 마지막 단계(홈 전환 직전)에 한 번 보낸다. 생성 직후 바로 보내면 서브 엔진이
      // 아직 위젯 트리를 마운트하기 전이라 설정이 유실될 수 있어, 위 지연 단계들 이후로 미룬다.
      await _sendOverlaySettingsSafely();

      _log.info('App initialized (Windows)');
      if (welcome) {
        _router.go("/welcome");
      } else {
        _router.go("/");
      }
    } catch (e, s) {
      // 임계 경로의 예기치 못한 실패(설정 로드 실패·타임아웃 등). 스플래시가 멈추지 않도록
      // 재시도 가능한 에러 상태를 노출한다.
      _log.severe('Critical initialization failed (Windows)', e, s);
      _status.sink.add(InitializerStatus(
        progress: 0,
        message: "initialization failed",
        error: true,
        retryable: true,
      ));
    } finally {
      _windowsCriticalPhaseRunning = false;
    }
  }

  /// 스플래시의 재시도 버튼에서 호출. 에러 상태를 지우고 임계 경로를 다시 실행한다.
  Future<void> retryForWindows() async {
    _log.info('Retrying initialization (Windows)');
    _status.sink.add(InitializerStatus(progress: 0, message: "preparing"));
    await _runWindowsCriticalPhase();
  }

  /// 오버레이 엔진 생성: 모니터 조회(loadSettings) → 두 번째 Flutter 엔진 생성(startOverlay).
  /// **다중 엔진 초기화 레이스**로 인한 Windows 간헐 크래시(`is_finalized`)를 줄이기 위해,
  /// 병렬 워밍업이 아니라 로딩 화면 단계(메인 아이솔레이트가 한가할 때)에서 직렬로 호출한다.
  /// 실패·지연은 격리하며(타임아웃 포함) 앱 진입을 막지 않는다. 오버레이 설정값 전송은 여기서
  /// 하지 않고, 창이 켜져 안정화된 뒤 초기화 마지막 단계(`_sendOverlaySettingsSafely`, 홈 전환
  /// 직전)에서 한 번 보낸다.
  Future<void> _prepareOverlaySafely() async {
    try {
      final overlaySettings =
          await _overlayRepository.loadSettings().timeout(_criticalStepTimeout);
      await _overlayRepository
          .startOverlay(overlaySettings.monitorDevice)
          .timeout(_criticalStepTimeout);
    } catch (e, s) {
      _log.warning('Overlay initialization failed; app continues', e, s);
    }
  }

  /// 오버레이 설정값(활성 기능·위치·투명도 등)을 오버레이 창으로 보낸다. 초기화 마지막 단계에서
  /// 오버레이가 안정화된 뒤 호출한다. 오버레이 미시작 시 Repository가 조용히 건너뛰며, 실패해도
  /// 홈 진입을 막지 않도록 격리·타임아웃한다.
  Future<void> _sendOverlaySettingsSafely() async {
    try {
      await _overlayRepository
          .sendInitialSettings()
          .timeout(_criticalStepTimeout);
    } catch (e, s) {
      _log.warning('Sending overlay settings failed; app continues', e, s);
    }
  }

  /// 저장된 토큰으로 자동 로그인한다. 직렬 실행이므로 네트워크가 느려도 로딩 화면이 멈추지
  /// 않도록 타임아웃을 두고, 실패는 격리한다. 결과는 userStream으로 반영돼 화면이 반응형 갱신된다.
  Future<void> _loginSafely() async {
    try {
      await _authRepository.login().timeout(_criticalStepTimeout);
    } catch (e, s) {
      _log.warning('Auto login failed; app continues', e, s);
    }
  }

  /// 알림음 플레이어를 마운트한다. 실패해도 앱 사용에는 지장이 없다.
  Future<void> _initAudioSafely() async {
    try {
      await _audioPlayerRepository.init();
    } catch (e, s) {
      _log.warning('Audio player initialization failed; app continues', e, s);
    }
  }

  /// 트레이 아이콘/메뉴 설정. 실패해도 창 표시로 진행한다.
  Future<void> _startTraySafely() async {
    try {
      await startTray();
    } catch (e, s) {
      _log.warning('Tray initialization failed', e, s);
    }
  }

  /// 창 크기·위치·표시 적용. 실패해도 앱 진입을 막지 않는다.
  Future<void> _setWindowsSafely() async {
    try {
      await setWindows();
    } catch (e, s) {
      _log.warning('Window setup failed', e, s);
    }
  }

  Future<void> initializeForWeb() async {
    final welcome = await _appSettingsRepository.getAppSettings();
    if (!welcome) {
      await _authRepository.login();
    }
    //웹소켓
    await _audioPlayerRepository.init();
    _log.info('App initialized (Web)');
  }

  Future<void> initializeForAndroid() async {
    final welcome = await _appSettingsRepository.getAppSettings();
    if (!welcome) {
      await _authRepository.login();
    }
    await _audioPlayerRepository.init();
    _log.info('App initialized (Android)');
    AppLinks().uriLinkStream.listen((uri) {
      if(uri.hasQuery){
        _router.goWithGa("${uri.path}?${uri.query}");
      } else {
        _router.goWithGa(uri.path);
      }
    });
  }

  Future<void> update() async {
    _status.sink.add(InitializerStatus(
      progress: 0,
      message: "check available downloads",
    ));
    await _status.sink.addStream(_versionRepository.downloadLatest().map(
      (progress) {
        return InitializerStatus(
          progress: progress,
          message: "download latest",
        );
      },
    ));
    _status.sink.add(InitializerStatus(
      progress: 1,
      message: "waiting for update",
    ));
    _log.info('New version downloaded, launching installer and exiting');
    // 오버레이 자식(별도 엔진)을 먼저 정리한다. 자식이 남아 있으면 프로세스가 종료되지
    // 않아 인스톨러가 실행 파일을 교체하지 못한다(파일 잠금).
    await _overlayRepository.teardown();
    await Process.start(
      '${Directory.current.path}/SetupKaranda.exe',
      ["-t", "-l", "1000", "/silent"],
    );
    // 메인 창만 destroy하면 오버레이 엔진이 같은 프로세스를 살려둘 수 있으므로,
    // 프로세스 전체를 확실히 종료해 인스톨러가 파일 교체를 완료하게 한다.
    exit(0);
  }

  Future<void> setWindows() async {
    await windowManager.hide();
    await windowManager.setTitleBarStyle(TitleBarStyle.normal);
    if (kDebugMode) {
      await windowManager.setSize(const Size(1280, 720));
    } else {
      await windowManager.setSize(_appSettingsRepository.settings.windowSize);
    }
    await windowManager.setMinimumSize(const Size(600, 550));
    if (_appSettingsRepository.settings.windowOffset == null || kDebugMode) {
      await windowManager.center();
    } else {
      windowManager.setPosition(_appSettingsRepository.settings.windowOffset!);
    }
    if (!_appSettingsRepository.settings.startMinimized) {
      await windowManager.show();
    } else if (!_appSettingsRepository.settings.useTrayMode) {
      await windowManager.minimize();
    }
  }

  Future<void> startTray() async {
    await trayManager.setIcon("assets/brand/app_icon.ico");
    Menu menu = Menu(
      items: [
        MenuItem(
          key: 'show',
          label: "windowsTray.show".tr(),
        ),
        MenuItem(
          key: 'hide',
          label: "windowsTray.hide".tr(),
        ),
        MenuItem.separator(),
        MenuItem(
          key: 'cancel',
          label: "windowsTray.cancel".tr(),
        ),
        MenuItem.separator(),
        MenuItem(
          key: 'quit',
          label: "windowsTray.quit".tr(),
        ),
      ],
    );
    await trayManager.setContextMenu(menu);
  }
}
