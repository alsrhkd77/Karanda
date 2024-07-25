import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:karanda/common/api.dart';
import 'package:karanda/common/server_time.dart';
import 'package:karanda/common/time_of_day_extension.dart';
import 'package:karanda/widgets/default_app_bar.dart';
import 'package:karanda/widgets/loading_indicator.dart';
import 'package:karanda/widgets/title_text.dart';
import 'package:karanda/world_boss/world_boss_controller.dart';
import 'package:karanda/world_boss/models/boss.dart';

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

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    return Scaffold(
      appBar: const DefaultAppBar(),
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: ListTile(
              leading: Icon(FontAwesomeIcons.dragon),
              title: TitleText(
                '월드 보스',
                bold: true,
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
                    crossAxisCount: width > 1120 ? 3 : 1,
                    mainAxisSpacing: 8.0,
                    crossAxisSpacing: 8.0,
                    childAspectRatio: width > 1400 ? 1.2 : 1.0,
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
    return Container(
      constraints: const BoxConstraints(maxWidth: 380),
      child: Card(
        child: StreamBuilder(
          stream: _serverTime.stream,
          builder: (context, now) {
            if (!now.hasData) {
              return Container();
            }
            Duration diff = widget.boss.spawnTime.difference(now.requireData);
            return Padding(
              padding: const EdgeInsets.all(8.0),
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
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: widget.boss.nameList
                        .map((e) => BossImageAvatar(name: e))
                        .toList(),
                  ),
                  Column(
                    children: [
                      Text(
                        widget.boss.names,
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                      Text(
                        diff.toString().replaceAll('-', '').split('.').first,
                        style: Theme.of(context)
                            .textTheme
                            .displayMedium
                            ?.copyWith(
                                color: diff.isNegative
                                    ? (diff.inMinutes == 0
                                        ? Colors.green
                                        : Colors.red)
                                    : Colors.blue),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
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
        //radius: 80.0,
        backgroundColor: Colors.transparent,
        minRadius: 60.0,
        foregroundImage: NetworkImage('${Api.worldBossPortrait}/$name.png',),
      ),
    );
  }
}
