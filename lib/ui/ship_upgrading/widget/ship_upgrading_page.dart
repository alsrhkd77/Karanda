import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:karanda/model/ship_upgrading/ship_upgrading_data.dart';
import 'package:karanda/ui/core/ui/bdo_item_image.dart';
import 'package:karanda/ui/core/ui/dialog_kit.dart';
import 'package:karanda/ui/core/ui/karanda_app_bar.dart';
import 'package:karanda/ui/core/ui/loading_indicator.dart';
import 'package:karanda/ui/core/ui/page_base.dart';
import 'package:karanda/ui/ship_upgrading/controller/ship_upgrading_controller.dart';
import 'package:karanda/ui/ship_upgrading/widget/ship_upgrading_dialog.dart';
import 'package:karanda/ui/ship_upgrading/widget/ship_upgrading_parts_image.dart';
import 'package:karanda/ui/ship_upgrading/widget/ship_upgrading_settings_page.dart';
import 'package:karanda/ui/ship_upgrading/widget/ship_upgrading_table_row.dart';
import 'package:karanda/utils/extension/build_context_extension.dart';
import 'package:karanda/utils/extension/int_extension.dart';
import 'package:karanda/utils/extension/string_extension.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';

import '../../../model/ship_upgrading/ship_upgrading_child_data.dart';

class ShipUpgradingPage extends StatelessWidget {
  const ShipUpgradingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ShipUpgradingController(repository: context.read()),
      builder: (context, child) {
        return Scaffold(
          appBar: KarandaAppBar(
            icon: FontAwesomeIcons.ship,
            title: context.tr("shipUpgrading.shipUpgrading"),
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const ShipUpgradingSettingsPage(),
                  ));
                },
                icon: const Icon(Icons.construction),
                tooltip: context.tr("config"),
              ),
            ],
          ),
          body: Consumer(
            builder: (context, ShipUpgradingController controller, child) {
              if (controller.ship == null || controller.materials.isEmpty) {
                return const LoadingIndicator();
              }
              final width = MediaQuery.sizeOf(context).width;
              return PageBase(
                width: width,
                children: [
                  _Head(
                    width: width,
                    completionRate: controller.completionRate,
                    initialShipSelection: controller.ship,
                    ships: controller.ships.values.toList(),
                    onShipSelected: controller.selectShip,
                  ),
                  Card(
                    child: ListView(
                      padding: const EdgeInsets.all(8.0),
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemExtent: 64,
                      children: [
                        _TableHead(width: width),
                        ...controller.materials.values.map((item) {
                          return _TableItem(
                            item: item,
                            width: width,
                            textEditingController:
                                controller.textController[item.code],
                            stock: controller.stock[item.code] ?? 0,
                            need: controller.needs[item.code],
                            realNeed: controller.realNeeds[item.code],
                            parents: controller.selectedParts
                                .where((e) => item.parent.contains(e.code))
                                .toList(),
                            completedParts: controller.completedParts,
                            onChange: controller.updateUserStock,
                            increase: controller.increaseUserStock,
                            decrease: controller.decreaseUserStock,
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 64.0),
                ],
              );
            },
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              final func = context.read<ShipUpgradingController>().dailyQuest;
              final check = await DialogKit.of(context).doubleCheck(
                title: Text(context.tr("shipUpgrading.dailyQuest")),
                content: Text(
                  context.tr("shipUpgrading.dialog.dailyQuestHint"),
                ),
              );
              if (check ?? false) {
                func();
              }
            },
            icon: const Icon(Icons.add_task),
            label: Text(context.tr("shipUpgrading.dailyQuest")),
            focusNode: FocusNode(skipTraversal: true),
          ),
        );
      },
    );
  }
}

class _TableItem extends StatelessWidget {
  final double width;
  final ShipUpgradingData item;
  final TextEditingController? textEditingController;
  final int stock;
  final ShipUpgradingQuantityData? need;
  final ShipUpgradingQuantityData? realNeed;
  final List<ShipUpgradingData> parents;
  final List<int> completedParts;
  final void Function(int, int) onChange;
  final void Function(int) increase;
  final void Function(int) decrease;

  const _TableItem({
    super.key,
    required this.item,
    required this.width,
    this.textEditingController,
    required this.stock,
    this.need,
    this.realNeed,
    required this.parents,
    required this.completedParts,
    required this.onChange,
    required this.increase,
    required this.decrease,
  });

