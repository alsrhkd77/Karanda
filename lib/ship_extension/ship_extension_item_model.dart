class ShipExtensionItemModel{
  late String name;
  late String farmingRootName;
  late String detail;
  late String npc;
  late int reward;
  late int price;
  late String assetPath;
  List<String> parts = [];

  int user = 0;
  int need = 0;

  ShipExtensionItemModel.fromJson(this.name, Map data){
    Map farming = data['주 획득처'];
    farmingRootName = farming['name'];
    detail = farming['detail'];
    npc = farming['npc'];
    reward = farming['reward'];
    price = data['가격'];
    assetPath = data['path'];
  }
}