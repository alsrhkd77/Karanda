import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:karanda/enums/bdo_region.dart';
import 'package:karanda/model/trade_market_preset_item.dart';
import 'package:karanda/ui/core/theme/dimes.dart';
import 'package:karanda/ui/core/ui/bdo_item_image.dart';
import 'package:karanda/ui/core/ui/karanda_app_bar.dart';
import 'package:karanda/ui/core/ui/loading_indicator.dart';
import 'package:karanda/ui/core/ui/page_base.dart';
import 'package:karanda/ui/trade_market/presets/controllers/trade_market_preset_controller.dart';
import 'package:karanda/utils/extension/build_context_extension.dart';
import 'package:karanda/utils/extension/go_router_extension.dart';
import 'package:karanda/utils/extension/int_extension.dart';
import 'package:provider/provider.dart';

class TradeMarketPresetPage extends StatelessWidget {
  final String presetKey;
  final BDORegion region;

  const TradeMarketPresetPage({
    super.key,
    required this.presetKey,
    required this.region,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TradeMarketPresetController(
        tradeMarketService: context.read(),
        key: presetKey,
        region: region,
      ),
      child: Scaffold(
        appBar: KarandaAppBar(
          title: context.tr("trade market.$presetKey"),
          icon: FontAwesomeIcons.scaleUnbalanced,
        ),
        body: Consumer(
          builder: (context, TradeMarketPresetController controller, child) {
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
                ListTile(
                  title: Text(context.tr("trade market.preset item name")),
                  trailing: Text(
                    context.tr("trade market.preset item price"),
                    style: TextTheme.of(context).bodyLarge,
                  ),
                ),
                ...controller.items!.map((item) {
                  return _ItemTile(
                    presetKey: presetKey,
                    item: item,
                    region: region,
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

class _ItemTile extends StatelessWidget {
  final String presetKey;
  final BDORegion region;
  final TradeMarketPresetItem item;


  const _ItemTile({
    super.key,
    required this.presetKey,
    required this.region,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final itemInfo = context.itemInfo(item.code.toString());
    final stockStatus = item.price!.currentStock > 0;
    return Card(
      margin: const EdgeInsets.all(4.0),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding: Dimens.listTileContentsPadding(),
        leading: BdoItemImage(
          code: itemInfo.code,
          enhancementLevel: item.enhancementLevel,
        ),
        title: Text(context.itemName(itemInfo.code, item.enhancementLevel)),
        subtitle: Text(context.tr(
                "trade market.$presetKey efficiency",
                args: [(item.price!.price / item.value).round().format()],
              )),
        trailing: stockStatus
            ? Text(item.price!.price.format())
            : Text(
                "${item.price!.price.format()} (${context.tr("trade market.preset item out of stock")})",
                style: const TextStyle(color: Colors.red),
              ),
        onTap: () {
          context
              .goWithGa("/trade-market/${region.name}/detail/${itemInfo.code}");
        },
      ),
    );
  }
}
