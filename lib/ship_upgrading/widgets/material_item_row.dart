import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:karanda/ship_upgrading/ship_upgrading_material.dart';
import 'package:karanda/trade_market/bdo_item_image_widget.dart';

class MaterialItemRow {
  final ShipUpgradingMaterial material;
  final int need;
  final int totalDays;
  final bool finished;
  final bool showTotalNeeded;
  final Function(String, int) onInputChanged;
  final Function(String) increase;
  final Function(String) decrease;

  MaterialItemRow(
      {required this.material,
        required this.showTotalNeeded,
        required this.need,
        required this.finished,
        required this.onInputChanged,
        required this.increase,
        required this.decrease,
        required this.totalDays});

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

  TableRow toTableRow() {
    return TableRow(children: [
      Padding(
        padding: const EdgeInsets.all(6.0),
        child: InkWell(
          onTap: () => decrease(material.code.toString()),
          borderRadius: BorderRadius.circular(4.0),
          focusNode: FocusNode(skipTraversal: true),
          child: BdoItemImageWidget(
            code: material.code.toString(),
            grade: material.grade,
            size: 44,
          ),
        ),
      ),
      TextButton(
        onPressed: () => increase(material.code.toString()),
        focusNode: FocusNode(skipTraversal: true),
        child: Text(material.nameKR.replaceAll('(', '\n('),
            textAlign: TextAlign.center),
      ),
      //Text(material.nameKR.replaceAll('(', '\n('), textAlign: TextAlign.center),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(material.obtain.nameWithNpc),
            Text(
              material.obtain.detailWithReward,
              style: const TextStyle(fontSize: 12.0),
            ),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextFormField(
          controller: material.controller,
          keyboardType: const TextInputType.numberWithOptions(),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^(\d{0,3})')),
          ],
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: Colors.blue),
            ),
            contentPadding: EdgeInsets.zero,
          ),
          textAlign: TextAlign.center,
          onChanged: (String value) {
            int parsed = int.tryParse(value) ?? 0;
            onInputChanged(material.code.toString(), parsed);
          },
        ),
      ),
      Text.rich(
        TextSpan(
          text: '${need.toString()}개',
          children: showTotalNeeded && need != material.totalNeeded
              ? [
            TextSpan(
              text: '\n(${material.totalNeeded})',
              style: const TextStyle(fontSize: 12),
            )
          ]
              : [],
        ),
        textAlign: TextAlign.center,
      ),
      Text(
        finished || material.obtain.reward <= 0
            ? '-'
            : '${getDDay(need, material.userStock, material.obtain.reward)}일 / $totalDays일',
        textAlign: TextAlign.center,
      ),
      Text(
        finished
            ? '-'
            : '${(material.userStock / need * 100).toStringAsFixed(2)}%',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: finished ? null : getColor(material.userStock / need),
        ),
      ),
    ]);
  }

  static TableRow header({required bool showTotalNeeded}) {
    TextStyle style = const TextStyle(
      fontWeight: FontWeight.bold,
    );
    return TableRow(children: [
      const SizedBox(
        height: 26.0,
      ),
      Text(
        "아이템",
        textAlign: TextAlign.center,
        style: style,
      ),
      Text(
        "주요 획득처",
        textAlign: TextAlign.center,
        style: style,
      ),
      Text(
        "보유",
        textAlign: TextAlign.center,
        style: style,
      ),
      Text.rich(
        TextSpan(
          text: "필요",
          children: showTotalNeeded
              ? [const TextSpan(text: "\n(합계)", style: TextStyle(fontSize: 12))]
              : [],
        ),
        textAlign: TextAlign.center,
        style: style,
      ),
      Text(
        "남은 일수",
        textAlign: TextAlign.center,
        style: style,
      ),
      Text(
        "달성률",
        textAlign: TextAlign.center,
        style: style,
      ),
    ]);
  }
}