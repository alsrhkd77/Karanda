import 'package:karanda/verification_center/models/bdo_family.dart';

class User {
  final String uuid;
  String? discordId;
  String avatar;
  String username;
  BdoFamily? mainFamily;

  User({
    required this.uuid,
    this.discordId,
    required this.avatar,
    required this.username,
    this.mainFamily,
  });
}
