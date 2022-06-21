class ShipExtensionModel {
  late String type;
  late String name;
  late String prowName;  //선수상 이름
  late String platingName; //장갑 이름
  late String cannonName;  //함포 이름
  late String windSailName;  //돛 이름
  late Map<String, String> spec; //선박 능력치
  late Map<String, int> prowItem;  //선수상 증축 재료
  late Map<String, int> platingItem; //장갑 증축 재료
  late Map<String, int> cannonItem;  //함포 증축 재료
  late Map<String, int> windSailItem;  //돛 증축 재료
  late Map<String, int> item;

  ShipExtensionModel.fromJson(this.type, Map data){
    name = data['name'];
    prowName = data['prow']['name'];
    platingName = data['plating']['name'];
    cannonName = data['cannon']['name'];
    windSailName = data['windSail']['name'];
    spec = data['spec'];
    prowItem = data['prow']['item'];
    platingItem = data['plating']['item'];
    cannonItem = data['cannon']['item'];
    windSailItem = data['windSail']['item'];
    item = data['item'];
  } //선박 증축 재료


}
