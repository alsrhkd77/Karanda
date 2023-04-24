import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:karanda/common/api.dart';
import 'package:karanda/common/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:karanda/common/http_response_extension.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthNotifier with ChangeNotifier {
  bool _authenticated = false;
  late String _username;
  late String _avatar;

  bool get authenticated => _authenticated;

  String get username => _username;

  String get avatar => _avatar;

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
    String? accessToken = sharedPreferences.getString('access-token');
    final response =
        await http.get('${Api.authorization}?access_token=$accessToken');
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
    if (data.containsKey('token') &&
        data.containsKey('access_token') &&
        data.containsKey('refresh_token')) {
      result = true;
      request.response.redirect(Uri.parse('https://discord.com'));
    } else {
      request.response.redirect(Uri.parse('https://discord.com'));
    }
    await request.response.close();
    await redirectServer.close();

    if (result) {
      await saveToken(
          data['token']!, data['access_token']!, data['refresh_token']!);
      if (await _authorization()) {
        Get.toNamed('/');
      }
    }
  }

  Future<void> saveToken(
      String token, String accessToken, String refreshToken) async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    sharedPreferences.setString('karanda-token', token);
    sharedPreferences.setString('access-token', accessToken);
    sharedPreferences.setString('refresh-token', refreshToken);
  }

  Future<void> _launchUrl(String url, {bool newTab = true}) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, webOnlyWindowName: newTab ? '_blank' : '_self')) {
      throw Exception('Could not launch $uri');
    }
  }
}
