class WorldBossSetting {
  bool useAlarm = false;
  List<int> alarm = [1, 5, 10];
  List<String> excludedBoss =[];

  WorldBossSetting.fromJson(Map data) {
    useAlarm = data['use-alarm'] ?? useAlarm;
    excludedBoss = data['excluded-boss'].cast<String>() ?? [];
    if(data.containsKey('alarm')) {
      alarm = List.generate(data['alarm'].length, (index) => data['alarm'][index]);
    }
  }

  Map toJson() {
    Map data = {};
    if(useAlarm) {
      data['use-alarm'] = useAlarm;
    }
    data['alarm'] = alarm;
    data['excluded-boss'] = excludedBoss;
    return data;
  }
}
