import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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

class MelodyOfStarsPage extends StatefulWidget {
  const MelodyOfStarsPage({super.key});

  @override
  State<MelodyOfStarsPage> createState() => _MelodyOfStarsPageState();
}

class _MelodyOfStarsPageState extends State<MelodyOfStarsPage> {
  Map melodyOfStars = {};
  List<TradeMarketDataModel> priceData = [];
  final List<int> transform = [1, 5, 25]; // 강화 단계별 별들의 선율 변환 갯수

  @override
  void initState() {
    super.initState();
    getBaseData();
  }

  Future<void> getBaseData() async {
    List data = jsonDecode(
        await rootBundle.loadString('assets/data/melody_of_stars.json'));
    Map result = {};
    for (Map item in data) {
      result[item["code"].toString()] = item;
    }
    setState(() {
      melodyOfStars = result;
    });
    getPriceData();
  }

  Future<void> getPriceData() async {
    Map<String, List<String>> param = {};
    for (String key in melodyOfStars.keys) {
      param[key] = ["1", "2", "3"]; // 장, 광, 고
    }
    List<TradeMarketDataModel> data =
        await TradeMarketProvider.getLatest(param);
    data.sort((a, b) {
      if ((a.currentStock > 0 && b.currentStock > 0) ||
          (a.currentStock == 0 && b.currentStock == 0)) {
        double aPrice = a.price / transform[a.enhancementLevel - 1];
        double bPrice = b.price / transform[b.enhancementLevel - 1];
        return aPrice.compareTo(bPrice);
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
      appBar: const DefaultAppBar(
        title: "통합 거래소 프리셋",
        icon: FontAwesomeIcons.scaleUnbalanced,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListTile(
                title: const TitleText('별들의 선율 재료'),
                trailing: IconButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) => const _ExchangeRateDialog());
                  },
                  icon: const Icon(Icons.help_outline),
                ),
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
                        return _ItemTile(data: priceData[index]);
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

  const _ItemTile({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    MarketItemModel? itemInfo =
        context.read<TradeMarketNotifier>().itemInfo[data.code.toString()];
    final format = NumberFormat('###,###,###,###');
    final List<int> transform = [1, 5, 25]; // 강화 단계별 별들의 선율 변환 갯수
    String stockStatus = data.currentStock == 0 ? ' (품절)' : '';
    if (itemInfo == null) return Container();
    return Card(
      clipBehavior: Clip.hardEdge,
      margin: const EdgeInsets.all(4.0),
      child: ListTile(
        onTap: () {
          context.goWithGa(
            '/trade-market/detail?name=${itemInfo.name}',
            extra: itemInfo.code.toString(),
          );
        },
        contentPadding:
            const EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
        leading: BdoItemImageWidget(
          code: data.code.toString(),
          size: 49,
          grade: 2,
          enhancementLevel:
              itemInfo.enhancementLevelToString(data.enhancementLevel),
        ),
        title: Text(itemInfo.nameWithEnhancementLevel(data.enhancementLevel)),
        subtitle: Text(
            '선율 1개당 ${format.format((data.price / transform[data.enhancementLevel - 1]).round())}'),
        trailing: Text(
          '${format.format(data.price)}$stockStatus',
          style: TextStyle(
            fontSize: 12,
            color: data.currentStock == 0 ? Colors.red : null,
          ),
        ),
      ),
    );
  }
}

class _ExchangeRateDialog extends StatelessWidget {
  const _ExchangeRateDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('변환 비율'),
      content: const Text('melody_of_stars_exchange_rate')
          .tr(args: ['1', '5', '25']),
    );
  }
}
