import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:karanda/common/go_router_extension.dart';
import 'package:karanda/common/real_time_notifier.dart';
import 'package:karanda/trade_market/bdo_item_image_widget.dart';
import 'package:karanda/trade_market/market_item_model.dart';
import 'package:karanda/trade_market/trade_market_notifier.dart';
import 'package:karanda/trade_market/trade_market_wait_item.dart';
import 'package:karanda/trade_market/trade_market_wait_list_stream.dart';
import 'package:karanda/widgets/loading_indicator.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

class TradeMarketWaitListWidget extends StatefulWidget {
  const TradeMarketWaitListWidget({super.key});

  @override
  State<TradeMarketWaitListWidget> createState() =>
      _TradeMarketWaitListWidgetState();
}

class _TradeMarketWaitListWidgetState extends State<TradeMarketWaitListWidget>
    with WindowListener {
  final TradeMarketWaitListStream dataStream = TradeMarketWaitListStream();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((timeStamp) => dataStream.publish());
    windowManager.addListener(this);
  }

  @override
  void activate() {
    super.activate();
    //dataStream.connect();
  }

  @override
  void deactivate() {
    //dataStream.disconnect();
    super.deactivate();
  }

  @override
  void onWindowFocus() {
    //dataStream.connect();
  }

  @override
  void onWindowClose() {
    //dataStream.dispose();
  }

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
        if (snapshot.hasError) {
          return const SliverToBoxAdapter(
            child: LoadingIndicator(),
          );
        }
        if (snapshot.requireData.isEmpty) {
          return const SliverToBoxAdapter(
            child: Align(
              alignment: Alignment.center,
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Text("등록 대기중인 상품이 없습니다"),
              ),
            ),
          );
        }
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              return Center(
                child: _WaitItemTile(item: snapshot.requireData[index]),
              );
            },
            childCount: snapshot.requireData.length,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    //dataStream.dispose();
    windowManager.removeListener(this);
    super.dispose();
  }
}

class _WaitItemTile extends StatelessWidget {
  final TradeMarketWaitItem item;
  final format = NumberFormat('###,###,###,###,###');

  _WaitItemTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    MarketItemModel? itemInfo =
        context.read<TradeMarketNotifier>().itemInfo[item.itemCode.toString()];
    if (itemInfo == null) return Container();
    return Card(
      margin: const EdgeInsets.all(8.0),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: () {
          context.goWithGa(
            '/trade-market/detail?name=${itemInfo.name}',
            extra: itemInfo.code,
          );
        },
        contentPadding:
            const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
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
            const Icon(
              FontAwesomeIcons.coins,
              size: 12,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(format.format(item.price)),
            ),
          ],
        ),
        trailing: Consumer<RealTimeNotifier>(
          builder: (context, notifier, _) {
            int seconds = item.targetTime.difference(notifier.now).inSeconds;
            int minutes = (seconds / 60).floor();
            String text = '';
            if (seconds <= 0) {
              text = '등록됨';
            } else if (minutes > 0) {
              text = '$minutes분 ${seconds % 60}초';
            } else {
              text = '${seconds % 60}초';
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
