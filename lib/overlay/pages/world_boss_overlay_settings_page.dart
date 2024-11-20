import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:karanda/common/global_properties.dart';
import 'package:karanda/overlay/overlay_manager.dart';
import 'package:karanda/widgets/default_app_bar.dart';
import 'package:karanda/widgets/loading_indicator.dart';
import 'package:karanda/widgets/title_text.dart';

class WorldBossOverlaySettingsPage extends StatefulWidget {
  const WorldBossOverlaySettingsPage({super.key});

  @override
  State<WorldBossOverlaySettingsPage> createState() =>
      _WorldBossOverlaySettingsPageState();
}

class _WorldBossOverlaySettingsPageState
    extends State<WorldBossOverlaySettingsPage> {
  final OverlayManager _overlayManager = OverlayManager();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((timeStamp) => _overlayManager.publish());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DefaultAppBar(
        icon: FontAwesomeIcons.layerGroup,
        title: '오버레이 (Beta)',
      ),
      body: StreamBuilder(
        stream: _overlayManager.overlayStatus,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const LoadingIndicator();
          }
          return SingleChildScrollView(
            child: Center(
              child: Container(
                margin: const EdgeInsets.all(12.0),
                constraints: BoxConstraints(
                  maxWidth: GlobalProperties.widthConstrains,
                ),
                child: Column(
                  children: [
                    const ListTile(
                      title: TitleText('월드 보스 오버레이', bold: true),
                    ),
                    const Divider(),
                    SwitchListTile(
                      title: const Text("오버레이 사용"),
                      value: snapshot.requireData["worldBoss"]!,
                      onChanged: (bool value) {
                        _overlayManager.setOverlayStatus(
                          key: "worldBoss",
                          value: value,
                        );
                      },
                    ),
                    SwitchListTile(
                      title: const Text("항상 보이기"),
                      value: snapshot.requireData["worldBossShowAlways"]!,
                      onChanged: (bool value) {
                        _overlayManager.setOverlayStatus(
                          key: "worldBossShowAlways",
                          value: value,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
