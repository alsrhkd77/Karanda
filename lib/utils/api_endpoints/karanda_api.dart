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
  static const String _partyFinder = "/party-finder";
  static const String createPost = "$_partyFinder/post/create";
  static const String updatePost = "$_partyFinder/post/update";
  static const String getRecentPosts = "$_partyFinder/posts";
  static const String getPost = "$_partyFinder/post";
  static const String getPostDetail = "$_partyFinder/post/detail";
  static const String openPost = "$_partyFinder/post/open";
  static const String closePost = "$_partyFinder/post/close";
  static const String joinToPost = "$_partyFinder/post/join";
  static const String cancelToPost = "$_partyFinder/post/cancel";
  static const String acceptApplicant = "$_partyFinder/post/accept";
  static const String rejectApplicant = "$_partyFinder/post/reject";
  static const String getApplicant = "$_partyFinder/post/applicant";
  static const String getApplicants = "$_partyFinder/post/applicants";
  static const String getUserJoined = "$_partyFinder/user/joined";
  static const String _fcm = "/fcm";
  static const String getUserFcmSettings = "$_fcm/settings";
  static const String saveUserFcmSettings = "$_fcm/settings/save";
  static const String deleteFcmToken = "$_fcm/token/delete";
  static const String updateFcmToken = "$_fcm/token/update";
  static const String _reportHub = "/report-hub";
  static const String getReportStatus = "$_reportHub/status";
  static const String getReports = "$_reportHub/reports";
  static const String addReport = "$_reportHub/report";
  static const String cancelReport = "$_reportHub/cancel";
}
