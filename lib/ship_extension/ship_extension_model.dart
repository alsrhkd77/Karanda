class ShipExtensionModel {
  late String type;
  late String name;
  late String prowName;  //선수상 이름
  late String platingName; //장갑 이름
  late String cannonName;  //함포 이름
  late String windSailName;  //돛 이름
  late Map<String, dynamic> spec; //선박 능력치
  late Map<String, dynamic> prowItem;  //선수상 증축 재료
  late Map<String, dynamic> platingItem; //장갑 증축 재료
  late Map<String, dynamic> cannonItem;  //함포 증축 재료
  late Map<String, dynamic> windSailItem;  //돛 증축 재료
  late Map<String, dynamic> item;

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

  Map<String, int> getNeed(List<String> exclude){
    Map<String, int> result = {};
    for(String prow in prowItem.keys){
      if(!exclude.contains('prow')){
        result[prow] = prowItem[prow] as int;
      } else{
        result[prow] = 0;
      }
    }
    for(String plating in platingItem.keys){
      if(result.containsKey(plating)){
        if(!exclude.contains('plating')){
          result[plating] = result[plating]! + platingItem[plating] as int;
        }
      }else{
        if(!exclude.contains('plating')){
          result[plating] = platingItem[plating] as int;
        } else {
          result[plating] = 0;
        }
      }
    }
    for(String cannon in cannonItem.keys){
      if(result.containsKey(cannon)){
        if(!exclude.contains('cannon')){
          result[cannon] = result[cannon]! + cannonItem[cannon] as int;
        }
      }else{
        if(!exclude.contains('cannon')){
          result[cannon] = cannonItem[cannon] as int;
        } else{
          result[cannon] = 0;
        }
      }
    }
    for(String windSail in windSailItem.keys){
      if(result.containsKey(windSail)){
        if(!exclude.contains('windSail')){
          result[windSail] = result[windSail]! + windSailItem[windSail] as int;
        }
      }else{
        if(!exclude.contains('windSail')){
          result[windSail] = windSailItem[windSail] as int;
        } else{
          result[windSail] = 0;
        }
      }
    }
    for(String i in item.keys){
      if(result.containsKey(i)){
        result[i] = result[i]! + item[i] as int;
      }else{
        result[i] = item[i];
      }
    }
    return result;
  }
}
