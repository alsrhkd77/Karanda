import 'package:flutter/material.dart';
import 'package:karanda/model/user.dart';
import 'package:karanda/ui/core/ui/class_symbol_widget.dart';

class UserWidget extends StatelessWidget {
  final User user;
  final bool verifyIcon;

  const UserWidget({super.key, required this.user, this.verifyIcon = true});

  @override
  Widget build(BuildContext context) {
    if (user.family == null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            foregroundImage: Image.network(user.avatar).image,
            backgroundColor: Colors.transparent,
            radius: 14,
          ),
          const SizedBox(width: 6),
          Text(user.username),
        ],
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClassSymbolWidget(bdoClass: user.family!.mainClass, size: 24,),
        Padding(
          padding: EdgeInsets.only(
            left: 2.0,
            right: verifyIcon ? 4.0 : 0.0,
          ),
          child: Text(user.family!.familyName),
        ),
        verifyIcon
            ? Icon(
                Icons.verified,
                color: user.family!.verified ? Colors.blue : Colors.grey,
          size: 16,
              )
            : const SizedBox(),
      ],
    );
  }
}
