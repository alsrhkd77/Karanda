import 'package:flutter/material.dart';
import 'package:karanda/auth/user.dart';
import 'package:karanda/common/api.dart';

class DiscordNameWidget extends StatelessWidget {
  final User user;

  const DiscordNameWidget({super.key, required this.user});

  String get _avatar => _getAvatarFromId().toString();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: CircleAvatar(
            foregroundImage: Image.network(user.avatar ??
                    "${Api.discordEmbedAvatar}/$_avatar.png")
                .image,
            radius: 12,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: Text(user.username),
        ),
      ],
    );
  }

  int _getAvatarFromId(){
    int code = int.tryParse(user.discordId[0]) ?? 0;
    if(code > 5){
      code = (code / 2).round();
    }
    return code;
  }
}
