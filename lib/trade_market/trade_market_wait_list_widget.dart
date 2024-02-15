import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:karanda/common/api.dart';
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
          itemExtent: 50.0,
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
    MarketItemModel? itemInfo = context.read<TradeMarketNotifier>().itemInfo[item.itemCode.toString()];
    String? name = itemInfo?.name;
    return ListTile(
      leading: Image.network('${Api.itemImage}/${item.itemCode}.png'),
      title: Text(name ?? '???'),
      subtitle: Text(format.format(item.price)),
      trailing: Text(item.targetTime.toString()),
    );
  }
}
