import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

Future<http.Response> head(String url, {Map<String, String>? headers}) async {
  headers = await _getToken(headers);
  return http.head(Uri.parse(url), headers: headers);
}

Future<http.Response> get(String url, {Map<String, String>? headers}) async {
  headers = await _getToken(headers);
  return http.get(Uri.parse(url), headers: headers);
}

Future<http.Response> post(String url,
    {Map<String, String>? headers, Object? body, Encoding? encoding, bool? json}) async {
  headers = await _getToken(headers);
  headers = _setJson(headers, json);
  return http.post(Uri.parse(url),
      headers: headers,
      body: body,
      encoding: encoding ?? Encoding.getByName('utf-8'));
}

Future<http.Response> put(String url,
    {Map<String, String>? headers, Object? body, Encoding? encoding, bool? json}) async {
  headers = await _getToken(headers);
  headers = _setJson(headers, json);
  return http.put(Uri.parse(url),
      headers: headers,
      body: body,
      encoding: encoding ?? Encoding.getByName('utf-8'));
}

Future<http.Response> patch(String url,
    {Map<String, String>? headers, Object? body, Encoding? encoding, bool? json}) async {
  headers = await _getToken(headers);
  headers = _setJson(headers, json);
  return http.patch(Uri.parse(url),
      headers: headers,
      body: body,
      encoding: encoding ?? Encoding.getByName('utf-8'));
}

Future<http.Response> delete(String url,
    {Map<String, String>? headers, Object? body, Encoding? encoding, bool? json}) async {
  headers = await _getToken(headers);
  headers = _setJson(headers, json);
  return http.delete(Uri.parse(url),
      headers: headers,
      body: body,
      encoding: encoding ?? Encoding.getByName('utf-8'));
}

Future<String> read(String url, {Map<String, String>? headers}) async {
  headers = await _getToken(headers);
  return http.read(Uri.parse(url), headers: headers);
}

Future<Uint8List> readBytes(String url, {Map<String, String>? headers}) async {
  headers = await _getToken(headers);
  return http.readBytes(Uri.parse(url), headers: headers);
}

Future<Map<String, String>?> _getToken(Map<String, String>? headers) async {
  const storage = FlutterSecureStorage();
  String? _token = await storage.read(key: 'karanda-token');
  if (_token != null) {
    headers = headers ?? {};
    headers.addAll({'authorization': _token});
  }
  return headers;
}

Map<String, String>? _setJson(Map<String, String>? headers, bool? json) {
  if (json != null && json) {
    headers = headers ?? {};
    headers.addAll({'Content-Type': 'application/json'});
  }
  return headers;
}