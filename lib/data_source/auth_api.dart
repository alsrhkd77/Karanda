import 'dart:async';
import 'dart:convert';
import 'dart:io' show HttpRequest, HttpServer;

import 'package:karanda/common/http_response_extension.dart';
import 'package:karanda/model/user.dart';
import 'package:karanda/utils/api_endpoints/discord_api.dart';
import 'package:karanda/utils/api_endpoints/karanda_api.dart';
import 'package:karanda/utils/external_links.dart';
import 'package:karanda/utils/http_status.dart';
import 'package:karanda/utils/rest_client.dart';
import 'package:karanda/utils/result.dart';

import 'package:karanda/utils/launch_url.dart';

class AuthApi {
  Future<Result<User>> authorization() async {
    try {
      final response = await RestClient.get(KarandaApi.authorization)
          .timeout(const Duration(seconds: 30));
      if (response.statusCode == HttpStatus.ok) {
        return Result.ok(User.fromJson(jsonDecode(response.bodyUTF)));
      }
    } catch (e) {
      return Result.error(Exception("Failed to authorization.\n$e"));
    }
    return Result.error(Exception("Failed to authorization"));
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
        request.response.redirect(Uri.parse(ExternalLinks.discord));
      } else {
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
