class WorldBossSetting {
  bool useOverlay = false;
  List<int> alarm = [1,2,3,4,5,10,15];

  WorldBossSetting.fromJson(Map data){
    useOverlay = data['use-overlay'] ?? false;
  }

  Map toJson(){
    Map data = {};
    if(useOverlay){
      data['use-overlay'] = useOverlay;
    }
    return data;
  }
}