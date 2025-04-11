import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:karanda/enums/bdo_region.dart';
import 'package:karanda/model/trade_market_wait_item.dart';
import 'package:karanda/ui/core/theme/dimes.dart';
import 'package:karanda/ui/core/ui/bdo_item_image.dart';
import 'package:karanda/ui/core/ui/loading_indicator.dart';
import 'package:karanda/ui/trade_market/controllers/trade_market_wait_list_controller.dart';
import 'package:karanda/utils/extension/build_context_extension.dart';
import 'package:karanda/utils/extension/go_router_extension.dart';
import 'package:karanda/utils/extension/int_extension.dart';
import 'package:provider/provider.dart';

class TradeMarketWaitListWidget extends StatelessWidget {
  const TradeMarketWaitListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TradeMarketWaitListController(
        marketService: context.read(),
        timeRepository: context.read(),
      ),
      child: Selector(
        selector: (context, TradeMarketWaitListController controller) =>
        controller.items,
        builder: (context, List<TradeMarketWaitItem>? items, child) {
          final region = context.region;
          if (items == null || region == null) {
            return const LoadingIndicator();
          } else if (items.isEmpty) {
            return Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(context.tr("trade market.wait list empty")),
              ),
            );
          }
          return ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: items.length,
            itemBuilder: (context, index) {
              return Center(
                child: _WaitItemTile(
                  region: region,
                  item: items[index],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _WaitItemTile extends StatelessWidget {
  final TradeMarketWaitItem item;
  final BDORegion region;

  const _WaitItemTile({super.key, required this.item, required this.region});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(4.0),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: () {
          context.goWithGa(
              '/trade-market/${region.name}/detail/${item.itemCode}');
        },
        contentPadding: Dimens.listTileContentsPadding(),
        leading: BdoItemImage(
          code: item.itemCode.toString(),
          enhancementLevel: item.enhancementLevel,
        ),
        title: Text(context.itemName(
          item.itemCode.toString(),
          item.enhancementLevel,
        )),
        subtitle: Row(
          children: [
            const Icon(
              FontAwesomeIcons.coins,
              size: 12,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(item.price.format()),
            ),
          ],
        ),
        trailing: Selector(
          selector: (context, TradeMarketWaitListController controller) =>
              controller.now,
          builder: (context, DateTime now, child) {
            int seconds = item.targetTime.difference(now).inSeconds;
            int minutes = (seconds / 60).floor();
            String text = '';
            if (seconds <= 0) {
              text = context.tr("trade market.wait list complete");
            } else if (minutes > 0) {
              text = context.tr(
                "trade market.remaining min sec",
                namedArgs: {
                  "minutes": minutes.toString(),
                  "seconds": "${seconds % 60}",
                },
              );
            } else {
              text = context.tr(
                "trade market.remaining sec",
                args: ["${seconds % 60}"],
              );
            }
            return Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: seconds <= 0 ? Colors.green.shade400 : null,
              ),
            );
          },
        ),
      ),
    );
  }
}
