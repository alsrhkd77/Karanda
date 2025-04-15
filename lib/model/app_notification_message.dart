import 'package:karanda/enums/features.dart';

class AppNotificationMessage {
  final Features feature;
  final String content;
  final String? route;
  final bool mdContents;

  AppNotificationMessage({
    required this.feature,
    required this.content,
    this.route,
    required this.mdContents,
  });

  factory AppNotificationMessage.fromJson(Map json) {
    return AppNotificationMessage(
      feature: Features.values.byName(json["feature"]),
      content: json["content"],
      route: json["route"],
      mdContents: json["mdContents"],
    );
  }

  Map toJson() {
    return {
      "feature": feature.name,
      "content": content,
      "route": route,
      "mdContents": mdContents,
    };
  }
}
