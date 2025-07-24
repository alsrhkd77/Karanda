import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:karanda/model/ship_upgrading/ship_upgrading_data.dart';
import 'package:karanda/ui/core/ui/bdo_item_image.dart';
import 'package:karanda/ui/core/ui/karanda_app_bar.dart';
import 'package:karanda/ui/core/ui/loading_indicator.dart';
import 'package:karanda/ui/core/ui/page_base.dart';
import 'package:karanda/ui/ship_upgrading/controller/ship_upgrading_controller.dart';
import 'package:karanda/ui/ship_upgrading/widget/ship_upgrading_settings_page.dart';
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
    final width = MediaQuery.sizeOf(context).width;
    return ChangeNotifierProvider(
      create: (context) => ShipUpgradingController(
        repository: context.read(),
      )..loadData(),
      child: Scaffold(
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
            if (controller.ship == null) {
              return const LoadingIndicator();
            }
            return PageBase(
              width: width,
              children: [
                Row(
                  children: [
                    const Spacer(),
                    DropdownMenu<ShipUpgradingData>(
                      initialSelection: controller.ship,
                      dropdownMenuEntries: controller.ships.values
                          .map<DropdownMenuEntry<ShipUpgradingData>>((item) {
                        return DropdownMenuEntry(
                          value: item,
                          label: context
                              .itemName(item.code.toString())
                              .split(": ")
                              .last
                              .replaceAll(" -", ":"),
                        );
                      }).toList(),
                      onSelected: controller.selectShip,
                    ),
                  ],
                ),
                _TotalPercent(value: controller.completionRate),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        const _Head(),
                        ...controller.materials.values.map((item) {
                          return _ItemTile(
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
                ),
                const SizedBox(height: 40.0),
              ],
            );
          },
        ),
        floatingActionButton: _FAB(),
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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: LinearPercentIndicator(
        animation: true,
        animationDuration: 500,
        percent: min(value, 1.0),
        barRadius: const Radius.circular(4.0),
        progressColor: color,
        animateFromLastPercent: true,
        trailing: Text("${(value * 100).toStringAsFixed(2)}%"),
      ),
    );
  }
}

class _ItemTile extends StatelessWidget {
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

