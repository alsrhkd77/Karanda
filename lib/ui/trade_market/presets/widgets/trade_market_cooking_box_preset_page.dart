import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:karanda/enums/bdo_region.dart';
import 'package:karanda/model/trade_market_preset_item.dart';
import 'package:karanda/ui/core/theme/dimes.dart';
import 'package:karanda/ui/core/ui/bdo_item_image.dart';
import 'package:karanda/ui/core/ui/karanda_app_bar.dart';
import 'package:karanda/ui/core/ui/loading_indicator.dart';
import 'package:karanda/ui/core/ui/page_base.dart';
import 'package:karanda/ui/trade_market/presets/controllers/trade_market_cooking_box_preset_controller.dart';
import 'package:karanda/utils/extension/build_context_extension.dart';
import 'package:karanda/utils/extension/go_router_extension.dart';
import 'package:karanda/utils/extension/int_extension.dart';
import 'package:provider/provider.dart';

class TradeMarketCookingBoxPresetPage extends StatelessWidget {
  final BDORegion region;

  const TradeMarketCookingBoxPresetPage({super.key, required this.region});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TradeMarketCookingBoxPresetController(
        marketService: context.read(),
        region: region,
      ),
      child: Scaffold(
        appBar: KarandaAppBar(
          title: context.tr("trade market.cooking_box"),
          icon: FontAwesomeIcons.scaleUnbalanced,
        ),
        body: Consumer(
          builder: (
            context,
            TradeMarketCookingBoxPresetController controller,
            child,
          ) {
            if (controller.items == null) {
              return const LoadingIndicator();
            } else if (!controller.isLoaded) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const LoadingIndicator(),
                  Text(context.tr(
                    "trade market.preset waiting",
                    args: [controller.items!.length.toString()],
                  )),
                ],
              );
            }
            return PageBase(
              children: [
                Container(
                  alignment: Alignment.centerRight,
                  child: DropdownMenu(
                    initialSelection: controller.selectedBox,
                    dropdownMenuEntries: controller.boxKeys.map((item) {
                      return DropdownMenuEntry(
                        value: item,
                        label: context.itemName(item),
                      );
                    }).toList(),
                    onSelected: (value) {
                      if (value?.isNotEmpty ?? false) {
                        controller.selectBox(value!);
                      }
                    },
                  ),
                ),
                _UserData(
                  contributionsController: controller.contributionsController,
                  proficiencyController: controller.proficiencyController,
                ),
                ListTile(
                  title: Text(context.tr("trade market.preset item name")),
                  trailing: Text(
                    context.tr("trade market.cooking_box revenue"),
                    style: TextTheme.of(context).bodyLarge,
                  ),
                ),
                ...controller.items!.map((item) {
                  return _ItemTile(
                    region: region,
                    item: item,
                    silverBonus: controller.mastery.silverBonus,
                    deliveryCounts: controller.deliveryCounts,
                    boxPrice: controller.boxPrice,
                  );
                }).toList()
              ],
            );
          },
        ),
      ),
    );
  }
}

class _UserData extends StatelessWidget {
  final TextEditingController contributionsController; //공헌도
  final TextEditingController proficiencyController; //숙련도

  const _UserData({
    super.key,
    required this.contributionsController,
    required this.proficiencyController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            constraints: const BoxConstraints(maxWidth: 140),
            child: TextField(
              controller: contributionsController,
              keyboardType: const TextInputType.numberWithOptions(),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^(\d{0,3})')),
              ],
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                  labelText:
                      context.tr("trade market.cooking_box contribution")),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            constraints: const BoxConstraints(maxWidth: 140),
            child: TextField(
              controller: proficiencyController,
              keyboardType: const TextInputType.numberWithOptions(),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^(\d{0,4})')),
              ],
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                  labelText: context.tr("trade market.cooking_box mastery")),
            ),
          )
        ],
      ),
    );
  }
}

class _ItemTile extends StatelessWidget {
  final BDORegion region;
  final int boxPrice;
  final TradeMarketPresetItem item;
  final double silverBonus;
  final int deliveryCounts;

  const _ItemTile({
    super.key,
    required this.region,
    required this.item,
    required this.silverBonus,
    required this.deliveryCounts,
    required this.boxPrice,
  });

  @override
  Widget build(BuildContext context) {
    final itemInfo = context.itemInfo(item.code.toString());
    return Card(
      margin: const EdgeInsets.all(4.0),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding: Dimens.listTileContentsPadding(),
        leading: BdoItemImage(
          code: itemInfo.code,
        ),
        title: Text("${context.itemName(itemInfo.code)} × ${item.value}"),
        subtitle: Text(context.tr(
          "trade market.cooking_box efficiency",
          namedArgs: {
            "total": (item.price!.price * item.value).format(),
            "single": item.price!.price.format(),
          },
        )),
        trailing: _Revenue(
          silverBonus: silverBonus,
          deliveryCounts: deliveryCounts,
          stock: item.price!.currentStock,
          boxPrice: boxPrice,
          value: item.value,
          materialPrice: item.price!.price,
        ),
        onTap: () {
          context
              .goWithGa("/trade-market/${region.name}/detail/${itemInfo.code}");
        },
      ),
    );
  }
}

class _Revenue extends StatelessWidget {
  final double silverBonus;
  final int value;
  final int materialPrice;
  final int boxPrice;
  final int stock;
  final int deliveryCounts;

  const _Revenue(
      {super.key,
      required this.silverBonus,
      required this.deliveryCounts,
      required this.stock,
      required this.boxPrice,
      required this.value,
      required this.materialPrice});

  @override
  Widget build(BuildContext context) {
    //예상 수익 = ((상자값 * 2.5) + (상자값 * 숙련도 보너스) - (요리 가격 * 상자당 필요 갯수)) * 황납 가능 횟수
    final int revenue = ((boxPrice * 2.5).floor() +
            (boxPrice * silverBonus).floor() -
            (materialPrice * value)) *
        deliveryCounts;

    if (stock == 0) {
      return Text(
        context.tr(
          "trade market.cooking_box out of stock",
          args: [revenue.format()],
        ),
        style: const TextStyle(color: Colors.red),
      );
    } else if (stock < value * deliveryCounts) {
      return Text(
        context.tr(
          "trade market.cooking_box low stock",
          args: [revenue.format()],
        ),
        style: const TextStyle(color: Colors.orange),
      );
    } else if (revenue <= 0) {
      return Text(
        revenue.format(),
        style: const TextStyle(color: Colors.orange),
      );
    }
    return Text(revenue.format());
  }
}
