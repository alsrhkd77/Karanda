import 'dart:math';

import 'package:karanda/common/api.dart';
import 'package:karanda/verification_center/models/bdo_family.dart';

class User {
  late String discordId;
  String? avatar;
  late String username;
  BdoFamily? mainFamily;

  User({
    required this.discordId,
    required this.avatar,
    required this.username,
    this.mainFamily,
  });

  User.fromData(Map data) {
    discordId = data['discordId'];
    avatar = data['avatar'] == null
        ? "${Api.discordEmbedAvatar}/${Random().nextInt(6)}.png"
        : "${Api.discordAvatar}/${data['avatar']}";
    username = data['username'];
    if (data.containsKey('mainFamily') && data['mainFamily'] != null) {
      mainFamily = BdoFamily.fromData(data['mainFamily']);
    }
  }
}
