import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:karanda/widgets/default_app_bar.dart';
import 'package:karanda/widgets/title_text.dart';

class WorldBossTimerPage extends StatefulWidget {
  const WorldBossTimerPage({super.key});

  @override
  State<WorldBossTimerPage> createState() => _WorldBossTimerPageState();
}

class _WorldBossTimerPageState extends State<WorldBossTimerPage> {
  DateTime d = DateTime.now();
  @override
  Widget build(BuildContext context) {
    d.weekday;
    return Scaffold(
      appBar: DefaultAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListTile(
              trailing: Icon(FontAwesomeIcons.dragon),
              title: TitleText('보스 타이머'),
            ),

          ],
        ),
      ),
    );
  }
}
