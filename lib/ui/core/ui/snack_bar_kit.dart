import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../auth/widgets/auth_page.dart';

class SnackBarKit {
  BuildContext context;

  SnackBarKit.of(this.context);

  void needLogin() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(
        children: [
          const Padding(
            padding: EdgeInsets.all(4.0),
            child: Icon(Icons.lock_outline, color: Colors.red),
          ),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text(context.tr("need login")),
          ),
        ],
      ),
      action: SnackBarAction(
        label: context.tr("auth.login"),
        onPressed: (){
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const AuthPage(),
          ));
        },
      ),
    ));
  }

  void requestFailed(){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(
        children: [
          const Padding(
            padding: EdgeInsets.all(4.0),
            child: Icon(Icons.error_outline, color: Colors.red),
          ),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text(context.tr("request filed")),
          ),
        ],
      ),
    ));
  }
}
