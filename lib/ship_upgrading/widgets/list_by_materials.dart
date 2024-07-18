import 'package:flutter/material.dart';
import 'package:karanda/ship_upgrading/ship_upgrading_data_controller.dart';
import 'package:karanda/ship_upgrading/ship_upgrading_setting.dart';
import 'package:karanda/ship_upgrading/widgets/material_item_row.dart';
import 'package:karanda/widgets/loading_indicator.dart';

class ListByMaterials extends StatefulWidget {
  final ShipUpgradingDataController dataController;
  final ShipUpgradingSetting setting;

  const ListByMaterials(
      {super.key, required this.dataController, required this.setting});

  @override
  State<ListByMaterials> createState() => _ListByMaterialsState();
}

class _ListByMaterialsState extends State<ListByMaterials> {
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
        stream: dataController.selectedShipData,
        builder: (context, selected) {
          return StreamBuilder(
              stream: dataController.materials,
              builder: (context, materials) {
                if (!selected.hasData || !materials.hasData) {
                  return const LoadingIndicator();
                }
                return Card(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 8.0),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 26.0, vertical: 16.0),
                    child: Table(
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
                      defaultVerticalAlignment:
                          TableCellVerticalAlignment.middle,
                      defaultColumnWidth: const FixedColumnWidth(80),
                      children: (widget.setting.showTableHeader
                          ? [MaterialItemRow.header(showTotalNeeded: false)]
                          : [])
                        ..addAll(materials.requireData.values.map<TableRow>(
                          (e) => MaterialItemRow(
                            material: e,
                            need: e.totalNeeded,
                            finished: false,
                            showTotalNeeded: false,
                            onInputChanged: dataController.updateUserStock,
                            totalDays: e.totalDays,
                            increase: dataController.increaseUserStock,
                            decrease: dataController.decreaseUserStock,
                          ).toTableRow(),
                        )),
                    ),
                  ),
                );
              });
        });
  }
}
