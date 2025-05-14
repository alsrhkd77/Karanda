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

  static const String _auth = "/auth";
  static const String authorization = "$_auth/discord/authorization";
  static const String tokenRefresh = "$_auth/discord/refresh";
  static const String unregister = "$_auth/discord/unregister";
  static const String families = "/bdo-family/families";
  static const String _tradeMarket = "/trade-market";
  static const String marketWaitList = "$_tradeMarket/wait-list";
  static const String marketPriceDetail = "$_tradeMarket/detail";
  static const String marketLatestPrice = "$_tradeMarket/latest";
  static const String adventurerHub = "/adventurer-hub";
  static const String createPost = "$adventurerHub/post/create";
  static const String updatePost = "$adventurerHub/post/update";
  static const String getRecentPosts = "$adventurerHub/posts";
  static const String getPost = "$adventurerHub/post";
  static const String getPostDetail = "$adventurerHub/post/detail";
  static const String openPost = "$adventurerHub/post/open";
  static const String closePost = "$adventurerHub/post/close";
  static const String joinToPost = "$adventurerHub/post/join";
  static const String cancelToPost = "$adventurerHub/post/cancel";
  static const String acceptApplicant = "$adventurerHub/post/accept";
  static const String rejectApplicant = "$adventurerHub/post/reject";
  static const String getApplicant = "$adventurerHub/post/applicant";
  static const String getApplicants = "$adventurerHub/post/applicants";
  static const String getUserJoined = "$adventurerHub/user/joined";
}
