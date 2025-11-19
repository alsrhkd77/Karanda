import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:karanda/model/bartering/bartering.dart';
import 'package:karanda/model/bartering/bartering_mastery.dart';
import 'package:karanda/model/bartering/bartering_settings.dart';
import 'package:karanda/model/bartering/ship_profile.dart';
import 'package:karanda/ui/bartering/controller/bartering_parley_controller.dart';
import 'package:karanda/ui/core/theme/dimes.dart';
import 'package:karanda/ui/core/ui/bdo_item_image.dart';
import 'package:karanda/ui/core/ui/loading_indicator.dart';
import 'package:karanda/ui/core/ui/page_base.dart';
import 'package:karanda/utils/extension/build_context_extension.dart';
import 'package:karanda/utils/extension/double_extension.dart';
import 'package:karanda/utils/extension/int_extension.dart';
import 'package:percent_indicator/flutter_percent_indicator.dart';
import 'package:provider/provider.dart';

class SimpleBarteringParleyTab extends StatelessWidget {
  const SimpleBarteringParleyTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => BarteringParleyController(
        repository: context.read(),
      ),
      builder: (context, child) {
        return Consumer(
          builder: (context, BarteringParleyController controller, child) {
            if (controller.settings == null) {
              return LoadingIndicator();
            }
            final width = MediaQuery.sizeOf(context).width;
            return PageBase(
              width: width,
              children: [
                _Head(
                  width: width,
                  settings: controller.settings!,
                  onShipProfileSelected: controller.onProfileSelect,
                  enabled: controller.started,
                  tradeVoucher: controller.tradeVoucher,
                  parleyTextController: controller.parleyTextController,
                  onParleyUpdate: controller.onParleyTextUpdate,
                  increaseVoucher: controller.increaseTradeVoucher,
                  decreaseVoucher: controller.decreaseTradeVoucher,
                  start: controller.start,
                  resetAll: controller.resetAll,
                ),
                _PercentIndicator(
                  consumed: controller.consumed + controller.totalParley,
                  total: controller.parley,
                ),
                ListView.builder(
                  primary: false,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: controller.locations.length,
                  itemBuilder: (context, index) {
                    return _BarteringTile(
                      width: width,
                      enabled: controller.started,
                      data: controller.locations[index],
                      onCountUpdate: (value) => controller.updateCount(
                        index: index,
                        value: value,
                      ),
                      increase: () => controller.increaseCount(index),
                      decrease: () => controller.decreaseCount(index),
                      apply: () => controller.applyCount(index),
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

class _BarteringTile extends StatelessWidget {
  final double width;
  final bool enabled;
  final Bartering data;
  final void Function(int value) onCountUpdate;
  final void Function() increase;
  final void Function() decrease;
  final void Function() apply;

  const _BarteringTile({
    super.key,
    required this.width,
    required this.enabled,
    required this.data,
    required this.onCountUpdate,
    required this.increase,
    required this.decrease,
    required this.apply,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDense = width < 460;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 8.0,
          children: [
            Flex(
              direction: isDense ? Axis.vertical : Axis.horizontal,
              mainAxisAlignment: isDense
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.spaceBetween,
              crossAxisAlignment: isDense
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.center,
              children: [
                _Location(
                  isDense: isDense,
                  reducedParley: data.reducedParley,
                  exchangePoint: data.exchangePoint,
                ),
                Text(context.tr(
                  "bartering.total",
                  args: [data.totalParley.format()],
                )),
              ],
            ),
            Flex(
              direction: isDense ? Axis.vertical : Axis.horizontal,
              mainAxisAlignment: isDense
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: isDense ? Size.infinite.width : 220,
                  child: TextFormField(
                    controller: data.countTextController,
                    keyboardType: const TextInputType.numberWithOptions(),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^(\d{0,3})')),
                    ],
                    textAlignVertical: TextAlignVertical.top,
                    decoration: InputDecoration(
                      labelText: " ${context.tr("bartering.exchangeCount")}",
                      contentPadding: EdgeInsets.symmetric(horizontal: 6.0),
                      prefix: InkWell(
                        onTap: decrease,
                        focusNode: FocusNode(skipTraversal: true),
                        borderRadius: BorderRadius.circular(25.0),
                        child: Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Icon(Icons.remove, size: 16),
                        ),
                      ),
                      suffix: InkWell(
                        onTap: increase,
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
                Container(
                  width: isDense ? Size.infinite.width : null,
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: ElevatedButton(
                    onPressed: enabled ? apply : null,
                    child: Text(context.tr("bartering.exchangeComplete")),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Location extends StatelessWidget {
  final bool isDense;
  final int reducedParley;
  final String exchangePoint;

  const _Location({
    super.key,
    required this.isDense,
    required this.reducedParley,
    required this.exchangePoint,
  });

  @override
  Widget build(BuildContext context) {
    final text = context.tr("bartering.simple.$exchangePoint");
    return Row(
      mainAxisAlignment:
          isDense ? MainAxisAlignment.spaceBetween : MainAxisAlignment.start,
      children: [
        Text("[${reducedParley.format()}] $text"),
        Tooltip(
          message: context.tr("bartering.simple.${exchangePoint}_points"),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(Icons.help_outline, color: Colors.grey),
          ),
        ),
      ],
    );
  }
}

class _Head extends StatelessWidget {
  final double width;
  final BarteringSettings settings;
  final bool enabled;
  final int tradeVoucher;
  final TextEditingController parleyTextController;
  final void Function(ShipProfile?) onShipProfileSelected;
  final void Function(String?) onParleyUpdate;
  final void Function() increaseVoucher;
  final void Function() decreaseVoucher;
  final void Function() start;
  final void Function() resetAll;

  const _Head({
    super.key,
    required this.width,
    required this.settings,
    required this.onShipProfileSelected,
    required this.enabled,
    required this.tradeVoucher,
    required this.parleyTextController,
    required this.onParleyUpdate,
    required this.increaseVoucher,
    required this.decreaseVoucher,
    required this.start,
    required this.resetAll,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        top: Dimens.pagePaddingValue,
      ),
      child: Flex(
        direction: width < 600 ? Axis.vertical : Axis.horizontal,
        mainAxisAlignment: width < 600
            ? MainAxisAlignment.start
            : MainAxisAlignment.spaceBetween,
        spacing: 4.0,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flex(
                direction: width < 440 ? Axis.vertical : Axis.horizontal,
                crossAxisAlignment: width < 440
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.center,
                spacing: 8.0,
                children: [
                  SizedBox(
                    width: width < 440 ? Size.infinite.width : 220,
                    child: TextFormField(
                      controller: parleyTextController,
                      enabled: !enabled,
                      keyboardType: const TextInputType.numberWithOptions(),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^(\d{0,7})'),
                        ),
                      ],
                      decoration: InputDecoration(
                        labelText: context.tr("bartering.parley"),
                      ),
                      onChanged: onParleyUpdate,
                    ),
                  ),
                  _TradeVoucher(
                    tradeVoucher: tradeVoucher,
                    increaseVoucher: increaseVoucher,
                    decreaseVoucher: decreaseVoucher,
                  ),
                ],
              ),
              _ReductionRate(
                mastery: settings.mastery,
                useValuePack: settings.valuePack,
                useCleia: settings.lastSelectedShip.useCleia,
              ),
            ],
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              DropdownMenu<ShipProfile>(
                label: Text(context.tr("bartering.settings.shipProfiles")),
                width: width < 600
                    ? width - 36.0 - (Dimens.pagePaddingValue * 2)
                    : null,
                initialSelection: settings.lastSelectedShip,
                dropdownMenuEntries: settings.shipProfiles.map((profile) {
                  return DropdownMenuEntry(value: profile, label: profile.name);
                }).toList(),
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                width: width < 600 ? Size.infinite.width : null,
                child: enabled
                    ? ElevatedButton.icon(
                        onPressed: resetAll,
                        label: Text(context.tr("bartering.simple.resetAll")),
                        icon: Icon(Icons.refresh),
                      )
                    : ElevatedButton.icon(
                        onPressed: start,
                        label: Text(context.tr("bartering.simple.start")),
                        icon: Icon(Icons.rocket_launch),
                      ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _TradeVoucher extends StatelessWidget {
  final int tradeVoucher;
  final void Function() increaseVoucher;
  final void Function() decreaseVoucher;

  const _TradeVoucher({
    super.key,
    required this.tradeVoucher,
    required this.increaseVoucher,
    required this.decreaseVoucher,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      spacing: 4.0,
      children: [
        Tooltip(
          message: context.tr(
            "bartering.tradeVoucherDetail",
            args: [context.itemName("320106")],
          ),
          child: BdoItemImage(code: "320106"),
        ),
        IconButton(
          onPressed: decreaseVoucher,
          icon: Icon(Icons.remove),
        ),
        Text(tradeVoucher.toString()),
        IconButton(
          onPressed: increaseVoucher,
          icon: Icon(Icons.add),
        ),
      ],
    );
  }
}

class _ReductionRate extends StatelessWidget {
  final BarteringMastery mastery;
  final bool useValuePack;
  final bool useCleia;

  const _ReductionRate({
    super.key,
    required this.mastery,
    required this.useValuePack,
    required this.useCleia,
  });

  @override
  Widget build(BuildContext context) {
    double rate = mastery.reductionRate * 100;
    String text =
        "${context.tr("lifeSkillLevel.${mastery.rank}")} ${mastery.level}(${rate.toStringAsFixed(2)}%)";
    if (useValuePack) {
      rate = rate + 10.0;
      text = "$text\n${context.tr("bartering.settings.valuePack")}(10%)";
    }
    if (useCleia) {
      rate = rate + 10.0;
      text = "$text\n${context.tr("bartering.settings.cleia")}(10%)";
    }
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Row(
        children: [
          Text(
            context.tr(
              "bartering.parleyReduction",
              args: [rate.toStringAsFixed(2)],
            ),
            style: TextTheme.of(context).titleMedium,
          ),
          Tooltip(
            message: text,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.help_outline, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}

class _PercentIndicator extends StatelessWidget {
  final int consumed;
  final int total;

  const _PercentIndicator({
    super.key,
    required this.consumed,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final rate = consumed / total;
    final text = (rate * 100).format();
    MaterialColor color;
    switch (rate) {
      case < 0.25:
        color = Colors.blue;
      case < 0.5:
        color = Colors.green;
      case < 0.75:
        color = Colors.yellow;
      case < 1.0:
        color = Colors.orange;
      default:
        color = Colors.red;
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: LinearPercentIndicator(
        animation: true,
        animationDuration: 500,
        percent: min(rate, 1.0),
        barRadius: const Radius.circular(4.0),
        progressColor: color,
        animateFromLastPercent: true,
        trailing: Text("${consumed.format()} / ${total.format()} ($text%)"),
      ),
    );
  }
}
