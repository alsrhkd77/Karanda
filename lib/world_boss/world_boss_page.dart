import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:karanda/common/api.dart';
import 'package:karanda/common/duration_extension.dart';
import 'package:karanda/common/server_time.dart';
import 'package:karanda/common/time_of_day_extension.dart';
import 'package:karanda/widgets/default_app_bar.dart';
import 'package:karanda/widgets/loading_indicator.dart';
import 'package:karanda/widgets/title_text.dart';
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

  double calcAspectRatio(double width) {
    if (width > 1800) {
      return 1.2;
    }
    if (width > 1700) {
      return 1.0;
    }
    if (width > 1600) {
      return 0.9;
    }
    if (width > 1400) {
      return 0.8;
    } else if (width > 1200) {
      return 0.7;
    } else if (width > 800) {
      return 0.7;
    }
    return 1.0;
  }

  int calcCrossAxisCount(double width) {
    if (width > 1200) {
      return 3;
    } else if (width > 800) {
      return 2;
    }
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    return Scaffold(
      appBar: const DefaultAppBar(),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: ListTile(
              leading: const Icon(FontAwesomeIcons.dragon),
              title: const TitleText(
                '월드 보스 (Beta)',
                bold: true,
              ),
              trailing: IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => WorldBossSettingsPage(
                        controller: _controller,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.construction),
                tooltip: '설정',
              ),
            ),
          ),
          StreamBuilder(
              stream: _controller.stream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SliverToBoxAdapter(
                    child: LoadingIndicator(),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.all(12.0),
                  sliver: SliverGrid.count(
                    crossAxisCount: calcCrossAxisCount(width),
                    mainAxisSpacing: 8.0,
                    crossAxisSpacing: 8.0,
                    childAspectRatio: calcAspectRatio(width),
                    children: [
                      _Card(boss: snapshot.requireData.previous),
                      _Card(boss: snapshot.requireData.next),
                      _Card(boss: snapshot.requireData.followed),
                    ],
                  ),
                );
              }),
        ],
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
              Wrap(
                alignment: WrapAlignment.center,
                children: widget.boss.nameList
                    .map((e) => BossImageAvatar(name: e))
                    .toList(),
              ),
              Column(
                children: [
                  Text(
                    widget.boss.names,
                    style: Theme.of(context).textTheme.displaySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 8.0,
                  ),
                  Text(
                    diff.isNegative && diff.inMinutes == 0
                        ? '출현!'
                        : diff
                            .splitString()
                            .replaceAll('-', '')
                            .padLeft(8, '0'),
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: diff.isNegative
                            ? (diff.inMinutes == 0 ? Colors.green : Colors.red)
                            : Colors.blue),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class BossImageAvatar extends StatelessWidget {
  final String name;

  const BossImageAvatar({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CircleAvatar(
        radius: 60.0,
        backgroundColor: Colors.transparent,
        foregroundImage: NetworkImage(
          '${Api.worldBossPortrait}/$name.png',
        ),
      ),
    );
  }
}
