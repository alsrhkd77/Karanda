import 'package:karanda/data_source/audio_player_data_source.dart';
import 'package:karanda/model/audio_player_settings.dart';
import 'package:media_kit/media_kit.dart';
import 'package:rxdart/rxdart.dart';

class AudioPlayerRepository {
  Player? _player;
  final AudioPlayerDataSource _dataSource;
  final _settings = BehaviorSubject<AudioPlayerSettings>();

  AudioPlayerRepository({required AudioPlayerDataSource dataSource})
      : _dataSource = dataSource {
    _settings.stream.listen(_saveSettings);
  }

  Stream<AudioPlayerSettings> get settingsStream => _settings.stream;

  Future<void> init() async {
    _settings.sink.add(await _dataSource.loadSettings());
    final player = Player();
    await player.open(
      Media("asset:///assets/sounds/notification.mp3"),
      play: false,
    );
    _player = player;
  }

  Future<void> playNotificationSound() async {
    await _player?.setVolume(_settings.value.volume);
    await _player?.play();
  }

  void setVolume(double value) {
    final snapshot = _settings.value..volume = value;
    _settings.sink.add(snapshot);
  }

  Future<void> _saveSettings(AudioPlayerSettings snapshot) async {
    await _dataSource.saveSettings(snapshot);
  }
}
