import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:karanda/enums/features.dart';

class AppNotificationMessage {
  final Features feature;
  final String contentsKey;
  final List<String>? contentsArgs;
  final String? route;
  final bool mdContents;

  AppNotificationMessage({
    required this.feature,
    required this.contentsKey,
    this.contentsArgs,
    this.route,
    required this.mdContents,
  });

  factory AppNotificationMessage.fromJson(Map json) {
    return AppNotificationMessage(
      feature: Features.values.byName(json["feature"]),
      contentsKey: json["contentsKey"],
      contentsArgs: json["contentsArgs"] == null
          ? null
          : List<String>.from(json["contentsArgs"]),
      route: json["route"],
      mdContents: json["mdContents"] ?? false,
    );
  }

  factory AppNotificationMessage.fromRemoteMessage(RemoteMessage msg) {
    String f = msg.notification?.title?.replaceAll(' ', '') ??
        Features.notifications.name;
    f = f[0].toLowerCase() + f.substring(1);
    if(msg.notification?.bodyLocKey == null){
      return AppNotificationMessage(
        feature: Features.values.byName(f),
        contentsKey: "notifications",
        contentsArgs: [msg.notification?.body ?? "Empty message"],
        mdContents: false,
      );
    }
    return AppNotificationMessage(
      feature: Features.values.byName(f),
      contentsKey: msg.notification!.bodyLocKey!,
      contentsArgs: msg.notification?.bodyLocArgs,
      mdContents: false,
    );
  }

  Map toJson() {
    return {
      "feature": feature.name,
      "contentsKey": contentsKey,
      "contentsArgs": contentsArgs,
      "route": route,
      "mdContents": mdContents,
    };
  }
}
