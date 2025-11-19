import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:karanda/model/bartering/bartering.dart';
import 'package:karanda/ui/bartering/controller/bartering_weight_controller.dart';
import 'package:karanda/ui/core/ui/loading_indicator.dart';
import 'package:karanda/ui/core/ui/page_base.dart';
import 'package:karanda/utils/extension/double_extension.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';

import '../../../model/bartering/ship_profile.dart';
import '../../core/theme/dimes.dart';

class SimpleBarteringWeightTab extends StatelessWidget {
  const SimpleBarteringWeightTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => BarteringWeightController(
        repository: context.read(),
      ),
      builder: (context, child) {
        return Consumer(
          builder: (context, BarteringWeightController controller, child) {
            if (controller.settings == null) {
              return LoadingIndicator();
            }
            final width = MediaQuery.sizeOf(context).width;
            final isDense = width < 400;
            return PageBase(
              width: width,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(),
                      DropdownMenu<ShipProfile>(
                        label:
                            Text(context.tr("bartering.settings.shipProfiles")),
                        width: width < 600
                            ? width - 16.0 - (Dimens.pagePaddingValue * 2)
                            : null,
                        initialSelection: controller.settings!.lastSelectedShip,
                        dropdownMenuEntries:
                            controller.settings!.shipProfiles.map((profile) {
                          return DropdownMenuEntry(
                            value: profile,
                            label: profile.name,
                          );
                        }).toList(),
                        onSelected: controller.onProfileSelect,
                      ),
                    ],
                  ),
                ),
                _PercentIndicator(
                  current: controller.totalWeight,
                  total: controller.settings!.lastSelectedShip.totalWeight,
                ),
                ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  primary: false,
                  shrinkWrap: true,
                  itemCount: controller.tradeGoods.length,
                  itemBuilder: (context, index) {
                    final isEtc = index == controller.tradeGoods.length - 1;
                    return _WeightTile(
                      isDense: isDense,
                      isEtc: isEtc,
                      data: controller.tradeGoods[index],
                      increaseCount: () => controller.increaseCount(index),
                      decreaseCount: () => controller.decreaseCount(index),
                      onCountUpdate: (value) {
                        controller.updateCount(index: index, value: value);
                      },
                      weightTextController:
                          isEtc ? controller.etcWeightTextController : null,
                      onWeightUpdate: isEtc ? controller.updateEtcWeight : null,
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _WeightTile extends StatelessWidget {
  final bool isDense;
  final bool isEtc;
  final Bartering data;
  final TextEditingController? weightTextController;
  final void Function() increaseCount;
  final void Function() decreaseCount;
  final void Function(int) onCountUpdate;
  final void Function(double)? onWeightUpdate;

  const _WeightTile({
    super.key,
    required this.isDense,
    required this.isEtc,
    required this.data,
    this.weightTextController,
    required this.increaseCount,
    required this.decreaseCount,
    required this.onCountUpdate,
    required this.onWeightUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final totalWeight = data.outputWeight * data.count;
    return Card(
      child: ListTile(
        title: Flex(
          direction: isDense ? Axis.vertical : Axis.horizontal,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment:
              isDense ? CrossAxisAlignment.start : CrossAxisAlignment.center,
          spacing: isDense ? 4.0 : 12.0,
          children: [
            Text(context.tr("bartering.simple.${data.exchangePoint}")),
            Container(
              width: isDense ? 160 : 140,
              padding: EdgeInsets.all(4.0),
              child: isEtc
                  ? TextFormField(
                      controller: weightTextController,
                      keyboardType: const TextInputType.numberWithOptions(),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^[0-9.]*$')),
                      ],
                      maxLength: 8,
                      decoration: InputDecoration(
                        labelText: context.tr("bartering.weight"),
                        counter: const SizedBox(),
                        suffixText: "LT",
                      ),
                      onChanged: (value) {
                        final parsed = double.tryParse(value) ?? 0;
                        onWeightUpdate!(parsed);
                      },
                    )
                  : TextFormField(
                      controller: data.countTextController,
                      keyboardType: const TextInputType.numberWithOptions(),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^(\d{0,3})')),
                      ],
                      textAlignVertical: TextAlignVertical.top,
                      decoration: InputDecoration(
                        labelText: context.tr("bartering.simple.count"),
                        contentPadding: EdgeInsets.symmetric(horizontal: 6.0),
                        prefix: InkWell(
                          onTap: decreaseCount,
                          focusNode: FocusNode(skipTraversal: true),
                          borderRadius: BorderRadius.circular(25.0),
                          child: Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Icon(Icons.remove, size: 16),
                          ),
                        ),
                        suffix: InkWell(
                          onTap: increaseCount,
                          focusNode: FocusNode(skipTraversal: true),
                          borderRadius: BorderRadius.circular(25.0),
                          child: Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Icon(Icons.add, size: 16),
                          ),
                        ),
                      ),
                      textAlign: TextAlign.center,
                      onChanged: (value) {
                        final parsed = int.tryParse(value) ?? 0;
                        onCountUpdate(parsed);
                      },
                    ),
            ),
          ],
        ),
        trailing: Text("${totalWeight.format()} LT"),
      ),
    );
  }
}

class _PercentIndicator extends StatelessWidget {
  final double current;
  final double total;

  const _PercentIndicator({
    super.key,
    required this.current,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final rate = current / total;
    final text = (rate * 100).format();
    MaterialColor color;
    switch (rate) {
      case < 0.4:
        color = Colors.blue;
      case < 0.8:
        color = Colors.green;
      case < 1.0:
        color = Colors.yellow;
      case < 1.7:
        color = Colors.orange;
      default:
        color = Colors.red;
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: LinearPercentIndicator(
        animation: true,
        animationDuration: 500,
        percent: min(rate / 1.7, 1.0),
        barRadius: const Radius.circular(4.0),
        progressColor: color,
        animateFromLastPercent: true,
        trailing: Text("${current.format()}LT / ${total.format()}LT ($text%)"),
      ),
    );
  }
}
