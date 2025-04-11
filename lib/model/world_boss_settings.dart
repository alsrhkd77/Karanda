class WorldBossSettings {
  bool notify;
  final Set<int> notificationTime = {};
  final Set<String> excluded = {};

  WorldBossSettings({
    this.notify = false,
    Set<int>? notificationTime,
    Set<String>? excluded,
  }) {
    this.notificationTime.addAll(notificationTime ?? {1, 5, 10});
    this.excluded.addAll(excluded ?? {});
  }

  factory WorldBossSettings.fromJson(Map json) {
    return WorldBossSettings(
      notify: json["notify"],
      notificationTime: Set.from(json["notificationTime"] ?? []),
      excluded: Set.from(json["excluded"] ?? []),
    );
  }

  Map toJson() {
    return {
      "notify": notify,
      "notificationTime": notificationTime.toList(),
      "excluded": excluded.toList(),
    };
  }
}
