import 'package:flutter/material.dart';
import 'package:karanda/ship_upgrading/ship_upgrading_data_controller.dart';

class ListByMaterials extends StatefulWidget {
  final ShipUpgradingDataController dataController;

  const ListByMaterials({super.key, required this.dataController});

  @override
  State<ListByMaterials> createState() => _ListByMaterialsState();
}

class _ListByMaterialsState extends State<ListByMaterials> {
  late ShipUpgradingDataController dataController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((timeStamp) => dataController.subscribe());
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
