import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:karanda/enums/overlay_features.dart';
import 'package:karanda/ui/core/theme/dimes.dart';
import 'package:karanda/ui/core/ui/karanda_app_bar.dart';
import 'package:karanda/ui/core/ui/loading_indicator.dart';
import 'package:karanda/ui/overlay/controllers/overlay_controller.dart';
import 'package:karanda/ui/overlay/widgets/overlay_settings_page.dart';
import 'package:provider/provider.dart';

class OverlayPage extends StatefulWidget {
  const OverlayPage({super.key});

  @override
  State<OverlayPage> createState() => _OverlayPageState();
}

class _OverlayPageState extends State<OverlayPage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => OverlayController(overlayRepository: context.read()),
      child: Scaffold(
        appBar: KarandaAppBar(
          icon: FontAwesomeIcons.layerGroup,
          title: context.tr("overlay.overlay"),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const OverlaySettingsPage(),
                ));
              },
              icon: const Icon(Icons.construction),
              tooltip: context.tr("config"),
            ),
          ],
        ),
        body: Consumer(
          builder: (context, OverlayController controller, child) {
            if (controller.overlaySettings == null) {
              return const LoadingIndicator();
            }
            final width = MediaQuery.sizeOf(context).width;
            final contentsWidth = min(Dimens.pageMaxWidth, width);
            final count = max((contentsWidth / 400).floor(), 1);
            final activated = controller.overlaySettings!.activatedFeatures;
            return GridView.count(
              crossAxisCount: count,
              childAspectRatio: (contentsWidth / count) / 68,
              padding: Dimens.constrainedPagePadding(width),
              children: [
                _Tile(
                  feature: OverlayFeatures.notification,
                  isActivated: activated.contains(OverlayFeatures.notification),
                ),
                _Tile(
                  feature: OverlayFeatures.worldBoss,
                  isActivated: activated.contains(OverlayFeatures.worldBoss),
                ),
                _Tile(
                  feature: OverlayFeatures.clock,
                  isActivated: activated.contains(OverlayFeatures.clock),
                ),
                _Tile(
                  feature: OverlayFeatures.bossHpScaleIndicator,
                  isActivated:
                      activated.contains(OverlayFeatures.bossHpScaleIndicator),
                ),
              ],
            );
          },
        ),
        floatingActionButton: const _Fab(),
      ),
    );
  }
}

class _Fab extends StatelessWidget {
  const _Fab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, OverlayController controller, child) {
        if (controller.overlaySettings == null) {
          return Container();
        }
        return FloatingActionButton.extended(
          onPressed: () => controller.switchEditMode(),
          icon: const Icon(Icons.aspect_ratio),
          label: Text(context.tr("overlay.resize and position")),
        );
      },
    );
  }
}

class _Tile extends StatelessWidget {
  final OverlayFeatures feature;
  final bool isActivated;

  const _Tile({
    super.key,
    required this.feature,
    required this.isActivated,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Center(
        child: SwitchListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 2,
          ),
          title: Text(context.tr("overlay.${feature.name}")),
          value: isActivated,
          onChanged: (status) {
            context.read<OverlayController>().switchActivation(feature, status);
          },
        ),
      ),
    );
  }
}
