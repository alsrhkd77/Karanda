import 'dart:math';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:karanda/common/duration_extension.dart';
import 'package:karanda/common/global_properties.dart';
import 'package:karanda/common/server_time.dart';
import 'package:karanda/common/time_of_day_extension.dart';
import 'package:karanda/widgets/default_app_bar.dart';
import 'package:karanda/widgets/loading_indicator.dart';
import 'package:karanda/world_boss/BossImageAvatar.dart';
import 'package:karanda/world_boss/world_boss_controller.dart';
import 'package:karanda/world_boss/models/boss.dart';
import 'package:karanda/world_boss/world_boss_settings_page.dart';

class WorldBossPage extends StatefulWidget {
  const WorldBossPage({super.key});

  @override
  State<WorldBossPage> createState() => _WorldBossPageState();
}

class _WorldBossPageState extends State<WorldBossPage> {
  final WorldBossController _controller = WorldBossController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((timeStamp) => _controller.subscribe());
  }

  int calcCrossAxisCount(double width) {
    if (width > 1200) {
      return 3;
    } else if (width > 680) {
      return 2;
    }
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    return Scaffold(
      appBar: DefaultAppBar(
        icon: FontAwesomeIcons.dragon,
        title: "월드 보스 (Beta)",
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => WorldBossSettingsPage(
                      controller: _controller,
                    ),
                  ),
                );
                _controller.init();
              },
              icon: const Icon(Icons.construction),
              tooltip: '설정',
            ),
          )
        ],
      ),
      body: StreamBuilder(
          stream: _controller.stream,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const LoadingIndicator();
            }
            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.symmetric(
                    vertical: GlobalProperties.scrollViewVerticalPadding,
                    horizontal:
                        GlobalProperties.scrollViewHorizontalPadding(width),
                  ),
                  sliver: SliverGrid.count(
                    crossAxisCount: calcCrossAxisCount(width),
                    mainAxisSpacing: 8.0,
                    crossAxisSpacing: 8.0,
                    childAspectRatio: min(340, width) / 550,
                    children: [
                      _Card(boss: snapshot.requireData.previous),
                      _Card(boss: snapshot.requireData.next),
                      _Card(boss: snapshot.requireData.followed),
                    ],
                  ),
                )
              ],
            );
          }),
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
          return Container(
            height: 550,
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  TimeOfDay.fromDateTime(widget.boss.spawnTime)
                      .timeWithoutPeriod(),
                  style: Theme.of(context)
                      .textTheme
                      .displayMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                Container(
                  height: 320,
                  constraints: const BoxConstraints(maxWidth: 320),
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Center(
                    child: GridView.count(
                      crossAxisCount: min(widget.boss.nameList.length, 2),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 1.0,
                      children: widget.boss.nameList
                          .map<Widget>((e) => BossImageAvatar(name: e))
                          .toList(),
                    ),
                  ),
                ),
                SizedBox(
                  height: 84,
                  child: Center(
                    child: Text(
                      widget.boss.names,
                      style: Theme.of(context).textTheme.displaySmall,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Text(
                  diff.isNegative && diff.inMinutes == 0
                      ? '출현!'
                      : diff.splitString().replaceAll('-', '').padLeft(8, '0'),
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: diff.isNegative
                          ? (diff.inMinutes == 0 ? Colors.green : Colors.red)
                          : Colors.blue),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
