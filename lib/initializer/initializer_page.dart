import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:window_manager/window_manager.dart';

class InitializerPage extends StatefulWidget {
  const InitializerPage({super.key});

  @override
  State<InitializerPage> createState() => _InitializerPageState();
}

class _InitializerPageState extends State<InitializerPage> {

  Future<void> setWindows() async {
    //await windowManager.setTitleBarStyle(TitleBarStyle.hidden);

    await Future.delayed(Duration(seconds: 3));
    await windowManager.hide();
    await windowManager.setTitleBarStyle(TitleBarStyle.normal);
    await windowManager.setSize(const Size(1280, 720));
    await windowManager.center();
    await windowManager.show();
    context.go("/");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Karanda',
                    style: TextStyle(
                      fontFamily: 'NanumSquareRound',
                      fontWeight: FontWeight.w700,
                      fontSize: 22.0,
                    ),
                  ),
                  Text('2.5.3', style: TextStyle(
                    color: Colors.grey.shade600
                  ),),
                ],
              ),
            ),
            Image.asset(
              'assets/brand/karanda_shape.png',
              width: 200,
              height: 200,
              filterQuality: FilterQuality.high,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text('Check for update'),
                  ),
                  LinearProgressIndicator(
                    borderRadius: BorderRadius.circular(12.0),
                    value: 0.58,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      setWindows();
    }
  }
}
