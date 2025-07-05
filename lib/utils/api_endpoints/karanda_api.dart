import 'package:flutter/foundation.dart' show kDebugMode;

abstract final class KarandaApi {
  static const String scheme = kDebugMode ? 'http' : 'https';
  static const String host = kDebugMode ? 'localhost' : 'api.karanda.kr';
  ///don't use [port] in release mode
  static const int port = 8000;

  static const liveChannel = "${kDebugMode? "ws" : "wss"}://$host${kDebugMode ? ":$port":""}/live-channel";
  static const storage = "https://storage.googleapis.com/karanda";

  static const String latestVersion = "https://www.karanda.kr/version.json";
  static const List<String> latestVersionMirrors = [
    "https://github.com/Hammuu1112/Karanda/releases/latest/download/SetupKaranda.exe",
    "https://storage.googleapis.com/karanda/SetupKaranda.exe"
  ];

  static const String itemImage = "$storage/bdo/item/image";
  static const String classSymbol = "$storage/bdo/classes/symbol";

  static const String _auth = "/auth";
  static const String authorization = "$_auth/discord/authorization";
  static const String tokenRefresh = "$_auth/discord/refresh";
  static const String unregister = "$_auth/discord/unregister";
  static const String _family = "/bdo-family";
  static const String registerFamily = "$_family/register";
  static const String unregisterFamily = "$_family/unregister";
  static const String updateFamilyData = "$_family/update-family";
  static const String startFamilyVerification = "$_family/start-verification";
  static const String verifyFamily = "$_family/verify";
  static const String _tradeMarket = "/trade-market";
  static const String marketWaitList = "$_tradeMarket/wait-list";
  static const String marketPriceDetail = "$_tradeMarket/detail";
  static const String marketLatestPrice = "$_tradeMarket/latest";
  static const String partyFinder = "/party-finder";
  static const String createPost = "$partyFinder/post/create";
  static const String updatePost = "$partyFinder/post/update";
  static const String getRecentPosts = "$partyFinder/posts";
  static const String getPost = "$partyFinder/post";
  static const String getPostDetail = "$partyFinder/post/detail";
  static const String openPost = "$partyFinder/post/open";
  static const String closePost = "$partyFinder/post/close";
  static const String joinToPost = "$partyFinder/post/join";
  static const String cancelToPost = "$partyFinder/post/cancel";
  static const String acceptApplicant = "$partyFinder/post/accept";
  static const String rejectApplicant = "$partyFinder/post/reject";
  static const String getApplicant = "$partyFinder/post/applicant";
  static const String getApplicants = "$partyFinder/post/applicants";
  static const String getUserJoined = "$partyFinder/user/joined";
  static const String fcm = "/fcm";
  static const String getUserFcmSettings = "$fcm/settings";
  static const String saveUserFcmSettings = "$fcm/settings/save";
  static const String deleteFcmToken = "$fcm/token/delete";
  static const String updateFcmToken = "$fcm/token/update";
}
