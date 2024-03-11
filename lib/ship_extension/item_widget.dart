import 'package:flutter/material.dart';
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
    String farming = widget.item.farmingRootName;
    String detail = widget.item.detail;
    int dDay = widget.item.reward == 0
        ? 0
        : ((widget.item.need - widget.item.user) / widget.item.reward).ceil();
    double percent = widget.item.need > 0 ?widget.item.user / widget.item.need : 0;
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
                  width: 190,
                  margin: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: Text(widget.item.name.replaceFirst('(', '\n('),
                      overflow: TextOverflow.clip, textAlign: TextAlign.center),
                ),
                const VerticalDivider(),
                Container(
                  width: 480,
                  margin: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(farming),
                      Text(
                        detail,
                        style: Theme.of(context).textTheme.bodySmall,
                      )
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
                  width: 45,
                  margin: const EdgeInsets.symmetric(horizontal: 6.0),
                  child:
                      Text('${widget.item.need}개', textAlign: TextAlign.center),
                ),
                const VerticalDivider(),
                Container(
                  width: 40,
                  margin: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: Text(widget.item.reward == 0 ? '-' : '$dDay일',
                      textAlign: TextAlign.center),
                ),
                const VerticalDivider(),
                Container(
                  width: 40,
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
                  //child: Text('${widget.item.price}주화', textAlign: TextAlign.center),
                  child: Text('${(percent * 100).toStringAsFixed(2)}%', textAlign: TextAlign.center),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: -2,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(
              color: getColor(percent),
              value: percent > 1 ? 1 : percent,
              backgroundColor: Colors.transparent,
            ),
          ),
          Positioned(
            left: -3,
            child: SizedBox(
              width: 80,
              child: _PartsIcon(
                partsName: widget.item.parts,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PartsIcon extends StatelessWidget {
  final List<String> partsName;
  final parts = {
    'prow' : '선수상',
    'plating' : '장갑',
    'cannon' : '함포',
    'windSail' : '돛',
  };

  _PartsIcon({super.key, required this.partsName});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: partsName.map((e) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.5),
        child: Text(
          parts[e]!,
          style: const TextStyle(fontSize: 11.0),
        ),
      )).toList(),
    );
  }
}

