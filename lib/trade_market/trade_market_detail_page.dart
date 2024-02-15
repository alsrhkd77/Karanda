import 'package:flutter/material.dart';
import 'package:karanda/common/api.dart';
import 'package:karanda/common/global_properties.dart';
import 'package:karanda/trade_market/trade_market_notifier.dart';
import 'package:karanda/widgets/default_app_bar.dart';
import 'package:karanda/widgets/loading_indicator.dart';
import 'package:karanda/widgets/title_text.dart';
import 'package:provider/provider.dart';

class TradeMarketDetailPage extends StatefulWidget {
  final String? code;
  final String? name;

  const TradeMarketDetailPage({super.key, this.code, this.name});

  @override
  State<TradeMarketDetailPage> createState() => _TradeMarketDetailPageState();
}

class _TradeMarketDetailPageState extends State<TradeMarketDetailPage> {
  late String code;
  late String name;


  @override
  void initState() {
    super.initState();
    code = widget.code ?? '';
    name = widget.name ?? '';
    print('code $code, name $name');
  }

  @override
  Widget build(BuildContext context) {
    if(context.watch<TradeMarketNotifier>().itemInfo.isEmpty){
      return LoadingIndicator();
    } else if(!context.watch<TradeMarketNotifier>().itemNames.containsKey(name)){
      return LoadingIndicator(); //error 없는 아이템
    }
    if(code.isEmpty){
      code = context.read<TradeMarketNotifier>().itemNames[name] ?? '';
    }
    return Scaffold(
      appBar: DefaultAppBar(),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: GlobalProperties.scrollViewPadding,
            sliver: SliverToBoxAdapter(
              child: ListTile(
                title: TitleText(name, bold: true),
                trailing: null,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Image.network('${Api.itemImage}/$code.png', width: 92, height: 92, fit: BoxFit.fitHeight),
          )
        ],
      ),
    );
  }
}
