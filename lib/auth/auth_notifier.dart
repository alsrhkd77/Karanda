import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:karanda/common/api.dart';
import 'package:karanda/common/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:karanda/common/http_response_extension.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthNotifier with ChangeNotifier {
  final GlobalKey<ScaffoldMessengerState> _rootScaffoldMessengerKey;

  bool _authenticated = false;
  late String _username;
  late String _avatar;

  bool get authenticated => _authenticated;

  String get username => _username;

  String get avatar => _avatar;

  AuthNotifier(this._rootScaffoldMessengerKey) {
    authorization();
  }

  void authenticate() {
    String _url;
    if (kIsWeb) {
      _url = Api.authenticateWeb;
      _launchUrl(_url, newTab: false);
    } else {
      //windows app
      _url = Api.authenticateWindows;
      listenRedirect();
      _launchUrl(_url);
    }
  }

  Future<void> authorization() async {
    const storage = FlutterSecureStorage();
    if (!_authenticated && await storage.containsKey(key: 'karanda-token')) {
      await _authorization();
    }
  }

  Future<bool> _authorization() async {
    final response = await http.get(Api.authorization);
    if (response.statusCode == 200) {
      Map data = jsonDecode(response.bodyUTF);
      _authenticated = true;
      _avatar = data['avatar'];
      _username = data['username'];
      notifyListeners();
      return true;
    } else if(response.statusCode == 401){
      return await tokenRefresh();
    }
    return false;
  }

  Future<bool> tokenRefresh() async {
    const storage = FlutterSecureStorage();
    String? socialToken =  await storage.read(key: 'social-token');
    String? refreshToken = await storage.read(key: 'refresh-token');
    if(socialToken != null && refreshToken != null){
      Map<String, String> data = {
        'social-token': socialToken,
        'refresh-token': refreshToken
      };
      final response = await http.post(Api.tokenRefresh, headers: data);
      if (response.statusCode == 200) {
        Map data = jsonDecode(response.bodyUTF);
        _authenticated = true;
        _avatar = data['avatar'];
        _username = data['username'];
        saveToken(token: data['token'], socialToken: data['social-token'], refreshToken: data['refresh-token']);
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  //run only windows app
  Future<void> listenRedirect() async {
    HttpServer redirectServer = await HttpServer.bind("localhost", 8082);
    HttpRequest request = await redirectServer.first;
    Map<String, String> data = request.uri.queryParameters;
    bool result = false;
    if (data.containsKey('token') && data.containsKey('social-token') && data.containsKey('refresh-token')) {
      result = true;
      request.response.redirect(Uri.parse('https://discord.com'));
    } else {
      //TODO: 실패시 보낼 페이지 필요
      request.response.redirect(Uri.parse('https://discord.com'));
    }
    await request.response.close();
    await redirectServer.close();

    //TODO: 실패 시 처리 필요
    if (result) {
      await saveToken(token: data['token']!, socialToken: data['social-token']!, refreshToken: data['refresh-token']!);
      if (await _authorization()) {
        Get.offAllNamed('/');
      }
    }
  }

  Future<void> logout() async {
    await _logout();
    _rootScaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: const Text('로그아웃 되었습니다'),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(24.0),
        backgroundColor: Theme.of(_rootScaffoldMessengerKey.currentContext!)
            .snackBarTheme
            .backgroundColor,
      ),
    );
  }

  Future<void> _logout() async {
    await deleteToken();
    _authenticated = false;
    _username = '';
    _avatar = '';
    notifyListeners();
  }

  Future<bool> unregister() async {
    final response = await http.delete(Api.unregister);
    if (response.statusCode == 200) {
      await _logout();
      _rootScaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: const Text('회원탈퇴가 완료되었습니다'),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(24.0),
          backgroundColor: Theme.of(_rootScaffoldMessengerKey.currentContext!)
              .snackBarTheme
              .backgroundColor,
        ),
      );
      return true;
    }
    return false;
  }

  Future<void> deleteToken() async {
    const storage = FlutterSecureStorage();
    await storage.delete(key: 'karanda-token');
    await storage.delete(key: 'social-token');
    await storage.delete(key: 'refresh-token');
  }

  Future<void> saveToken({required String token, required String socialToken, required String refreshToken}) async {
    final storage = FlutterSecureStorage();
    await storage.write(key: 'karanda-token', value: token);
    await storage.write(key: 'social-token', value: socialToken);
    await storage.write(key: 'refresh-token', value: refreshToken);
  }

  Future<void> _launchUrl(String url, {bool newTab = true}) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, webOnlyWindowName: newTab ? '_blank' : '_self')) {
      throw Exception('Could not launch $uri');
    }
  }
}