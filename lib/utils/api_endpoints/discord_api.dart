import 'package:flutter/foundation.dart' show kReleaseMode;

abstract final class DiscordApi {
  static const String authenticateWeb = kReleaseMode
      ? 'https://discord.com/api/oauth2/authorize?client_id=1097362924584046712&redirect_uri=http%3A%2F%2Fapi.karanda.kr%2Fauth%2Fdiscord%2Fauthenticate%2Fweb&response_type=code&scope=identify'
      : 'https://discord.com/api/oauth2/authorize?client_id=1097362924584046712&redirect_uri=http%3A%2F%2Flocalhost%3A8000%2Fauth%2Fdiscord%2Fauthenticate%2Fweb&response_type=code&scope=identify%20email&prompt=none';

  static const String authenticateWindows = kReleaseMode
      ? 'https://discord.com/api/oauth2/authorize?client_id=1097362924584046712&redirect_uri=http%3A%2F%2Fapi.karanda.kr%2Fauth%2Fdiscord%2Fauthenticate%2Fwindows&response_type=code&scope=identify'
      : 'https://discord.com/api/oauth2/authorize?client_id=1097362924584046712&redirect_uri=http%3A%2F%2Flocalhost%3A8000%2Fauth%2Fdiscord%2Fauthenticate%2Fwindows&response_type=code&scope=identify%20email&prompt=none';

  static const String karandaChannel = "https://discord.gg/8ZRAMGdcYG";
}
