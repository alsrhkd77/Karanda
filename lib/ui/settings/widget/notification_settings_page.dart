import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:karanda/enums/recruitment_category.dart';
import 'package:karanda/model/party_finder_settings.dart';
import 'package:karanda/model/world_boss_settings.dart';
import 'package:karanda/ui/core/theme/features_icon.dart';
import 'package:karanda/ui/core/ui/karanda_app_bar.dart';
import 'package:karanda/ui/core/ui/loading_indicator.dart';
import 'package:karanda/ui/core/ui/page_base.dart';
import 'package:karanda/ui/core/ui/section.dart';
import 'package:karanda/ui/settings/controller/notification_settings_controller.dart';
import 'package:provider/provider.dart';

class NotificationSettingsPage extends StatelessWidget {
  const NotificationSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => NotificationSettingsController(
        worldBossService: context.read(),
        partyFinderRepository: context.read(),
      ),
      child: Scaffold(
        appBar: KarandaAppBar(
          icon: Icons.notifications,
          title: context.tr("settings.notifications"),
        ),
        body: Consumer(
          builder: (context, NotificationSettingsController controller, child) {
            if (controller.worldBossSettings == null ||
                controller.partyFinderSettings == null) {
              return const LoadingIndicator();
            }
            final WorldBossSettings worldBossSettings =
                controller.worldBossSettings!;
            final PartyFinderSettings partyFinderSettings =
                controller.partyFinderSettings!;
            return PageBase(
              children: [
                Section(
                  title: context.tr("world boss.world boss"),
                  icon: FeaturesIcon.worldBoss,
                  child: Column(
                    children: [
                      SwitchListTile(
                        value: controller.worldBossSettings!.notify,
                        onChanged: controller.setWorldBossNotify,
                        title:
                            Text(context.tr("settings.activate notifications")),
                      ),
                      ExpansionTile(
                        title: Text(context.tr("world boss.notification time")),
                        children: [
                          ...worldBossSettings.notificationTime.map((time) {
                            return _WorldBossNotificationTimeTile(time: time);
                          }),
                          worldBossSettings.notificationTime.length < 5
                              ? ListTile(
                                  onTap: () =>
                                      controller.addNotificationTime(context),
                                  leading: const Icon(Icons.add),
                                  title: Text(context.tr("world boss.add")),
                                )
                              : const SizedBox(),
                        ],
                      ),
                    ],
                  ),
                ),
                Section(
                  title: context.tr("partyFinder.partyFinder"),
                  icon: FeaturesIcon.partyFinder,
                  child: Column(
                    children: [
                      SwitchListTile(
                        value: partyFinderSettings.notify,
                        onChanged: controller.setPartyFinderNotify,
                        title:
                            Text(context.tr("settings.activate notifications")),
                      ),
                      ExpansionTile(
                        title: Text(
                            context.tr("partyFinder.settings.excluded")),
                        children: [
                          _PartyFinderRecruitmentCategoryTile(
                            category: RecruitmentCategory.partyAndPlatoon,
                            excluded: partyFinderSettings.excludedCategory
                                .contains(RecruitmentCategory.partyAndPlatoon),
                          ),
                          _PartyFinderRecruitmentCategoryTile(
                            category: RecruitmentCategory.guildBossRaid,
                            excluded: partyFinderSettings.excludedCategory
                                .contains(RecruitmentCategory.guildBossRaid),
                          ),
                          _PartyFinderRecruitmentCategoryTile(
                            category: RecruitmentCategory.guildWar,
                            excluded: partyFinderSettings.excludedCategory
                                .contains(RecruitmentCategory.guildWar),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _WorldBossNotificationTimeTile extends StatelessWidget {
  final int time;

  const _WorldBossNotificationTimeTile({
    super.key,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(context.tr(
        "world boss.minutes before spawn",
        args: [time.toString()],
      )),
      trailing: IconButton(
        onPressed: () => context
            .read<NotificationSettingsController>()
            .removeNotificationTime(time),
        icon: const Icon(Icons.close),
        color: Colors.red,
        tooltip: context.tr("world boss.remove"),
      ),
    );
  }
}

class _PartyFinderRecruitmentCategoryTile extends StatelessWidget {
  final RecruitmentCategory category;
  final bool excluded;

  const _PartyFinderRecruitmentCategoryTile({
    super.key,
    required this.category,
    required this.excluded,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(context.tr("partyFinder.category.${category.name}")),
      trailing: Checkbox(
        value: excluded,
        onChanged: (value) => context
            .read<NotificationSettingsController>()
            .updatePartyFinderExcludedCategory(category),
      ),
    );
  }
}
