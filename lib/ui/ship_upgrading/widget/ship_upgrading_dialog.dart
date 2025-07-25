import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:karanda/utils/extension/build_context_extension.dart';
import 'package:karanda/utils/extension/int_extension.dart';
import 'package:provider/provider.dart';

import '../../../model/ship_upgrading/ship_upgrading_data.dart';
import '../../core/ui/bdo_item_image.dart';
import '../controller/ship_upgrading_controller.dart';
import 'ship_upgrading_parts_image.dart';

class ShipUpgradingDialog {
  final BuildContext context;

  ShipUpgradingDialog.of(this.context);

  void itemDialog({
    required ShipUpgradingData item,
    required ShipUpgradingController provider,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return _ItemDialog(item: item, provider: provider);
      },
    );
  }

  void dailyQuestDialog() {}

  void userStockResetDialog() {}
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
            final need = controller.needs[item.code];
            final realNeed = controller.realNeeds[item.code];
            final coin = (max((realNeed?.count ?? 0) - stock, 0) * item.coin);
            final List<ShipUpgradingData> parents = controller.selectedParts
                .where((e) => item.parent.contains(e.code))
                .toList();
            final List<int> completedParts = controller.completedParts;
            double percent;
            if (realNeed == null) {
              percent = (stock / (need?.count ?? 1) + 1) * 100;
            } else {
              percent = stock / (realNeed.count) * 100;
            }
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
                              ShipUpgradingPartsImage(
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
              actions: [
                SizedBox(
                  width: Size.infinite.width,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(context.tr("shipUpgrading.dialog.close")),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
