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

  static String get authenticateWeb {
    if (kReleaseMode) {
      return 'https://discord.com/api/oauth2/authorize?client_id=1097362924584046712&redirect_uri=http%3A%2F%2Fkaranda-server-6hf3d25tnq-an.a.run.app%2Fauth%2Fdiscord%2Fauthenticate%2Fweb&response_type=code&scope=identify%20email';
    } else {
      return 'https://discord.com/api/oauth2/authorize?client_id=1097362924584046712&redirect_uri=http%3A%2F%2Flocalhost%3A8000%2Fauth%2Fdiscord%2Fauthenticate%2Fweb&response_type=code&scope=identify%20email';
    }
  }

  static String get authenticateWindows {
    if (kReleaseMode) {
      return 'https://discord.com/api/oauth2/authorize?client_id=1097362924584046712&redirect_uri=http%3A%2F%2Fkaranda-server-6hf3d25tnq-an.a.run.app%2Fauth%2Fdiscord%2Fauthenticate%2Fwindows&response_type=code&scope=identify%20email';
    } else {
      return 'https://discord.com/api/oauth2/authorize?client_id=1097362924584046712&redirect_uri=http%3A%2F%2Flocalhost%3A8000%2Fauth%2Fdiscord%2Fauthenticate%2Fwindows&response_type=code&scope=identify%20email';
    }
  }

  static String get _checklist => '$_server/checklist';

  static String get authorization => '$_server/auth/discord/authorization';

  static String get unregister => '$_server/auth/discord/unregister';

  static String get tokenRefresh => '$_server/auth/discord/refresh';

  static String get discordCDN => 'https://cdn.discordapp.com/avatars/';

  static String get getChecklistItems => '$_checklist/get/checklist-items';

  static String get getChecklistFinishedItems => '$_checklist/get/finished-items';

  static String get createChecklistItem => '$_checklist/create/checklist-item';

  static String get createChecklistFinishedItem => '$_checklist/create/finished-item';

  static String get deleteChecklistItem => '$_checklist/delete/checklist-item';

  static String get deleteChecklistFinishedItem => '$_checklist/delete/finished-item';

  static String get updateChecklistItem => '$_checklist/update/checklist-item';

}