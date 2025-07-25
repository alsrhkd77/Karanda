import 'package:flutter/material.dart';
import 'package:karanda/utils/extension/build_context_extension.dart';

import '../../core/ui/bdo_item_image.dart';

class ShipUpgradingPartsImage extends StatelessWidget {
  final String code;
  final double size;
  final bool completed;

  const ShipUpgradingPartsImage({
    super.key,
    required this.code,
    required this.completed,
    this.size = 38.0,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: context.itemName(code),
      child: Stack(
        children: [
          BdoItemImage(
            code: code,
            size: size,
          ),
          completed
              ? Container(
                  width: size,
                  height: size,
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
