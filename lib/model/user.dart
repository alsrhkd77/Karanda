import 'package:karanda/model/bdo_family.dart';

class User {
  String discordId;
  String username;
  /// 서버 계약상 nullable(`UserDTO.avatar: String?`). 렌더링 시 null을 처리해야 한다.
  String? avatar;
  BDOFamily? family;

  User({
    required this.discordId,
    required this.username,
    required this.avatar,
    required this.family,
  });

  factory User.fromJson(Map json) {
    return User(
      discordId: json["discordId"],
      username: json["username"],
      avatar: json["avatar"],
      family:
          json["bdoFamily"] == null ? null : BDOFamily.fromJson(json["bdoFamily"]),
    );
  }

  Map toJson() {
    return {
      "discordId": discordId,
      "username": username,
      "avatar": avatar,
      "bdoFamily": family?.toJson(),
    };
  }
}
