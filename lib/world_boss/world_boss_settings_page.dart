import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:karanda/widgets/custom_base.dart';
import 'package:karanda/widgets/default_app_bar.dart';
import 'package:karanda/widgets/loading_indicator.dart';
import 'package:karanda/world_boss/BossImageAvatar.dart';
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
      appBar: const DefaultAppBar(
        icon: Icons.construction,
        title: '월드 보스 설정',
      ),
      body: StreamBuilder(
        stream: controller.settings,
        builder: (context, settings) {
          if (!settings.hasData) {
            return const LoadingIndicator();
          }
          return CustomBase(
            children: [
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
              ExpansionTile(
                //initiallyExpanded: true,
                title: const Text('알림 시간'),
                expandedAlignment: Alignment.centerLeft,
                childrenPadding: const EdgeInsets.symmetric(
                    horizontal: 8.0, vertical: 4.0),
                children: List.generate(
                  settings.requireData.alarm.length + 1,
                      (index) {
                    if (index == settings.requireData.alarm.length &&
                        settings.requireData.alarm.length < 10) {
                      return _AddAlarm(
                        add: () {
                          showDialog(
                            context: context,
                            builder: (_) => _AddAlarmDialog(
                              add: (minute) =>
                                  controller.addAlarm(minute),
                            ),
                          );
                        },
                      );
                    }
                    return _Alarm(
                      index: index,
                      onChanged: (int value) {
                        controller.updateAlarm(index, value);
                      },
                      initialValue: settings.requireData.alarm[index],
                      remove: () {
                        controller.removeAlarm(index);
                      },
                    );
                  },
                ),
              ),
              ExpansionTile(
                title: const Text("제외할 보스"),
                childrenPadding: const EdgeInsets.symmetric(
                    horizontal: 8.0, vertical: 4.0),
                children: controller.fixedBosses.keys.map((e) {
                  return CheckboxListTile(
                    title: Text(e).tr(),
                    secondary: BossImageAvatar(name: e),
                    value: settings.requireData.excludedBoss.contains(e),
                    onChanged: (value) {
                      if (value != null) {
                        controller.excludeBoss(e);
                      }
                    },
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Alarm extends StatelessWidget {
  final int index;
  final int initialValue;
  final Function(int) onChanged;
  final Function remove;

  const _Alarm({
    super.key,
    required this.onChanged,
    required this.initialValue,
    required this.index,
    required this.remove,
  });

  @override
  Widget build(BuildContext context) {
    TextEditingController controller = TextEditingController();
    controller.text = initialValue.toString();
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 240,
      ),
      child: ListTile(
        leading: Text(
          '${index + 1}.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        title: Center(
          child: Text('$initialValue분'),
        ),
        trailing: IconButton(
          onPressed: () => remove(),
          icon: const Icon(Icons.close),
          color: Colors.red,
        ),
      ),
    );
  }
}

class _AddAlarm extends StatelessWidget {
  final Function add;

  const _AddAlarm({super.key, required this.add});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => add(),
        child: Container(
          width: Size.infinite.width,
          height: 42.0,
          constraints: const BoxConstraints(
            maxWidth: 240,
          ),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class _AddAlarmDialog extends StatefulWidget {
  final bool Function(int) add;

  const _AddAlarmDialog({super.key, required this.add});

  @override
  State<_AddAlarmDialog> createState() => _AddAlarmDialogState();
}

class _AddAlarmDialogState extends State<_AddAlarmDialog> {
  final TextEditingController textEditingController = TextEditingController();
  int minute = 1;
  String infoText = '';

  @override
  void initState() {
    textEditingController.text = minute.toString();
    super.initState();
  }

  void increase() {
    setState(() {
      minute += 1;
      if (minute >= 100) minute = 99;
      textEditingController.text = minute.toString();
    });
  }

  void decrease() {
    setState(() {
      minute -= 1;
      if (minute <= 0) minute = 1;
      textEditingController.text = minute.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('알림 추가하기'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              //mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(onPressed: decrease, icon: const Icon(Icons.remove)),
                Container(
                  constraints: const BoxConstraints(maxWidth: 120),
                  child: TextFormField(
                    controller: textEditingController,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^(\d{0,2})')),
                    ],
                    decoration: InputDecoration(
                      suffixText: '분',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: const BorderSide(color: Colors.blue),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12.0),
                    ),
                    textAlign: TextAlign.center,
                    onChanged: (String? value) {
                      if (value != null && value.isNotEmpty) {
                        int parsed = int.tryParse(value) ?? 0;
                        if (parsed > 0) minute = parsed;
                      }
                    },
                  ),
                ),
                IconButton(onPressed: increase, icon: const Icon(Icons.add))
              ],
            ),
          ),
          Text(
            infoText,
            style: const TextStyle(color: Colors.red),
          )
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            context.pop();
          },
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: () {
            bool result = widget.add(minute);
            if (result) {
              context.pop();
            } else {
              setState(() {
                infoText = '이미 설정되어 있습니다!';
              });
            }
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue, foregroundColor: Colors.white),
          child: const Text('설정'),
        )
      ],
      actionsAlignment: MainAxisAlignment.spaceBetween,
    );
  }
}