  const _ItemTile({
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
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () {
        final controller = context.read<ShipUpgradingController>();
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (context) => _ItemDialog(
            item: item,
            provider: controller,
          ),
        );
      },
      focusNode: FocusNode(skipTraversal: true),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Center(child: BdoItemImage(code: item.code.toString())),
            ),
            Expanded(
              flex: 4,
              child: Text(context.itemName(item.code.toString()).keepWord()),
            ),
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: textEditingController,
                keyboardType: const TextInputType.numberWithOptions(),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^(\d{0,4})')),
                ],
                textAlign: TextAlign.center,
                onChanged: (value) {
                  final parsed = int.tryParse(value) ?? 0;
                  onChange(item.code, parsed);
                },
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () => decrease(item.code),
                      icon: const Icon(Icons.remove_circle_outline),
                      focusNode: FocusNode(skipTraversal: true),
                    ),
                    IconButton(
                      onPressed: () => increase(item.code),
                      icon: const Icon(Icons.add_circle_outline),
                      focusNode: FocusNode(skipTraversal: true),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Center(child: Text(realNeed?.count.format() ?? "-")),
            ),
            Expanded(
              flex: 2,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(
                      "${percent.toStringAsFixed(2)}%",
                      style: TextStyle(color: color),
                    ),
                  ),
                  LinearPercentIndicator(
                    animation: true,
                    animationDuration: 500,
                    percent: min(percent / 100, 1.0),
                    backgroundColor: Colors.grey,
                    barRadius: const Radius.circular(4.0),
                    progressColor: color,
                    animateFromLastPercent: true,
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Center(
                child: Tooltip(
                  message: context.tr(
                    "shipUpgrading.perUnit",
                    args: [item.coin.format()],
                  ),
                  child: Text(coin.format()),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: parents.map(
                  (parent) {
                    return _PartsImage(
                      code: parent.code.toString(),
                      completed: completedParts.contains(parent.code),
                    );
                  },
                ).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Head extends StatelessWidget {
  const _Head({super.key});

  @override
  Widget build(BuildContext context) {
    final style = TextTheme.of(context)
        .titleMedium
        ?.copyWith(fontWeight: FontWeight.bold);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Center(
              child: Text(context.tr("shipUpgrading.items"), style: style),
            ),
          ),
          Expanded(
            flex: 4,
            child: Center(
              child: Text(context.tr("shipUpgrading.stocks"), style: style),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text(context.tr("shipUpgrading.needed"), style: style),
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: Text(context.tr("shipUpgrading.completion"), style: style),
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: Text(
                context.tr("shipUpgrading.totalCost"),
                style: style,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: Text(context.tr("shipUpgrading.components"), style: style),
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemDialog extends StatelessWidget {
  final ShipUpgradingData item;
  final ShipUpgradingController provider;

  const _ItemDialog({super.key, required this.item, required this.provider});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: provider,
      builder: (context, child) {
        return Consumer(
          builder: (context, ShipUpgradingController controller, child) {
            final stock = controller.stock[item.code] ?? 0;
            final realNeed = controller.realNeeds[item.code];
            final coin = (max((realNeed?.count ?? 0) - stock, 0) * item.coin);
            final percent = (stock / (realNeed?.count ?? 1) * 100);
            final List<ShipUpgradingData> parents = controller.selectedParts
                .where((e) => item.parent.contains(e.code))
                .toList();
            final List<int> completedParts = controller.completedParts;
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
            return AlertDialog(
              scrollable: true,
              title: ListTile(
                leading: BdoItemImage(code: item.code.toString()),
                title: Text(context.itemName(item.code.toString())),
                subtitle: LinearProgressIndicator(
                  backgroundColor: Colors.grey,
                  color: color,
                  value: min(percent / 100, 1.0),
                ),
              ),
              content: ConstrainedBox(
                constraints: BoxConstraints(minWidth: 320),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      title: Text(context.tr("shipUpgrading.stocks")),
                      trailing: SizedBox(
                        width: 124,
                        child: TextFormField(
                          controller: controller.textController[item.code],
                          keyboardType: const TextInputType.numberWithOptions(),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^(\d{0,4})')),
                          ],
                          textAlign: TextAlign.center,
                          onChanged: (value) {
                            final parsed = int.tryParse(value) ?? 0;
                            controller.updateUserStock(item.code, parsed);
                          },
                        ),
                      ),
                    ),
                    ListTile(
                      title: Text(context.tr("shipUpgrading.needed")),
                      trailing: Text(realNeed?.count.format() ?? "-"),
                    ),
                    ListTile(
                      title: Text(context.tr("shipUpgrading.completion")),
                      trailing: Text(
                        "${percent.toStringAsFixed(2)}%",
                        style: TextStyle(color: color),
                      ),
                    ),
                    ListTile(
                      title: Text(context.tr("shipUpgrading.dialog.unitCost")),
                      trailing: Text(context.tr(
                        "shipUpgrading.dialog.coin",
                        args: [item.coin.format()],
                      )),
                    ),
                    ListTile(
                      title: Text(context.tr("shipUpgrading.dialog.totalCost")),
                      trailing: Text(context.tr(
                        "shipUpgrading.dialog.coin",
                        args: [coin.format()],
                      )),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: parents.map((parent) {
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _PartsImage(
                                code: parent.code.toString(),
                                completed: completedParts.contains(parent.code),
                              ),
                              SizedBox(width: 12),
                              Text(
                                parent.materials
                                    .firstWhere((e) => e.code == item.code)
                                    .count
                                    .format(),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _FAB extends StatelessWidget {
  const _FAB({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: context.read<ShipUpgradingController>().dailyQuest,
      icon: const Icon(Icons.add_task),
      label: Text(context.tr("shipUpgrading.dailyQuest")),
      focusNode: FocusNode(skipTraversal: true),
    );
  }
}

class _PartsImage extends StatelessWidget {
  final String code;
  final bool completed;

  const _PartsImage({super.key, required this.code, required this.completed});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: context.itemName(code),
      child: Stack(
        children: [
          BdoItemImage(
            code: code,
            size: 38,
          ),
          completed
              ? Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4.0),
                    color: Colors.black.withAlpha(74),
                  ),
                  child: Icon(
                    Icons.check,
                    color: Colors.green,
                  ),
                )
              : SizedBox(),
        ],
      ),
    );
  }
}
