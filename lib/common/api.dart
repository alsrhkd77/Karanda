import 'package:flutter/foundation.dart';

class Api {
  static String get host {
    if (kReleaseMode) {
      return 'https://www.karanda.kr';
    } else {
      return 'http://localhost:2345';
    }
  }

  static String get _server {
    if (kReleaseMode) {
      //return 'https://karanda-server-6hf3d25tnq-an.a.run.app';
      return 'https://api.karanda.kr';
    } else {
      return 'http://localhost:8000';
    }
  }

  static String get _socketServer =>
      _server.replaceAll('http', 'ws');

  static String get webSocketChannel => '${_server.replaceAll('http', 'ws')}/live-channel';

  static String get _webSocketPrefix => '/live-data';

  static String get karandaDiscordServer => 'https://discord.gg/8ZRAMGdcYG';

  static String get authenticateWeb {
    if (kReleaseMode) {
      //return 'https://discord.com/api/oauth2/authorize?client_id=1097362924584046712&redirect_uri=http%3A%2F%2Fkaranda-server-6hf3d25tnq-an.a.run.app%2Fauth%2Fdiscord%2Fauthenticate%2Fweb&response_type=code&scope=identify%20email';
      return 'https://discord.com/api/oauth2/authorize?client_id=1097362924584046712&redirect_uri=http%3A%2F%2Fapi.karanda.kr%2Fauth%2Fdiscord%2Fauthenticate%2Fweb&response_type=code&scope=identify';
    } else {
      return 'https://discord.com/api/oauth2/authorize?client_id=1097362924584046712&redirect_uri=http%3A%2F%2Flocalhost%3A8000%2Fauth%2Fdiscord%2Fauthenticate%2Fweb&response_type=code&scope=identify%20email&prompt=none';
    }
  }

  static String get authenticateWindows {
    if (kReleaseMode) {
      //return 'https://discord.com/api/oauth2/authorize?client_id=1097362924584046712&redirect_uri=http%3A%2F%2Fkaranda-server-6hf3d25tnq-an.a.run.app%2Fauth%2Fdiscord%2Fauthenticate%2Fwindows&response_type=code&scope=identify%20email';
      return 'https://discord.com/api/oauth2/authorize?client_id=1097362924584046712&redirect_uri=http%3A%2F%2Fapi.karanda.kr%2Fauth%2Fdiscord%2Fauthenticate%2Fwindows&response_type=code&scope=identify';
    } else {
      return 'https://discord.com/api/oauth2/authorize?client_id=1097362924584046712&redirect_uri=http%3A%2F%2Flocalhost%3A8000%2Fauth%2Fdiscord%2Fauthenticate%2Fwindows&response_type=code&scope=identify%20email&prompt=none';
    }
  }

  static String get latestVersion => 'https://www.karanda.kr/version.json';

  static String get latestInstaller => 'https://github.com/Hammuu1112/Karanda/releases/latest';

  static String get discordCDN => 'https://cdn.discordapp.com/avatars/';

  static String get _checklist => '$_server/checklist';

  static String get storage => 'https://storage.googleapis.com/storage.karanda.kr';

  static String get _tradeMarket => '$_server/trade-market';

  static String get _marettaStatusReport => '$_server/maretta';

  static String get _blacklist => '$_server/blacklist';

  static String get _chzzk => '$_server/chzzk';

  static String get _bdoFamily => '$_server/auth/bdo-family';

  static String get _bdoNews => 'https://raw.githubusercontent.com/Hammuu1112/news/main/news';

  static String get authorization => '$_server/auth/discord/authorization';

  static String get unregister => '$_server/auth/discord/unregister';

  static String get logout => '$_server/auth/discord/logout';

  static String get tokenRefresh => '$_server/auth/discord/refresh';

  static String get getChecklistItems => '$_checklist/get/checklist-items';

  static String get getChecklistFinishedItems =>
      '$_checklist/get/finished-items';

  static String get createChecklistItem => '$_checklist/create/checklist-item';

  static String get createChecklistFinishedItem =>
      '$_checklist/create/finished-item';

  static String get deleteChecklistItem => '$_checklist/delete/checklist-item';

  static String get deleteChecklistFinishedItem =>
      '$_checklist/delete/finished-item';

  static String get updateChecklistItem => '$_checklist/update/checklist-item';

  static String get marettaStatusReports => '$_socketServer/maretta/reports';

  static String get createMarettaStatusReport => '$_marettaStatusReport/create/report';

  static String get getMarettaStatusReport => '$_marettaStatusReport/get/reports';

  static String get getMarettaBlacklist => '$_blacklist/get/maretta';

  static String get createMarettaBlacklist => '$_blacklist/create/maretta';

  static String get itemImage => '$storage/bdo/item/image';

  static String get worldBossPortrait => '$storage/bdo/worldboss/portrait';

  static String get classSymbol => '$storage/bdo/class-symbol';

  static String get marketWaitListChannel => '$_webSocketPrefix/trade-market/wait-list';

  static String get marketWaitList => '$_tradeMarket/wait-list';

  static String get marketItemDetail => '$_tradeMarket/detail';

  static String get marketItemLatest => '$_tradeMarket/latest';

  static String get chzzkLiveStatus => '$_chzzk/live-status';

  static String get bdoEvents => '$_bdoNews/kr_event.json';

  static String get bdoUpdates => '$_bdoNews/kr_update.json';

  static String get bdoLabUpdates => '$_bdoNews/lab_update.json';

  static String get allFamilies => '$_bdoFamily/families';

  static String get registerFamily => '$_bdoFamily/register';

  static String get verifyFamily => '$_bdoFamily/verify';

  static String get unregisterFamily => '$_bdoFamily/unregister';

  static String get refreshFamilyData => '$_bdoFamily/refresh';

  static String get setMainFamily => '$_bdoFamily/set-main';
}
