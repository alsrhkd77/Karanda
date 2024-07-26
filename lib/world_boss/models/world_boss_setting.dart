class WorldBossSetting {
  bool useAlarm = false;
  bool useOverlay = false;
  List<int> alarm = [1, 5, 10];

  WorldBossSetting.fromJson(Map data) {
    useAlarm = data['use-alarm'] ?? useAlarm;
    useOverlay = data['use-overlay'] ?? useOverlay;
    if(data.containsKey('alarm')) {
      alarm = List.generate(data['alarm'].length, (index) => data['alarm'][index]);
    }
  }

  Map toJson() {
    Map data = {};
    if(useAlarm) {
      data['use-alarm'] = useAlarm;
    }
    if (useOverlay) {
      data['use-overlay'] = useOverlay;
    }
    data['alarm'] = alarm;
    return data;
  }
}
