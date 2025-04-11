import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:karanda/common/date_time_extension.dart';
import 'package:karanda/model/world_boss_schedule.dart';
import 'package:karanda/repository/time_repository.dart';
import 'package:karanda/ui/core/theme/dimes.dart';
import 'package:karanda/ui/core/ui/karanda_app_bar.dart';
import 'package:karanda/ui/core/ui/loading_indicator.dart';
import 'package:karanda/ui/world_boss/controllers/world_boss_controller.dart';
import 'package:karanda/ui/world_boss/widgets/world_boss_settings_page.dart';
import 'package:karanda/utils/extension/duration_extension.dart';
import 'package:karanda/utils/extension/string_extension.dart';
import 'package:provider/provider.dart';

class WorldBossPage extends StatelessWidget {
  const WorldBossPage({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final contentsWidth = min(Dimens.pageMaxWidth, width);
    final count = max((contentsWidth / 400).floor(), 1);
    return ChangeNotifierProvider(
      create: (context) => WorldBossController(
        worldBossService: context.read(),
      ),
      child: Scaffold(
        appBar: KarandaAppBar(
          icon: FontAwesomeIcons.dragon,
          title: context.tr("world boss.world boss"),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const WorldBossSettingsPage(),
                ));
              },
              icon: const Icon(Icons.construction),
              tooltip: context.tr("config"),
            ),
          ],
        ),
        body: Consumer(
          builder: (context, WorldBossController controller, child) {
            if (controller.schedule == null) {
              return const LoadingIndicator();
            }
            return GridView.count(
              crossAxisCount: count,
              childAspectRatio: 0.55,
              padding: Dimens.constrainedPagePadding(width),
              children: [
                _Card(data: controller.schedule!.previous),
                _Card(data: controller.schedule!.current),
                _Card(data: controller.schedule!.next),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final WorldBossSchedule data;

  const _Card({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            //출현 시간
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                data.spawnTime.toLocal().format("HH:mm"),
                style: Theme.of(context)
                    .textTheme
                    .displayMedium
                    ?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 3),
              ),
            ),
            //초상화 그리드
            AspectRatio(
              aspectRatio: 1.0,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 16.0,
                ),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: min(data.activatedBosses.length, 2),
                  childAspectRatio: 1.0,
                  children: data.activatedBosses.map(
                    (boss) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          foregroundImage: Image.network(boss.imagePath).image,
                        ),
                      );
                    },
                  ).toList(),
                ),
              ),
            ),
            // 보스 이름
            _BossNames(
              names: data.activatedBosses.map((boss) => boss.name).toList(),
            ),
            // 남은 시간
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _TimeRemaining(spawnTime: data.spawnTime),
            ),
          ],
        ),
      ),
    );
  }
}

class _BossNames extends StatelessWidget {
  final List<String> names;

  const _BossNames({super.key, required this.names});

  @override
  Widget build(BuildContext context) {
    final txt = names
        .map((name) => toBeginningOfSentenceCase(context.tr(name)))
        .join(", ")
        .keepWord();
    return Text(
      txt,
      softWrap: true,
      style: Theme.of(context).textTheme.headlineLarge,
      textAlign: TextAlign.center,
      maxLines: 2,
    );
  }
}

class _TimeRemaining extends StatelessWidget {
  final DateTime spawnTime;

  const _TimeRemaining({super.key, required this.spawnTime});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: context.read<TimeRepository>().utcTimeStream,
      builder: (context, now) {
        if (!now.hasData) {
          return Text("", style: Theme.of(context).textTheme.displayMedium);
        }
        final diff = spawnTime.difference(now.requireData);
        return Text(
          diff.isNegative && diff.inMinutes == 0
              ? context.tr("world boss.spawned")
              : diff.splitString().replaceAll('-', '').padLeft(8, '0'),
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
              color: diff.isNegative
                  ? (diff.inMinutes == 0 ? Colors.green : Colors.red)
                  : Colors.blue),
        );
      },
    );
  }
}
