import 'package:karanda/common/api.dart';

class User {
  late String discordId;
  String? avatar;
  late String username;

  User({
    required this.discordId,
    required this.avatar,
    required this.username,
  });

  User.fromData(Map data) {
    discordId = data['discordId'];
    if(data['avatar'] != null){
      avatar = "${Api.discordAvatar}/${data['avatar']}";
    }
    username = data['username'];
  }

  Map toData(){
    Map data = {};
    data['discordId'] = discordId;
    data['avatar'] = avatar;
    data['username'] = username;
    return data;
  }
}
