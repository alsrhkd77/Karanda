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
        if (token != null) {
          request.headers['Authorization'] = "Bearer $token";
          return _inner.send(request);
        }
      } catch (e, s) {
        _log.warning('Token refresh failed', e, s);
      }
    }
    return response;
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
        await storage.write(key: 'karanda-token', value: data['token']);
        await storage.write(key: 'refresh-token', value: data['refreshToken']);
        _log.info('Auth token refreshed');
        return token;
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
