import 'dart:math';

import 'package:karanda/common/api.dart';
import 'package:karanda/verification_center/models/main_family.dart';

class User {
  late String discordId;
  String? avatar;
  late String username;
  MainFamily? mainFamily;

  User({
    required this.discordId,
    required this.avatar,
    required this.username,
    this.mainFamily,
  });

  User.fromData(Map data) {
    discordId = data['discordId'];
    if(data['avatar'] != null){
      avatar = "${Api.discordAvatar}/${data['avatar']}";
    }
    username = data['username'];
    if (data.containsKey('mainFamily') && data['mainFamily'] != null) {
      mainFamily = MainFamily.fromData(data['mainFamily']);
    }
  }

  Map toData(){
    Map data = {};
    data['discordId'] = discordId;
    data['avatar'] = avatar;
    data['username'] = username;
    data['mainFamily'] = mainFamily?.toData();
    return data;
  }
}
