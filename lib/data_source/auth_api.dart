import 'dart:async';
import 'dart:convert';
import 'dart:io' show HttpRequest, HttpServer;

import 'package:http/http.dart' as http;
import 'package:karanda/utils/extension/http_response_extension.dart';
import 'package:karanda/model/user.dart';
import 'package:karanda/utils/api_endpoints/discord_api.dart';
import 'package:karanda/utils/api_endpoints/karanda_api.dart';
import 'package:karanda/utils/external_links.dart';
import 'package:karanda/utils/http_status.dart';
import 'package:karanda/utils/rest_client.dart';
import 'package:karanda/utils/result.dart';

import 'package:karanda/utils/launch_url.dart';
import 'package:logging/logging.dart';

/// 인증 API 운영 로그. 토큰 값은 절대 기록하지 않는다.
final _log = Logger('auth');

/// 사용자 조회(`/auth/discord/authorization`) 실패 원인.
///
/// 호출자가 "저장된 토큰을 버려야 하는 실패"와 "서버·네트워크 문제라 토큰을 유지해야 하는 실패"를
/// 구분할 수 있게 상태 코드를 함께 전달한다. [statusCode]가 null이면 응답 자체를 받지 못한 것이다.
class AuthorizationFailure implements Exception {
  /// 서버 응답 상태 코드. 응답을 받지 못했으면 null.
  final int? statusCode;

  const AuthorizationFailure(this.statusCode);

  /// 서버가 토큰을 거부한 경우. 이때만 저장된 토큰이 재사용 불가하다.
  bool get tokenRejected => statusCode == HttpStatus.unauthorized;

  @override
  String toString() => 'AuthorizationFailure(status: $statusCode)';
}

class AuthApi {
  Future<Result<User>> authorization() async {
    final http.Response response;
    try {
      response = await RestClient.get(KarandaApi.authorization)
          .timeout(const Duration(seconds: 30));
    } catch (e, s) {
      // 네트워크 오류·타임아웃. 토큰 문제가 아니므로 statusCode는 null로 둔다.
      _log.warning('Authorization request failed', e, s);
      return Result.error(const AuthorizationFailure(null));
    }
    if (response.statusCode != HttpStatus.ok) {
      _log.warning('Authorization rejected (status: ${response.statusCode})');
      return Result.error(AuthorizationFailure(response.statusCode));
    }
    try {
      return Result.ok(User.fromJson(jsonDecode(response.bodyUTF)));
    } catch (e, s) {
      // 응답은 정상(200)이지만 모델로 변환하지 못한 경우. 토큰은 유효하므로 유지한다.
      _log.warning('Failed to parse user data', e, s);
      return Result.error(AuthorizationFailure(response.statusCode));
    }
  }

  void authenticationWeb() {
    launchURL(DiscordApi.authenticateWeb, newTab: false);
  }

  void authenticationWindows() {
    launchURL(DiscordApi.authenticateWindows);
  }

  void authenticationAndroid() {
    launchURL(DiscordApi.authenticateAndroid);
  }

  Future<bool> unregister() async {
    final response = await RestClient.delete(KarandaApi.unregister);
    return response.statusCode == HttpStatus.ok;
  }

  ///Only for windows.
  Future<void> listenRedirect({
    required Future<void> Function(String, String) onSuccess,
    required Future<void> Function() onFailed,
  }) async {
    HttpServer redirectServer = await HttpServer.bind("localhost", 8082, shared: true,);
    HttpRequest request = await redirectServer.first;
    try {
      Map<String, String> data = request.uri.queryParameters;
      if (data.containsKey('token') && data.containsKey('refresh-token')) {
        await onSuccess(data['token']!, data['refresh-token']!);
        _log.info('Discord auth tokens received');
        request.response.redirect(Uri.parse(ExternalLinks.discord));
      } else {
        _log.warning('Discord auth failed: redirect missing tokens');
        await onFailed();
        request.response
            .redirect(Uri.parse(ExternalLinks.karandaAuthErrorPage));
      }
    } finally {
      await request.response.close();
      await redirectServer.close();
    }
  }
}
