import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:karanda/common/global_properties.dart';
import 'package:karanda/widgets/default_app_bar.dart';
import 'package:karanda/widgets/download_desktop_snack_bar.dart';
import 'package:karanda/widgets/loading_indicator.dart';
import 'package:karanda/widgets/title_text.dart';
import 'package:karanda/world_boss/world_boss_controller.dart';

class WorldBossSettingsPage extends StatefulWidget {
  final WorldBossController controller;

  const WorldBossSettingsPage({super.key, required this.controller});

  @override
  State<WorldBossSettingsPage> createState() => _WorldBossSettingsPageState();
}

class _WorldBossSettingsPageState extends State<WorldBossSettingsPage> {
  late WorldBossController controller;

  @override
  void initState() {
    super.initState();
    controller = widget.controller;
    WidgetsBinding.instance
        .addPostFrameCallback((timeStamp) => controller.subscribe());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DefaultAppBar(),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(12.0),
            constraints:
                BoxConstraints(maxWidth: GlobalProperties.widthConstrains),
            child: StreamBuilder(
              stream: controller.settings,
              builder: (context, settings) {
                if (!settings.hasData) {
                  return const LoadingIndicator();
                }
                return Column(
                  children: [
                    const ListTile(
                      title: TitleText('월드 보스 설정', bold: true),
                    ),
                    const Divider(),
                    ListTile(
                      title: const Text('알림음 켜기'),
                      subtitle: const Text('웹에서는 정상적으로 동작하지 않을 수 있습니다'),
                      trailing: Switch(
                        value: settings.requireData.useAlarm,
                        onChanged: (value) {
                          controller.updateUseAlarm(value);
                        },
                      ),
                    ),
                    ListTile(
                      title: const Text('오버레이 켜기'),
                      trailing: Switch(
                        value: settings.requireData.useOverlay,
                        onChanged: (value) {
                          if (kIsWeb) {
                            DownloadDesktopSnackBar(context);
                          } else {
                            controller.updateUseOverlay(value);
                          }
                        },
                      ),
                    ),
                    ExpansionTile(
                      //initiallyExpanded: true,
                      title: const Text('알림 시간'),
                      expandedAlignment: Alignment.centerLeft,
                      childrenPadding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 4.0),
                      children: List.generate(settings.requireData.alarm.length,
                          (index) {
                        return _Alarm(
                          index: index,
                          onChanged: (int value) {
                            controller.updateAlarm(index, value);
                          },
                          initialValue: settings.requireData.alarm[
                              settings.requireData.alarm.length - index - 1],
                        );
                      }),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _Alarm extends StatelessWidget {
  final int index;
  final int initialValue;
  final Function(int) onChanged;

  const _Alarm({
    super.key,
    required this.onChanged,
    required this.initialValue,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 192.0,
      child: ListTile(
        leading: Text(
          '${index + 1}.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        title: TextFormField(
          initialValue: initialValue.toString(),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^(\d{0,2})')),
          ],
          decoration: InputDecoration(
            suffixText: '분',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: Colors.blue),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12.0),
          ),
          textAlign: TextAlign.center,
          onChanged: (String? value) {
            if (value != null && value.isNotEmpty) {
              int parsed = int.tryParse(value) ?? 0;
              if (parsed > 0) onChanged(parsed);
            }
          },
        ),
      ),
    );
  }
}
