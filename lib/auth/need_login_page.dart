import 'package:flutter/material.dart';
import 'package:karanda/widgets/default_app_bar.dart';
import 'package:karanda/widgets/need_login.dart';

class NeedLoginPage extends StatelessWidget {
  const NeedLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: DefaultAppBar(),
      body: NeedLogin(),
    );
  }
}
