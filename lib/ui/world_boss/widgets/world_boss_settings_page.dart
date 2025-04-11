import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:karanda/model/world_boss.dart';
import 'package:karanda/ui/core/ui/karanda_app_bar.dart';
import 'package:karanda/ui/core/ui/page_base.dart';
import 'package:karanda/ui/world_boss/controllers/world_boss_settings_controller.dart';
import 'package:provider/provider.dart';

class WorldBossSettingsPage extends StatelessWidget {
  const WorldBossSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => WorldBossSettingsController(
        worldBossService: context.read(),
      ),
      child: Scaffold(
        appBar: KarandaAppBar(
          icon: FontAwesomeIcons.dragon,
          title: context.tr("world boss.world boss"),
        ),
        body: Consumer(
          builder: (context, WorldBossSettingsController controller, child) {
            return PageBase(children: [
              SwitchListTile(
                value: controller.settings.notify,
                onChanged: controller.setNotify,
                title: Text(context.tr("world boss.notify")),
              ),
              ExpansionTile(
                title: Text(context.tr("world boss.notification time")),
                children: [
                  ...controller.settings.notificationTime.map((item) {
                    return _NotificationTimeTile(time: item);
                  }),
                  controller.settings.notificationTime.length < 5
                      ? ListTile(
                          onTap: () => controller.addNotificationTime(context),
                          leading: const Icon(Icons.add),
                          title: Text(context.tr("world boss.add")),
                        )
                      : const SizedBox(),
                ],
              ),
              ExpansionTile(
                title: Text(context.tr("world boss.exclude")),
                children: controller.fixedBosses.map((item) {
                  return _ExcludedBossTile(
                    data: item,
                    excluded: controller.settings.excluded.contains(item.name),
                  );
                }).toList(),
              ),
            ]);
          },
        ),
      ),
    );
  }
}

class _NotificationTimeTile extends StatelessWidget {
  final int time;

  const _NotificationTimeTile({super.key, required this.time});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(context.tr(
        "world boss.minutes before spawn",
        args: [time.toString()],
      )),
      trailing: IconButton(
        onPressed: () {
          context
              .read<WorldBossSettingsController>()
              .removeNotificationTime(time);
        },
        icon: const Icon(Icons.close),
        color: Colors.red,
        tooltip: context.tr("world boss.remove"),
      ),
    );
  }
}

class _ExcludedBossTile extends StatelessWidget {
  final WorldBoss data;
  final bool excluded;

  const _ExcludedBossTile({
    super.key,
    required this.data,
    required this.excluded,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        foregroundImage: Image.network(data.imagePath).image,
        backgroundColor: Colors.transparent,
      ),
      title: Text(toBeginningOfSentenceCase(context.tr(data.name))),
      trailing: Checkbox(
        value: excluded,
        onChanged: (value) => context
            .read<WorldBossSettingsController>()
            .updateExcludedBoss(data.name),
      ),
    );
  }
}
