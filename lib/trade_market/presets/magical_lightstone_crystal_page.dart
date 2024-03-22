import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:karanda/common/global_properties.dart';
import 'package:karanda/common/go_router_extension.dart';
import 'package:karanda/trade_market/bdo_item_image_widget.dart';
import 'package:karanda/trade_market/market_item_model.dart';
import 'package:karanda/trade_market/trade_market_data_model.dart';
import 'package:karanda/trade_market/trade_market_notifier.dart';
import 'package:karanda/trade_market/trade_market_provider.dart';
import 'package:karanda/widgets/default_app_bar.dart';
import 'package:karanda/widgets/loading_indicator.dart';
import 'package:karanda/widgets/title_text.dart';
import 'package:provider/provider.dart';

class MagicalLightstoneCrystalPage extends StatefulWidget {
  const MagicalLightstoneCrystalPage({super.key});

  @override
  State<MagicalLightstoneCrystalPage> createState() =>
      _MagicalLightstoneCrystalPageState();
}

class _MagicalLightstoneCrystalPageState
    extends State<MagicalLightstoneCrystalPage> {
  Map baseData = {};
  List<TradeMarketDataModel> priceData = [];


  @override
  void initState() {
    super.initState();
    getBaseData();
  }

  Future<void> getBaseData() async {
    Map data = jsonDecode(await rootBundle
        .loadString('assets/data/magical_lightstone_crystal.json'));
    setState(() {
      baseData = data;
    });
    getPriceData();
  }

  Future<void> getPriceData() async {
    Map<String, List<String>> param = {};
    for (String code in baseData.keys) {
      param[code] = ['0'];
    }
    List<TradeMarketDataModel> data =
        await TradeMarketProvider.getLatest(param);
    data.sort((a, b) {
      if ((a.currentStock > 0 && b.currentStock > 0) ||
          (a.currentStock == 0 && b.currentStock == 0)) {
        Map itemA = baseData[a.code.toString()];
        Map itemB = baseData[b.code.toString()];
        return (a.price / itemA["received"])
            .compareTo(b.price / itemB["received"]);
      }
      return b.currentStock.compareTo(a.currentStock);
    });
    setState(() {
      priceData = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: const DefaultAppBar(),
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: ListTile(
                title: TitleText('마력의 광명석 결정 재료'),
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(
                horizontal:
                    GlobalProperties.scrollViewHorizontalPadding(width)),
            sliver: const SliverToBoxAdapter(
              child: ListTile(
                title: Text('품목'),
                trailing: Text('현재 기준가'),
              ),
            ),
          ),
          priceData.isEmpty
              ? const SliverToBoxAdapter(
                  child: Center(child: LoadingIndicator()),
                )
              : SliverPadding(
                  padding: EdgeInsets.symmetric(
                    horizontal:
                        GlobalProperties.scrollViewHorizontalPadding(width),
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return _ItemTile(
                          data: priceData[index],
                          received: baseData[priceData[index].code.toString()]['received'],
                        );
                      },
                      childCount: priceData.length,
                    ),
                  ),
                ),
          SliverPadding(
            padding: GlobalProperties.scrollViewPadding,
          ),
        ],
      ),
    );
  }
}

class _ItemTile extends StatelessWidget {
  final TradeMarketDataModel data;
  final int received;

  const _ItemTile({super.key, required this.data, required this.received});

  @override
  Widget build(BuildContext context) {
    MarketItemModel? itemInfo =
        context.read<TradeMarketNotifier>().itemInfo[data.code.toString()];
    final format = NumberFormat('###,###,###,###');
    String stockStatus = data.currentStock == 0 ? ' (품절)' : '';
    if (itemInfo == null) return Container();
    return Card(
      clipBehavior: Clip.hardEdge,
      margin: const EdgeInsets.all(6.0),
      child: InkWell(
        onTap: () {
          context.goWithGa(
            '/trade-market/detail?name=${itemInfo.name}',
            extra: itemInfo.code.toString(),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: ListTile(
            leading: BdoItemImageWidget(
              code: data.code.toString(),
              size: 49,
              grade: itemInfo.grade,
              enhancementLevel:
                  itemInfo.enhancementLevelToString(data.enhancementLevel),
            ),
            title:
                Text(itemInfo.nameWithEnhancementLevel(data.enhancementLevel)),
            subtitle: Text('결정 1개당 ${format.format((data.price / received).round())}'),
            trailing: Text(
              '${format.format(data.price)}$stockStatus',
              style: TextStyle(
                fontSize: 12,
                color: data.currentStock == 0 ? Colors.red : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
