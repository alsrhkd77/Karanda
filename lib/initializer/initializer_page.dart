import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:karanda/auth/auth_notifier.dart';
import 'package:karanda/initializer/karanda_initializer.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

class InitializerPage extends StatefulWidget {
  const InitializerPage({super.key});

  @override
  State<InitializerPage> createState() => _InitializerPageState();
}

class _InitializerPageState extends State<InitializerPage> {
  final KarandaInitializer initializer = KarandaInitializer();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => runTasks());
  }

  Future<void> runTasks() async {
    try {
      await initializer.runTasks(context.read<AuthNotifier>().authorization());
    } catch (e) {
      print(e);
    } finally {
      await setWindows();
      context.go("/");
    }
  }

  Future<void> setWindows() async {
    await windowManager.hide();
    await windowManager.setTitleBarStyle(TitleBarStyle.normal);
    await windowManager.setSize(const Size(1280, 720));
    await windowManager.center();
    await windowManager.show();
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
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
                  StreamBuilder(
                    stream: initializer.version,
                    builder: (context, snapshot) => Text(
                      snapshot.hasData ? snapshot.data! : '',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),
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
                    child: StreamBuilder(
                      stream: initializer.task,
                      builder: (context, snapshot) =>
                          Text(snapshot.hasData ? snapshot.data! : ''),
                    ),
                  ),
                  StreamBuilder(
                    stream: initializer.percent,
                    builder: (context, snapshot) => LinearPercentIndicator(
                      animation: true,
                      progressColor: Colors.blue.shade400,
                      animationDuration: 500,
                      percent: snapshot.hasData ? snapshot.data! : 0,
                      barRadius: const Radius.circular(12.0),
                      animateFromLastPercent: true,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
