import 'package:flutter/foundation.dart' show kDebugMode;

abstract final class KarandaApi {
  static const String scheme = kDebugMode ? 'http' : 'https';
  static const String host = kDebugMode ? 'localhost' : 'api.karanda.kr';
  ///don't use [port] in release mode
  static const int port = 8000;

  static final liveChannel = "${scheme.replaceAll("http", "ws")}://$host${kDebugMode ? ":$port":""}/live-channel";
  static const storage = "https://storage.googleapis.com/karanda";

  static const String latestVersion = "https://www.karanda.kr/version.json";
  static const List<String> latestVersionMirrors = [
    "https://github.com/Hammuu1112/Karanda/releases/latest/download/SetupKaranda.exe",
    "https://storage.googleapis.com/karanda/SetupKaranda.exe"
  ];

  static const String itemImage = "$storage/bdo/item/image";

  static const String authorization = "/auth/discord/authorization";
  static const String tokenRefresh = "/auth/discord/refresh";
  static const String unregister = "/auth/discord/unregister";
  static const String families = "/bdo-family/families";
  static const String tradeMarketWaitList = "/trade-market/wait-list";
}
