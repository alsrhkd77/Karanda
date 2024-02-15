import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:karanda/common/api.dart';
import 'package:karanda/trade_market/trade_market_notifier.dart';
import 'package:karanda/trade_market/trade_market_wait_list_widget.dart';
import 'package:karanda/widgets/default_app_bar.dart';
import 'package:provider/provider.dart';

class TradeMarketPage extends StatefulWidget {
  const TradeMarketPage({super.key});

  @override
  State<TradeMarketPage> createState() => _TradeMarketPageState();
}

class _TradeMarketPageState extends State<TradeMarketPage> {
  Widget itemTile(String itemCode, String name) {
    return ListTile(
      leading: Image.network("${Api.itemImage}/$itemCode.png",
          height: 44,
          width: 44,
          fit: BoxFit.scaleDown,
          errorBuilder: (context, object, stackTrace) => Text("?"),
          cacheHeight: 44,
          cacheWidth: 44),
      title: Text(name),
      subtitle: Row(
        children: [
          Icon(
            FontAwesomeIcons.coins,
            size: 12,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text('1,000,000,000,000'),
          )
        ],
      ),
      trailing: Text('100,000,000'),
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
            body: CustomScrollView(
              slivers: [
                TradeMarketWaitListWidget(),
              ],
            ),
          );
        },
      ),
    );
  }
}
