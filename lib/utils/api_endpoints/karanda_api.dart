import 'package:flutter/foundation.dart';

class KarandaApi {
  static String scheme = kDebugMode ? 'http' : 'https';
  static String host = kDebugMode ? 'localhost' : 'www.karanda.kr';
  static int port = kDebugMode ? 8000 : 8080;

  static String tokenRefresh = "/auth/discord/refresh";
}