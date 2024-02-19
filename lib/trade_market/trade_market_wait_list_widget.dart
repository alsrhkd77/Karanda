import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:karanda/trade_market/bdo_item_image_widget.dart';
import 'package:karanda/trade_market/market_item_model.dart';
import 'package:karanda/trade_market/trade_market_notifier.dart';
import 'package:karanda/trade_market/trade_market_wait_item.dart';
import 'package:karanda/trade_market/trade_market_wait_list_stream.dart';
import 'package:karanda/widgets/loading_indicator.dart';
import 'package:provider/provider.dart';

class TradeMarketWaitListWidget extends StatefulWidget {
  const TradeMarketWaitListWidget({super.key});

  @override
  State<TradeMarketWaitListWidget> createState() =>
      _TradeMarketWaitListWidgetState();
}

class _TradeMarketWaitListWidgetState extends State<TradeMarketWaitListWidget> {
  final TradeMarketWaitListStream dataStream = TradeMarketWaitListStream();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: dataStream.waitItemList,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SliverToBoxAdapter(
            child: LoadingIndicator(),
          );
        }
        return SliverFixedExtentList(
          delegate:
              SliverChildBuilderDelegate((BuildContext context, int index) {
            return _WaitItemTile(item: snapshot.requireData[index]);
          }, childCount: snapshot.requireData.length),
          itemExtent: 84.0,
        );
      },
    );
  }

  @override
  void dispose() {
    dataStream.dispose();
    super.dispose();
  }
}

class _WaitItemTile extends StatelessWidget {
  final TradeMarketWaitItem item;
  final format = NumberFormat('###,###,###,###');

  _WaitItemTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    MarketItemModel? itemInfo =
        context.read<TradeMarketNotifier>().itemInfo[item.itemCode.toString()];
    if (itemInfo == null) return Container();
    return Card(
      margin: EdgeInsets.all(8.0),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        //onTap: (){},
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: ListTile(
            leading: BdoItemImageWidget(
              code: item.itemCode.toString(),
              enhancementLevel:
                  itemInfo.enhancementLevelToString(item.enhancementLevel),
              grade: itemInfo.grade,
              size: 48,
            ),
            title: Text(itemInfo.nameWithEnhancementLevel(item.enhancementLevel)),
            subtitle: Row(
              children: [
                Icon(
                  FontAwesomeIcons.coins,
                  size: 12,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Text(format.format(item.price)),
                ),
              ],
            ),
            trailing: Text(item.targetTime.toString()),
          ),
        ),
      ),
    );
  }
}
