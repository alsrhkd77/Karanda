import 'package:flutter/material.dart';

class ShipUpgradingTableRow extends StatelessWidget {
  final double width;
  final void Function()? onTap;
  final Widget item;
  final Widget? itemName;
  final Widget stock;
  final Widget needed;
  final Widget completion;
  final Widget totalCost;
  final Widget components;

  const ShipUpgradingTableRow({
    super.key,
    required this.width,
    this.onTap,
    required this.item,
    this.itemName,
    required this.stock,
    required this.needed,
    required this.completion,
    required this.totalCost,
    required this.components,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      focusNode: FocusNode(skipTraversal: true),
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            flex: itemName == null ? (width < 600 ? 1 : 4) : 1,
            child: Center(child: item),
          ),
          itemName == null || width < 600
              ? SizedBox()
              : Expanded(
                  flex: 3,
                  child: itemName ?? SizedBox(),
                ),
          Expanded(
            flex: 2,
            child: Center(child: stock),
          ),
          Expanded(
            flex: 2,
            child: Center(child: needed),
          ),
          width < 500
              ? SizedBox()
              : Expanded(
                  flex: 2,
                  child: Center(child: completion),
                ),
          width < 800
              ? SizedBox()
              : Expanded(
                  flex: 2,
                  child: Center(child: totalCost),
                ),
          width < 1000
              ? SizedBox()
              : Expanded(
                  flex: 2,
                  child: Center(child: components),
                ),
        ],
      ),
    );
  }
}
