import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:karanda/common/api.dart';
import 'package:karanda/common/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:karanda/common/http_response_extension.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    if (!_authenticated && sharedPreferences.containsKey('karanda-token')) {
      await _authorization();
    }
  }

  Future<bool> _authorization() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    final response = await http.get(Api.authorization);
    if (response.statusCode == 200) {
      Map data = jsonDecode(response.bodyUTF);
      _authenticated = true;
      _avatar = data['avatar'];
      _username = data['username'];
      notifyListeners();
      return true;
    }
    return false;
  }

  //run only windows app
  Future<void> listenRedirect() async {
    HttpServer redirectServer = await HttpServer.bind("localhost", 8082);
    HttpRequest request = await redirectServer.first;
    Map<String, String> data = request.uri.queryParameters;
    bool result = false;
    if (data.containsKey('token')) {
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
      await saveToken(data['token']!);
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
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
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
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    sharedPreferences.remove('karanda-token');
  }

  Future<void> saveToken(String token) async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    sharedPreferences.setString('karanda-token', token);
  }

  Future<void> _launchUrl(String url, {bool newTab = true}) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, webOnlyWindowName: newTab ? '_blank' : '_self')) {
      throw Exception('Could not launch $uri');
    }
  }
}
