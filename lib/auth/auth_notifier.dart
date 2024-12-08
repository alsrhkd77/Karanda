import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:karanda/common/api.dart';
import 'package:karanda/common/global_properties.dart';
import 'package:karanda/common/go_router_extension.dart';
import 'package:karanda/common/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:karanda/common/http_response_extension.dart';
import 'package:karanda/verification_center/models/bdo_family.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:go_router/go_router.dart';

class AuthNotifier with ChangeNotifier {
  final GlobalKey<ScaffoldMessengerState> _rootScaffoldMessengerKey;
  final GoRouter goRouter;

  bool _authenticated = false;
  bool _waitResponse = false;
  late String _username;
  late String _avatar;
  late String _discordId;
  BdoFamily? _mainFamily;

  bool get authenticated => _authenticated;

  bool get waitResponse => _waitResponse;

  String get username => _username;

  String get avatar => _avatar;

  String get discordId => _discordId;

  BdoFamily? get mainFamily => _mainFamily;

  AuthNotifier(this._rootScaffoldMessengerKey, this.goRouter) {
    if (kIsWeb) {
      authorization();
    }
  }

  void authenticate() {
    String url;
    if (kIsWeb) {
      url = Api.authenticateWeb;
      _launchUrl(url, newTab: false);
    } else {
      //windows app
      url = Api.authenticateWindows;
      listenRedirect();
      _launchUrl(url);
    }
  }

  Future<void> authorization() async {
    if (!_waitResponse) {
      _waitResponse = true;
      notifyListeners();
      const storage = FlutterSecureStorage();
      if (await storage.containsKey(key: 'karanda-token')) {
        await _authorization();
      }
      _waitResponse = false;
      notifyListeners();
    }
  }

  Future<bool> _authorization() async {
    try {
      final response = await http
          .get(Api.authorization)
          .timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        Map data = jsonDecode(response.bodyUTF);
        _authenticated = true;
        _username = data['username'];
        _discordId = data['discordId'];
        _avatar = data['avatar'] == null
            ? "${Api.discordEmbedAvatar}/${Random().nextInt(6)}.png"
            : "${Api.discordAvatar}/${data['avatar']}";
        if (data.containsKey('mainFamily') && data['mainFamily'] != null) {
          _mainFamily = BdoFamily.fromData(data['mainFamily']);
        }
        notifyListeners();
        return true;
      } else if (response.statusCode == 401) {
        return await tokenRefresh();
      }
    } catch (e) {
      await _logout();
      if (kIsWeb) {
        _showSnackBar(content: '사용자 인증에 실패했습니다');
      }
    }
    return false;
  }

  Future<bool> tokenRefresh() async {
    const storage = FlutterSecureStorage();
    String? refreshToken = await storage.read(key: 'refresh-token');
    if (refreshToken != null) {
      Map<String, String> data = {'refresh-token': 'Bearer $refreshToken'};
      final response = await http.get(Api.tokenRefresh, headers: data);
      if (response.statusCode == 200) {
        Map data = jsonDecode(response.bodyUTF);
        _authenticated = true;
        _username = data['username'];
        _discordId = data['discordId'];
        _avatar = data['avatar'] == null
            ? "${Api.discordEmbedAvatar}/${Random().nextInt(6)}.png"
            : "${Api.discordAvatar}/${data['avatar']}";
        if (data.containsKey('mainFamily') && data['mainFamily'] != null) {
          _mainFamily = BdoFamily.fromData(data['mainFamily']);
        }
        saveToken(
            token: data['token'],
            refreshToken: data['refresh-token'] ?? data['refreshToken']);
        notifyListeners();
        return true;
      }
      await _logout();
      _showSnackBar(content: '유효하지 않은 인증입니다.');
    }
    return false;
  }

  //run only windows app
  Future<void> listenRedirect() async {
    bool result = false;
    HttpServer redirectServer =
        await HttpServer.bind("localhost", 8082, shared: true);
    HttpRequest request = await redirectServer.first;
    Map<String, String> data = request.uri.queryParameters;
    try {
      if (data.containsKey('token') && data.containsKey('refresh-token')) {
        result = true;
        request.response.redirect(Uri.parse('https://discord.com'));
      } else {
        request.response
            .redirect(Uri.parse('https://www.karanda.kr/#/auth/error'));
      }
    } finally {
      await request.response.close();
      await redirectServer.close();
    }

    if (result) {
      await saveToken(
          token: data['token']!, refreshToken: data['refresh-token']!);
      if (await _authorization()) {
        goRouter.goWithGa('/');
      }
    } else {
      await deleteToken();
      goRouter.goWithGa('/auth/error');
    }
  }

  Future<void> logout() async {
    await _logout();
    _showSnackBar(content: '로그아웃 되었습니다');
  }

  Future<void> _logout() async {
    await deleteToken();
    _authenticated = false;
    _username = '';
    _avatar = '';
    _discordId = '';
    notifyListeners();
  }

  Future<bool> unregister() async {
    final response = await http.delete(Api.unregister);
    if (response.statusCode == 200) {
      await _logout();
      _showSnackBar(content: '회원탈퇴가 완료되었습니다');
      return true;
    }
    return false;
  }

  Future<void> deleteToken() async {
    const storage = FlutterSecureStorage();
    await storage.delete(key: 'karanda-token');
    await storage.delete(key: 'refresh-token');
  }

  Future<void> saveToken(
      {required String token, required String refreshToken}) async {
    const storage = FlutterSecureStorage();
    await storage.write(key: 'karanda-token', value: token);
    await storage.write(key: 'refresh-token', value: refreshToken);
  }

  Future<void> _launchUrl(String url, {bool newTab = true}) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, webOnlyWindowName: newTab ? '_blank' : '_self')) {
      throw Exception('Could not launch $uri');
    }
  }

  void _showSnackBar({required String content}) {
    _rootScaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(content),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: GlobalProperties.snackBarMargin,
        backgroundColor: Theme.of(_rootScaffoldMessengerKey.currentContext!)
            .snackBarTheme
            .backgroundColor,
      ),
    );
  }
}
