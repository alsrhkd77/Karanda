import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:karanda/common/global_properties.dart';
import 'package:karanda/overlay/overlay_manager.dart';
import 'package:karanda/widgets/default_app_bar.dart';
import 'package:karanda/widgets/loading_indicator.dart';
import 'package:karanda/widgets/title_text.dart';

class OverlayPage extends StatefulWidget {
  const OverlayPage({super.key});

  @override
  State<OverlayPage> createState() => _OverlayPageState();
}

class _OverlayPageState extends State<OverlayPage> {
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
      appBar: const DefaultAppBar(),
      body: Column(
        children: [
          const ListTile(
            leading: Icon(FontAwesomeIcons.layerGroup),
            title: TitleText('오버레이 (Beta)', bold: true),
          ),
          Container(
            constraints: const BoxConstraints(
              maxWidth: 1520,
            ),
            child: StreamBuilder(
              stream: _overlayManager.overlayStatus,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const LoadingIndicator();
                }
                return Wrap(
                  spacing: 4.0,
                  runSpacing: 4.0,
                  children: [
                    _CustomTile(
                      title: "보스 알림",
                      value: snapshot.requireData["worldBoss"]!,
                      onChanged: (bool value) {
                        _overlayManager.setOverlayStatus(
                          key: "worldBoss",
                          value: value,
                        );
                      },
                      onTap: (){
                        _overlayManager.setOverlayStatus(
                          key: "worldBoss",
                          value: !snapshot.requireData["worldBoss"]!,
                        );
                      },
                    ),
                    _CustomTile(
                      title: "보스 HP 인디케이터",
                      value: snapshot.requireData["bossHpScaleIndicator"]!,
                      onChanged: (bool value) {
                        _overlayManager.setOverlayStatus(
                          key: "bossHpScaleIndicator",
                          value: value,
                        );
                      },
                      onTap: (){
                        _overlayManager.setOverlayStatus(
                          key: "bossHpScaleIndicator",
                          value: !snapshot.requireData["bossHpScaleIndicator"]!,
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _overlayManager.sendData(
            method: "callback", data: "enable edit mode"),
        icon: const Icon(Icons.aspect_ratio),
        label: const Text("크기 및 위치 조정"),
      ),
    );
  }
}

class _CustomTile extends StatelessWidget {
  final String title;
  final bool value;
  final void Function(bool) onChanged;
  final void Function() onTap;

  const _CustomTile({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(4.0),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          constraints: const BoxConstraints(maxWidth: 400),
          child: ListTile(
            title: Text(title),
            trailing: Switch(
              value: value,
              onChanged: onChanged,
            ),
          ),
        ),
      ),
    );
  }
}
