class AudioPlayerSettings {
  double volume;

  AudioPlayerSettings({this.volume = 100.0});

  factory AudioPlayerSettings.fromJson(Map json) {
    return AudioPlayerSettings(volume: json["volume"]);
  }

  Map toJson() {
    return {
      "volume": volume,
    };
  }
}