  @override
  Widget build(BuildContext context) {
    final coin = (max((realNeed?.count ?? 0) - stock, 0) * item.coin);
    final percent = (stock / (realNeed?.count ?? 1) * 100);
    MaterialColor color;
    switch (percent) {
      case < 25:
        color = Colors.red;
      case < 50:
        color = Colors.orange;
      case < 75:
        color = Colors.yellow;
      case < 100:
        color = Colors.green;
      default:
        color = Colors.blue;
    }
    return ShipUpgradingTableRow(
      width: width,
      onTap: () {
        final controller = context.read<ShipUpgradingController>();
        ShipUpgradingDialog.of(context).itemDialog(
          item: item,
          provider: controller,
        );
      },
      item: BdoItemImage(code: item.code.toString()),
      itemName: Text(context
          .itemName(item.code.toString())
          .keepWord()
          .replaceAll("(", "\n(")),
      stock: TextFormField(
        controller: textEditingController,
        keyboardType: const TextInputType.numberWithOptions(),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^(\d{0,4})')),
        ],
        textAlignVertical: TextAlignVertical.top,
        decoration: width < 400
            ? null
            : InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 6.0),
                prefix: InkWell(
                  onTap: () => decrease(item.code),
                  focusNode: FocusNode(skipTraversal: true),
                  borderRadius: BorderRadius.circular(25.0),
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Icon(Icons.remove, size: 16),
                  ),
                ),
                suffix: InkWell(
                  onTap: () => increase(item.code),
                  focusNode: FocusNode(skipTraversal: true),
                  borderRadius: BorderRadius.circular(25.0),
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Icon(Icons.add, size: 16),
                  ),
                ),
              ),
        textAlign: TextAlign.center,
        onChanged: (value) {
          final parsed = int.tryParse(value) ?? 0;
          onChange(item.code, parsed);
        },
      ),
      needed: Text(realNeed?.count.format() ?? "-"),
      completion: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Text(
              "${percent.toStringAsFixed(2)}%",
              style: TextStyle(color: color),
            ),
          ),
          LinearPercentIndicator(
            animation: true,
            animationDuration: 500,
            percent: min(percent / 100, 1.0),
            barRadius: const Radius.circular(4.0),
            progressColor: color,
            animateFromLastPercent: true,
          ),
        ],
      ),
      totalCost: Tooltip(
        message: context.tr(
          "shipUpgrading.perUnit",
          args: [item.coin.format()],
        ),
        child: Text(coin.format()),
      ),
      components: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: parents.map(
          (parent) {
            return ShipUpgradingPartsImage(
              code: parent.code.toString(),
              completed: completedParts.contains(parent.code),
            );
          },
        ).toList(),
      ),
    );
  }
}

class _TableHead extends StatelessWidget {
  final double width;

  const _TableHead({super.key, required this.width});

  @override
  Widget build(BuildContext context) {
    final style = TextTheme.of(context)
        .titleMedium
        ?.copyWith(fontWeight: FontWeight.bold);
    return ShipUpgradingTableRow(
      width: width,
      item: Text(
        context.tr("shipUpgrading.items").keepWord(),
        style: style,
        textAlign: TextAlign.center,
      ),
      stock: Text(context.tr("shipUpgrading.stocks"), style: style),
      needed: Text(context.tr("shipUpgrading.needed").keepWord(), style: style),
      completion: Text(context.tr("shipUpgrading.completion"), style: style),
      totalCost: Text(
        context.tr("shipUpgrading.totalCost").keepWord(),
        style: style,
        textAlign: TextAlign.center,
      ),
      components: Text(context.tr("shipUpgrading.components"), style: style),
    );
  }
}

class _Head extends StatelessWidget {
  final double width;
  final double completionRate;
  final ShipUpgradingData? initialShipSelection;
  final List<ShipUpgradingData> ships;
  final void Function(ShipUpgradingData?) onShipSelected;

  const _Head({
    super.key,
    required this.width,
    required this.completionRate,
    required this.initialShipSelection,
    required this.ships,
    required this.onShipSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (width < 800) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            trailing: _SelectShip(
              initialSelection: initialShipSelection,
              data: ships,
              onSelected: onShipSelected,
            ),
          ),
          ListTile(title: _TotalPercent(value: completionRate)),
        ],
      );
    }
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
      title: _TotalPercent(value: completionRate),
      trailing: _SelectShip(
        initialSelection: initialShipSelection,
        data: ships,
        onSelected: onShipSelected,
      ),
    );
  }
}

class _TotalPercent extends StatelessWidget {
  final double value;

  const _TotalPercent({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    MaterialColor color;
    switch (value) {
      case < 0.25:
        color = Colors.red;
      case < 0.5:
        color = Colors.orange;
      case < 0.75:
        color = Colors.yellow;
      case < 1.0:
        color = Colors.green;
      default:
        color = Colors.blue;
    }
    return LinearPercentIndicator(
      animation: true,
      animationDuration: 500,
      percent: min(value, 1.0),
      barRadius: const Radius.circular(4.0),
      progressColor: color,
      animateFromLastPercent: true,
      trailing: Text("${(value * 100).toStringAsFixed(2)}%"),
    );
  }
}

class _SelectShip extends StatelessWidget {
  final ShipUpgradingData? initialSelection;
  final List<ShipUpgradingData> data;
  final void Function(ShipUpgradingData?) onSelected;

  const _SelectShip({
    super.key,
    required this.initialSelection,
    required this.data,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<ShipUpgradingData>(
      initialSelection: initialSelection,
      dropdownMenuEntries:
          data.map<DropdownMenuEntry<ShipUpgradingData>>((item) {
        return DropdownMenuEntry(
          value: item,
          label: context
              .itemName(item.code.toString())
              .split(": ")
              .last
              .replaceAll(" -", ":"),
        );
      }).toList(),
      onSelected: onSelected,
    );
  }
}
