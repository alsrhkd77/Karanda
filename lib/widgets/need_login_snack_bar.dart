import 'package:flutter/material.dart';
import 'package:karanda/common/global_properties.dart';
import 'package:karanda/common/go_router_extension.dart';

class NeedLoginSnackBar {
  NeedLoginSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(
              Icons.lock,
              color: Colors.red,
            ),
            SizedBox(
              width: 8.0,
            ),
            Text('로그인이 필요한 서비스 입니다.'),
          ],
        ),
        action: SnackBarAction(
          label: "로그인",
          backgroundColor: Colors.blueAccent,
          textColor: Colors.white,
          onPressed: () => context.goWithGa('/auth/authenticate'),
        ),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: GlobalProperties.snackBarMargin,
        //showCloseIcon: true,
        backgroundColor: Theme.of(context).snackBarTheme.backgroundColor,
      ),
    );
  }
}
