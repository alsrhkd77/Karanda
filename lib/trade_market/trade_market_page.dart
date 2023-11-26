import 'package:flutter/material.dart';
import 'package:karanda/trade_market/trade_market_notifier.dart';
import 'package:karanda/widgets/default_app_bar.dart';
import 'package:provider/provider.dart';

class TradeMarketPage extends StatefulWidget {
  const TradeMarketPage({super.key});

  @override
  State<TradeMarketPage> createState() => _TradeMarketPageState();
}

class _TradeMarketPageState extends State<TradeMarketPage> {
  Widget itemTile() {
    return ListTile(
      leading: Image.network(
          "https://s1.pearlcdn.com/KR/TradeMarket/Common/img/BDO/item/736118.png"),
      title: Text("아이템 이름"),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TradeMarketNotifier(),
      child: Consumer<TradeMarketNotifier>(
        builder: (_, notifier, __) {
          return Scaffold(
            appBar: DefaultAppBar(),
            body: Center(
              child: Column(
                children: [
                  itemTile(),
                  itemTile(),
                  itemTile(),
                  itemTile(),
                  itemTile(),
                  itemTile(),
                  itemTile(),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              child: Icon(Icons.refresh),
              onPressed: () {
                notifier.testApi();
              },
            ),
          );
        },
      ),
    );
  }
}
