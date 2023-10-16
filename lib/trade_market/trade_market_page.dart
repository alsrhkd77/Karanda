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
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TradeMarketNotifier(),
      child: Consumer<TradeMarketNotifier>(
        builder: (_, notifier, __){
          return Scaffold(
            appBar: DefaultAppBar(),
            body: Center(
              child: Container(),
            ),
            floatingActionButton: FloatingActionButton(
              child: Icon(Icons.refresh),
              onPressed: (){
                notifier.getData();
              },
            ),
          );
        },
      ),
    );
  }
}
