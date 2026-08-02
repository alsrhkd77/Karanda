import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:karanda/model/version.dart';
import 'package:karanda/utils/api_endpoints/karanda_api.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:rxdart/rxdart.dart';

class VersionDataSource {
  Future<Version> getCurrentVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return Version.fromString(packageInfo.version);
  }

  /// 빌드 번호는 [Version] 모델에 없어 별도로 제공한다. `PackageInfo.fromPlatform`은
  /// 내부적으로 캐시되므로 버전 조회와 따로 불러도 부담이 없다.
  Future<String> getBuildNumber() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.buildNumber;
  }

  Future<Version> getLatestVersion() async {
    final response = await http.get(Uri.parse(KarandaApi.latestVersion));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Version.fromString(data['version']);
    }
    return Version(major: 0, minor: 0, patch: 0, text: "");
  }

  Future<String?> getAvailableApi() async {
    for (String path in KarandaApi.latestVersionMirrors) {
      final response = await http.head(Uri.parse(path));
      if (response.statusCode == 200) {
        return path;
      }
    }
    return null;
  }

  /// 최신 설치 파일을 내려받으며 진행률(0.0~1.0)을 방출한다.
  ///
  /// 실패는 **스트림 에러로 전파**한다. 이전 구현은 실패해도 스트림을 닫지 않아 소비자가 영구 대기했다.
  /// 부분 파일 정리는 dio가 담당한다(`download`의 `deleteOnError` 기본값이 true).
  Stream<double> downloadLatestVersion(String api) async* {
    final path = '${Directory.current.path}/SetupKaranda.exe';
    final status = BehaviorSubject<double>();
    // receiveTimeout은 청크 사이 간격 기준이라, 대용량 다운로드를 통째로 끊지 않으면서 정지 상태만 잡는다.
    final dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
    ));
    dio.download(
      api,
      path,
      onReceiveProgress: (received, total) {
        // Content-Length가 없으면 total이 -1로 들어와 진행률이 음수가 된다.
        if (total > 0) {
          status.sink.add(received / total);
        }
      },
    ).then(
      (_) => status.close(),
      onError: (Object e, StackTrace s) {
        status.addError(e, s);
        status.close();
      },
    );
    yield* status.stream;
  }
}
