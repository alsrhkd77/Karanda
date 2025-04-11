class AppNotificationMessage {
  final String content;
  final String? route;

  AppNotificationMessage({required this.content, this.route});

  factory AppNotificationMessage.fromJson(Map json) {
    return AppNotificationMessage(
      content: json["content"],
      route: json["route"],
    );
  }

  Map toJson() {
    return {
      "content": content,
      "route": route,
    };
  }
}
