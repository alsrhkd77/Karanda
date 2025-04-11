import 'package:karanda/model/bdo_family.dart';

class User {
  String discordId;
  String username;
  String avatar;
  BDOFamily? mainFamily;

  User({
    required this.discordId,
    required this.username,
    required this.avatar,
    required this.mainFamily,
  });

  factory User.fromJson(Map json) {
    List<BDOFamily> family = [];
    for(Map data in json["families"] ?? []){
      family.add(BDOFamily.fromJson(data));
    }
    return User(
      discordId: json["discordId"],
      username: json["username"],
      avatar: json["avatar"],
      mainFamily: json["mainFamily"],
    );
  }
}
