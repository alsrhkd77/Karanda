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
      return 'https://karanda-server-6hf3d25tnq-an.a.run.app';
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

  static String get authorization => '$_server/auth/discord/authorization';
}
