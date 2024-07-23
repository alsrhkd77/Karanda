import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:karanda/common/duration_extension.dart';
import 'package:karanda/common/server_time.dart';
import 'package:karanda/common/time_of_day_extension.dart';
import 'package:karanda/widgets/default_app_bar.dart';
import 'package:karanda/widgets/loading_indicator.dart';
import 'package:karanda/widgets/title_text.dart';
import 'package:karanda/world_boss_timer/boss_timer_controller.dart';
import 'package:karanda/world_boss_timer/models/boss.dart';

class WorldBossTimerPage extends StatefulWidget {
  const WorldBossTimerPage({super.key});

  @override
  State<WorldBossTimerPage> createState() => _WorldBossTimerPageState();
}

class _WorldBossTimerPageState extends State<WorldBossTimerPage> {
  final BossTimerController _controller = BossTimerController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DefaultAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const ListTile(
              leading: Icon(FontAwesomeIcons.dragon),
              title: TitleText(
                '보스 타이머',
                bold: true,
              ),
            ),
            StreamBuilder(
                stream: _controller.stream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return LoadingIndicator();
                  }
                  return Wrap(
                    children: [
                      _Card(boss: snapshot.requireData.previous),
                      _Card(boss: snapshot.requireData.next),
                      _Card(boss: snapshot.requireData.followed),
                    ],
                  );
                }),
          ],
        ),
      ),
    );
  }
}

class _Card extends StatefulWidget {
  final Boss boss;

  const _Card({super.key, required this.boss});

  @override
  State<_Card> createState() => _CardState();
}

class _CardState extends State<_Card> {
  final ServerTime _serverTime = ServerTime();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: StreamBuilder(
        stream: _serverTime.stream,
        builder: (context, now) {
          if (!now.hasData) {
            return Container();
          }
          Duration diff = widget.boss.spawnTime.difference(now.requireData);
          return Column(
            children: [
              Text.rich(TextSpan(
                  style: Theme.of(context).textTheme.displayMedium,
                  children: [
                    TextSpan(
                        text: TimeOfDay.fromDateTime(widget.boss.spawnTime)
                            .timeWithPeriod()),
                    TextSpan(text: ' ${widget.boss.names}'),
                  ])),
              Text(
                diff.toHMS(),
                style: Theme.of(context).textTheme.displayMedium,
              ),
            ],
          );
        },
      ),
    );
  }
}
