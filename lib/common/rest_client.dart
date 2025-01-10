import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http/retry.dart';
import 'package:karanda/common/api.dart';
import 'package:karanda/common/token_factory.dart';

class RestClient {
  static String get _scheme => kDebugMode ? 'http' : 'https';

  static String get _host => kDebugMode ? 'localhost' : 'www.karanda.kr';

  static int get _port => kDebugMode ? 8000 : 8080;

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
      scheme: Api.scheme,
      host: _host,
      port: _port,
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
    request.headers['Qualification'] = TokenFactory.serviceToken();
    if (json) {
      request.headers['Content-Type'] = 'application/json';
    }
    return _inner.send(request);
  }

  @override
  void close() {
    _inner.close();
    super.close();
  }
}