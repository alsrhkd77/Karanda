import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:karanda/model/ship_upgrading/ship_upgrading_child_data.dart';
import 'package:karanda/model/ship_upgrading/ship_upgrading_data.dart';
import 'package:karanda/ui/core/ui/bdo_item_image.dart';
import 'package:karanda/ui/core/ui/karanda_app_bar.dart';
import 'package:karanda/ui/core/ui/loading_indicator.dart';
import 'package:karanda/ui/core/ui/page_base.dart';
import 'package:karanda/ui/core/ui/section.dart';
import 'package:karanda/ui/ship_upgrading/controller/ship_upgrading_settings_controller.dart';
import 'package:karanda/utils/extension/build_context_extension.dart';
import 'package:provider/provider.dart';

class ShipUpgradingSettingsPage extends StatelessWidget {
  const ShipUpgradingSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ShipUpgradingSettingsController(
        repository: context.read(),
      )..loadData(),
      child: Scaffold(
        appBar: KarandaAppBar(
          icon: FontAwesomeIcons.ship,
          title: context.tr("shipUpgrading.shipUpgrading"),
        ),
        body: Consumer(
          builder:
              (context, ShipUpgradingSettingsController controller, child) {
            if (controller.settings == null) {
              return const LoadingIndicator();
            }
            return PageBase(
              children: [
                Section(
                  title: context.tr("shipUpgrading.completed"),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      children: controller.parts.map((item) {
                        return _PartsTile(
                          data: item,
                          value: controller.stock[item.code] == 1,
                          onChanged: controller.selectParts,
                        );
                      }).toList(),
                    ),
                  ),
                ),
                Section(
                  title: context.tr("shipUpgrading.dailyQuest"),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      children: controller.settings!.dailyQuest.map((item) {
                        return _DailyQuestTile(
                          data: item,
                          textEditingController:
                              controller.textController[item.code],
                          onChanged: controller.updateDailyQuest,
                        );
                      }).toList(),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 24.0,
                  ),
                  child: ElevatedButton(
                    onPressed: controller.resetUserStock,
                    child: Text(context.tr("shipUpgrading.resetUserStock")),
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

class _PartsTile extends StatelessWidget {
  final ShipUpgradingData data;
  final bool value;
  final void Function(int) onChanged;

  const _PartsTile({
    super.key,
    required this.data,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: BdoItemImage(code: data.code.toString(), size: 38),
      title: Text(context.itemName(data.code.toString())),
      trailing: Checkbox(
        value: value,
        onChanged: (selected) => onChanged(data.code),
      ),
    );
  }
}

class _DailyQuestTile extends StatelessWidget {
  final ShipUpgradingQuantityData data;
  final TextEditingController? textEditingController;
  final void Function(int, int) onChanged;

  const _DailyQuestTile({
    super.key,
    required this.data,
    this.textEditingController,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: BdoItemImage(code: data.code.toString(), size: 38),
      title: Text(context.itemName(data.code.toString())),
      trailing: SizedBox(
        width: 92.0,
        height: 36.0,
        child: TextFormField(
          controller: textEditingController,
          keyboardType: const TextInputType.numberWithOptions(),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^(\d{0,3})')),
          ],
          textAlign: TextAlign.center,
          onChanged: (value) {
            final parsed = int.tryParse(value) ?? 0;
            onChanged(data.code, parsed);
          },
        ),
      ),
    );
  }
}
