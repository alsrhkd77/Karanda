import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:karanda/ship_extension/ship_extension_item_model.dart';

class ItemWidget extends StatefulWidget {
  final Widget textField;
  final ShipExtensionItemModel item;

  const ItemWidget({Key? key, required this.textField, required this.item})
      : super(key: key);

  @override
  State<ItemWidget> createState() => _ItemWidgetState();
}

class _ItemWidgetState extends State<ItemWidget> {

  MaterialColor getColor(double percent){
    if(percent < 0.25){
      return Colors.red;
    }else if(percent < 0.5){
      return Colors.orange;
    }else if(percent < 0.75){
      return Colors.yellow;
    }else if(percent < 1){
      return Colors.green;
    }
    return Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    String farming = widget.item.farmingRootName;
    String detail = widget.item.detail;
    int dDay = widget.item.reward == 0 ? 0 : ((widget.item.need - widget.item.user) / widget.item.reward).ceil();
    double percent = widget.item.user / widget.item.need;
    if (percent > 1) percent = 1;
    if (dDay < 0) dDay = 0;
    if (widget.item.reward > 0) {
      farming = '$farming - ${widget.item.npc}';
      detail = '$detail, 보상 ${widget.item.reward}개';
    }
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.all(4.0),
      height: 75,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Image.asset(
                    widget.item.assetPath,
                    width: 40,
                    height: 40,
                  ),
                ),
                const VerticalDivider(),
                Container(
                  width: 135,
                  margin: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: Text(widget.item.name,
                      overflow: TextOverflow.clip, textAlign: TextAlign.center),
                ),
                const VerticalDivider(),
                Container(
                  width: 470,
                  margin: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(farming),
                      Text(detail, style: context.textTheme.caption,)
                    ],
                  ),
                ),
                const VerticalDivider(),
                SizedBox(
                  width: 60,
                  child: widget.textField,
                ),
                const VerticalDivider(),
                Container(
                  width: 40,
                  margin: const EdgeInsets.symmetric(horizontal: 6.0),
                  child:
                  Text('${widget.item.need}개', textAlign: TextAlign.center),
                ),
                const VerticalDivider(),
                Container(
                  width: 30,
                  margin: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: Text(
                      widget.item.reward == 0
                          ? '-'
                          : '$dDay일',
                      textAlign: TextAlign.center),
                ),
                const VerticalDivider(),
                Container(
                  width: 30,
                  margin: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: Text(
                      widget.item.reward == 0
                          ? '-'
                          : '${(widget.item.need / widget.item.reward).ceil()}일',
                      textAlign: TextAlign.center),
                ),
                const VerticalDivider(),
                Container(
                  width: 70,
                  margin: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: const Text('1500 주화', textAlign: TextAlign.center),
                ),
              ],
            ),
          ),
          Positioned(
            child: LinearProgressIndicator(
              color: getColor(percent),
              value: percent,
              backgroundColor: Colors.black.withOpacity(0),
            ),
            bottom: -2,
            left: 0,
            right: 0,
          ),
        ],
      ),
    );
  }
}
