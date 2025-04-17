import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:karanda/enums/overlay_features.dart';
import 'package:karanda/ui/core/ui/loading_indicator.dart';
import 'package:karanda/ui/overlay_app/controllers/world_boss_overlay_controller.dart';
import 'package:karanda/ui/overlay_app/widgets/overlay_widget.dart';
import 'package:karanda/utils/extension/string_extension.dart';
import 'package:provider/provider.dart';

class WorldBossOverlayWidget extends StatelessWidget {
  final double height;

  const WorldBossOverlayWidget({super.key, required this.height});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => WorldBossOverlayController(
        key: OverlayFeatures.worldBoss,
        defaultRect: Rect.fromLTWH(2, height - 144, 440, 120),
        constraints: const BoxConstraints(minWidth: 200, minHeight: 60),
        service: context.read(),
        timeRepository: context.read(),
      ),
      child: Consumer(
        builder: (context, WorldBossOverlayController controller, child) {
          return OverlayWidget(
            resizable: controller.editMode,
            show: controller.show,
            feature: controller.key,
            boxController: controller.boxController,
            contentBuilder: (context, rect, flip) {
              if (controller.schedule == null) {
                return const LoadingIndicator();
              }
              return Center(
                child: ListTile(
                  leadingAndTrailingTextStyle: TextTheme.of(context).titleLarge,
                  title: GridView.count(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    crossAxisCount: 4,
                    childAspectRatio: 1.0,
                    crossAxisSpacing: 4.0,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: controller.schedule!.activatedBosses.map((boss) {
                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          CircleAvatar(
                            foregroundImage:
                                Image.network(boss.imagePath).image,
                            backgroundColor: Colors.transparent,
                          ),
                          _BossName(name: boss.name),
                        ],
                      );
                    }).toList(),
                  ),
                  trailing: _TimeRemaining(diff: controller.timeRemaining),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _BossName extends StatelessWidget {
  final String name;

  const _BossName({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Text(
        toBeginningOfSentenceCase(context.tr(name)).keepWord(),
        style: TextTheme.of(context).labelLarge?.copyWith(
              color: Colors.white.withAlpha(220),
            ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _TimeRemaining extends StatelessWidget {
  final Duration diff;

  const _TimeRemaining({super.key, required this.diff});

  @override
  Widget build(BuildContext context) {
    if (diff.isNegative) {
      return Text(
        context.tr("world boss.spawned"),
        style: const TextStyle(
          color: Colors.green,
          fontWeight: FontWeight.bold,
        ),
      );
    } else if (diff.inHours > 0) {
      return Text("${diff.inHours}h ${diff.inMinutes % 60}min");
    } else if (diff.inMinutes > 0) {
      return Text("${diff.inMinutes}min");
    }
    return Text("${diff.inSeconds}sec");
  }
}
