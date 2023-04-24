import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<http.Response> head(String url, {Map<String, String>? headers}) async {
  headers = await _getToken(headers);
  return http.head(Uri.parse(url), headers: headers);
}

Future<http.Response> get(String url, {Map<String, String>? headers}) async {
  headers = await _getToken(headers);
  return http.get(Uri.parse(url), headers: headers);
}

Future<http.Response> post(String url,
    {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
  headers = await _getToken(headers);
  return http.post(Uri.parse(url),
      headers: headers, body: body, encoding: encoding);
}

Future<http.Response> put(String url,
    {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
  headers = await _getToken(headers);
  return http.put(Uri.parse(url),
      headers: headers, body: body, encoding: encoding);
}

Future<http.Response> patch(String url,
    {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
  headers = await _getToken(headers);
  return http.patch(Uri.parse(url),
      headers: headers, body: body, encoding: encoding);
}

Future<http.Response> delete(String url,
    {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
  headers = await _getToken(headers);
  return http.delete(Uri.parse(url),
      headers: headers, body: body, encoding: encoding);
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
  final SharedPreferences _sharedPreferences =
      await SharedPreferences.getInstance();
  String? _token = _sharedPreferences.getString('karanda-token');
  if (_token != null) {
    headers = headers ?? {};
    headers.addAll({'authentication': _token});
  }
  return headers;
}
