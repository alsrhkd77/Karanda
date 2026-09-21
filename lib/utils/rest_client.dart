import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http/retry.dart';
import 'package:karanda/utils/api_endpoints/karanda_api.dart';
import 'package:karanda/utils/http_status.dart';
import 'package:logging/logging.dart';

import 'package:karanda/utils/token_utils.dart';

/// 네트워크 운영 로그. Authorization 헤더·토큰 값은 절대 기록하지 않는다.
final _log = Logger('network');

abstract final class RestClient {
  //static String get _scheme => kDebugMode ? 'http' : 'https';
  //static String get _host => kDebugMode ? 'localhost' : 'www.karanda.kr';
  //static int get _port => kDebugMode ? 8000 : 8080;

  static Future<http.Response> head(
    String path, {
    Map<String, String>? headers,
    bool retry = false,
  }) async {
    return _withClient(
      function: (client) => client.head(_uri(path: path), headers: headers),
      retry: retry,
    );
  }

  static Future<http.Response> get(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? parameters,
    bool retry = false,
  }) async {
    return _withClient(
      function: (client) {
        return client.get(
          _uri(path: path, parameters: parameters),
          headers: headers,
        );
      },
      retry: retry,
    );
  }

  static Future<http.Response> post(
    String path, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
    bool json = false,
    bool retry = false,
  }) async {
    return _withClient(
      function: (client) {
        return client.post(
          _uri(path: path),
          headers: headers,
          body: body,
          encoding: encoding ?? Encoding.getByName('utf-8'),
        );
      },
      json: json,
      retry: retry,
    );
  }

  static Future<http.Response> put(
    String path, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
    bool json = false,
    bool retry = false,
  }) async {
    return _withClient(
      function: (client) {
        return client.put(
          _uri(path: path),
          headers: headers,
          body: body,
          encoding: encoding ?? Encoding.getByName('utf-8'),
        );
      },
      json: json,
      retry: retry,
    );
  }

  static Future<http.Response> patch(
    String path, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
    bool json = false,
    bool retry = false,
  }) async {
    return _withClient(
      function: (client) {
        return client.patch(
          _uri(path: path),
          headers: headers,
          body: body,
          encoding: encoding ?? Encoding.getByName('utf-8'),
        );
      },
      json: json,
      retry: retry,
    );
  }

  static Future<http.Response> delete(
    String path, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
    bool json = false,
    bool retry = false,
  }) async {
    return _withClient(
      function: (client) {
        return client.delete(
          _uri(path: path),
          headers: headers,
          body: body,
          encoding: encoding ?? Encoding.getByName('utf-8'),
        );
      },
      json: json,
      retry: retry,
    );
  }

  static Future<String> read(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? parameters,
    bool retry = false,
  }) async {
    return _withClient(
      function: (client) {
        return client.read(
          _uri(path: path, parameters: parameters),
          headers: headers,
        );
      },
      retry: retry,
    );
  }

  static Future<Uint8List> readBytes(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? parameters,
    bool retry = false,
  }) async {
    return _withClient(
      function: (client) {
        return client.readBytes(
          _uri(path: path, parameters: parameters),
          headers: headers,
        );
      },
      retry: retry,
    );
  }

  static Future<T> _withClient<T>({
    required Future<T> Function(http.Client) function,
    bool retry = false,
    bool json = false,
  }) async {
    var client = retry ? RetryClient(_Client(json)) : _Client(json);
    try {
      return await function(client);
    } finally {
      client.close();
    }
  }

  static Uri _uri({required String path, Map<String, dynamic>? parameters}) {
    return Uri(
      scheme: KarandaApi.scheme,
      host: KarandaApi.host,
      port: kDebugMode ? KarandaApi.port : null,
      path: path,
      queryParameters: parameters,
    );
  }
}

class _Client extends http.BaseClient {
  final http.Client _inner = http.Client();
  final bool json;

  _Client(this.json);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    const storage = FlutterSecureStorage();
    String? token = await storage.read(key: 'karanda-token');
    if (token != null) {
      request.headers['Authorization'] = "Bearer $token";
    }
    request.headers['Qualification'] = TokenUtils.serviceToken();
    if (json) {
      request.headers['Content-Type'] = 'application/json';
    }
    _log.info('Request: ${request.method} ${request.url.path}');
    http.StreamedResponse response = await _inner.send(request);
    if (response.statusCode == HttpStatus.unauthorized) {
      _log.fine('Unauthorized (401): ${request.method} ${request.url.path}, attempting token refresh');
      try {
        token = await tokenRefresh();
        final retry = token == null ? null : _copyRequest(request, token);
        if (retry != null) {
          // 이미 전송된 request는 finalize 상태라 그대로 재전송하면 StateError가 난다.
          // 반드시 복제본으로 보내고, await로 받아 실패 시 아래 catch에서 처리되게 한다.
          return await _inner.send(retry);
        }
      } catch (e, s) {
        _log.warning('Token refresh failed', e, s);
      }
    }
    return response;
  }

  /// 401 재시도용 request 복제.
  ///
  /// 이미 전송된 request는 finalize된 상태라 재사용할 수 없다. 본문을 다시 만들 수 있는
  /// [http.Request]만 복제하며, 그 외 타입(스트리밍·멀티파트)은 null을 반환해 재시도하지 않는다.
  http.Request? _copyRequest(http.BaseRequest origin, String token) {
    if (origin is! http.Request) return null;
    final copy = http.Request(origin.method, origin.url)
      ..followRedirects = origin.followRedirects
      ..maxRedirects = origin.maxRedirects
      ..persistentConnection = origin.persistentConnection;
    copy.headers.addAll(origin.headers);
    copy.headers['Authorization'] = "Bearer $token";
    copy.bodyBytes = origin.bodyBytes;
    return copy;
  }

  Future<String?> tokenRefresh() async {
    const storage = FlutterSecureStorage();
    final String? token = await storage.read(key: 'karanda-token');
    final String? refreshToken = await storage.read(key: 'refresh-token');

    if (token != null && refreshToken != null) {
      final uri = Uri(
        scheme: KarandaApi.scheme,
        host: KarandaApi.host,
        port: kDebugMode ? KarandaApi.port : null,
        path: KarandaApi.tokenRefresh,
      );

      final response = await _inner.get(
        uri,
        headers: {
          'Authorization': "Bearer $token",
          'Qualification': TokenUtils.serviceToken(),
          'refresh-token': 'Bearer $refreshToken'
        },
      );

      if (response.statusCode == HttpStatus.ok) {
        final data = jsonDecode(response.body);
        final newToken = data['token'] as String;
        await storage.write(key: 'karanda-token', value: newToken);
        await storage.write(key: 'refresh-token', value: data['refreshToken']);
        _log.info('Auth token refreshed');
        return newToken;
      }
      _log.warning('Token refresh rejected (status: ${response.statusCode})');
    }

    return null;
  }

  @override
  void close() {
    _inner.close();
    super.close();
  }
}
