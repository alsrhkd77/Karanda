import 'package:flutter/material.dart';
import 'package:karanda/ship_upgrading/ship_upgrading_data_controller.dart';
import 'package:karanda/ship_upgrading/ship_upgrading_material.dart';
import 'package:karanda/ship_upgrading/ship_upgrading_parts.dart';
import 'package:karanda/ship_upgrading/ship_upgrading_setting.dart';
import 'package:karanda/ship_upgrading/widgets/material_item_row.dart';
import 'package:karanda/trade_market/bdo_item_image_widget.dart';
import 'package:karanda/widgets/loading_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class ListByParts extends StatefulWidget {
  final ShipUpgradingDataController dataController;
  final double screenWidth;
  //final ShipUpgradingSetting setting;

  const ListByParts({super.key, required this.dataController, required this.screenWidth,});

  @override
  State<ListByParts> createState() => _ListByPartsState();
}

class _ListByPartsState extends State<ListByParts> {
  late ShipUpgradingDataController dataController;

  @override
  void initState() {
    super.initState();
    dataController = widget.dataController;
    WidgetsBinding.instance
        .addPostFrameCallback((timeStamp) => dataController.subscribe());
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: dataController.setting,
      builder: (context, setting) {
        return StreamBuilder(
          stream: dataController.selectedShipData,
          builder: (context, selected) {
            return StreamBuilder(
              stream: dataController.parts,
              builder: (context, parts) {
                return StreamBuilder(
                  stream: dataController.materials,
                  builder: (context, materials) {
                    if (!materials.hasData ||
                        !selected.hasData ||
                        !parts.hasData ||
                        !setting.hasData) {
                      return const LoadingIndicator();
                    }
                    return Column(
                      children: selected.requireData.parts
                          .map<_PartsCard>((e) => _PartsCard(
                        parts: parts.requireData[e]!,
                        materials: materials.requireData,
                        screenWidth: widget.screenWidth,
                        onInputChanged:
                        dataController.updateUserStock,
                        setFinished: dataController.setFinished,
                        showTotalNeeded:
                        setting.requireData.showTotalNeeded,
                        closeFinished: setting
                            .requireData.closeFinishedParts,
                        showHeaders:
                        setting.requireData.showTableHeader,
                        increase:
                        dataController.increaseUserStock,
                        decrease:
                        dataController.decreaseUserStock,
                      ))
                          .toList(),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

class _PartsCard extends StatelessWidget {
  final double screenWidth;
  final ShipUpgradingParts parts;
  final Map<String, ShipUpgradingMaterial> materials;
  final bool closeFinished;
  final bool showHeaders;
  final bool showTotalNeeded;
  final Function(String, int) onInputChanged;
  final Function(String) setFinished;
  final Function(String) increase;
  final Function(String) decrease;

  const _PartsCard({
    super.key,
    required this.parts,
    required this.screenWidth,
    required this.materials,
    required this.onInputChanged,
    required this.setFinished,
    required this.closeFinished,
    required this.showHeaders,
    required this.increase,
    required this.decrease,
    required this.showTotalNeeded,
  });

  int getDDay(int need, int stock, int reward) {
    need = need - stock;
    if (need <= 0) return 0;
    return (need / reward).ceil();
  }

  MaterialColor getColor(double percent) {
    if (percent < 0.25) {
      return Colors.red;
    } else if (percent < 0.5) {
      return Colors.orange;
    } else if (percent < 0.75) {
      return Colors.yellow;
    } else if (percent < 1) {
      return Colors.green;
    }
    return Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    double percent = 0;
    if (!parts.finished) {
      int totalNeed = 0;
      int totalStock = 0;
      for (String key in parts.materials.keys) {
        /*
        int num = materials[key]!.obtain.reward > 0
            ? materials[key]!.obtain.reward
            : materials[key]!.obtain.trade;

        totalNeed += parts.materials[key]!.need / num;

        if (materials[key]!.userStock > parts.materials[key]!.need) {
          totalStock += parts.materials[key]!.need / num;
        } else {
          totalStock += materials[key]!.userStock / num;
        }
         */
        totalNeed += parts.materials[key]!.need * materials[key]!.price;
        if (materials[key]!.userStock > parts.materials[key]!.need) {
          totalStock += parts.materials[key]!.need * materials[key]!.price;
        } else {
          totalStock += materials[key]!.userStock * materials[key]!.price;
        }
      }
      percent = totalStock / totalNeed;
    }
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 12.0),
        child: Column(
          children: [
            ListTile(
              leading: BdoItemImageWidget(
                code: parts.code.toString(),
                grade: parts.grade,
                size: 46,
              ),
              title: Text(parts.nameKR),
              trailing: parts.type != ShipParts.license
                  ? OutlinedButton.icon(
                onPressed: () => setFinished(parts.code.toString()),
                clipBehavior: Clip.hardEdge,
                icon: const Icon(Icons.check_rounded),
                label: const Text('제작 완료'),
                style: OutlinedButton.styleFrom(
                  //foregroundColor: Colors.grey.shade700,
                    foregroundColor: parts.finished
                        ? Colors.green.shade400
                        : Colors.grey.shade700,
                    side: BorderSide(
                        color: parts.finished
                            ? Colors.green.shade400
                            : Colors.grey.shade700,
                        width: 2.0),
                    animationDuration: const Duration(milliseconds: 650)),
                focusNode: FocusNode(skipTraversal: true),
              )
                  : null,
            ),
            !parts.finished || !closeFinished
                ? Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8.0, vertical: 12.0),
              child: LinearPercentIndicator(
                animation: true,
                animationDuration: 500,
                percent: percent,
                barRadius: const Radius.circular(4.0),
                progressColor: getColor(percent),
                backgroundColor: Colors.grey.shade700.withOpacity(0.6),
                animateFromLastPercent: true,
                lineHeight: 1.8,
              ),
            )
                : Container(),
            !parts.finished || !closeFinished
                ? Table(
              border: TableBorder(
                  horizontalInside: BorderSide(
                      color: Colors.grey.shade700.withOpacity(0.0),
                      width: 0.6),
                  verticalInside: BorderSide(
                      color: Colors.grey.shade700.withOpacity(0.0),
                      width: 0.6)),
              columnWidths: const <int, TableColumnWidth>{
                0: FixedColumnWidth(56),
                1: FixedColumnWidth(180),
                2: FixedColumnWidth(450),
                3: FixedColumnWidth(100),
                4: FixedColumnWidth(80),
                5: FixedColumnWidth(110),
                6: FixedColumnWidth(80),
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              defaultColumnWidth: const FixedColumnWidth(80),
              children: (showHeaders
                  ? [
                MaterialItemRow.header(
                    showTotalNeeded: showTotalNeeded)
              ]
                  : [])
                ..addAll(parts.materials.keys.map<TableRow>(
                      (e) => MaterialItemRow(
                    material: materials[e]!,
                    need: parts.materials[e]!.need,
                    finished: parts.finished,
                    showTotalNeeded: showTotalNeeded,
                    onInputChanged: onInputChanged,
                    totalDays: parts.materials[e]!.days,
                    increase: increase,
                    decrease: decrease,
                  ).toTableRow(),
                )),
            )
                : Container(),
          ],
        ),
      ),
    );
  }
}
