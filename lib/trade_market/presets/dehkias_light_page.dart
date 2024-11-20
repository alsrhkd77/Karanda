import 'dart:convert';

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

/// 관련 업데이트
/// https://www.kr.playblackdesert.com/ko-KR/News/Detail?groupContentNo=10718&countryType=ko-KR

class DehkiasLightPage extends StatefulWidget {
  const DehkiasLightPage({super.key});

  @override
  State<DehkiasLightPage> createState() => _DehkiasLightPageState();
}

class _DehkiasLightPageState extends State<DehkiasLightPage> {
  Map baseData = {};
  List<TradeMarketDataModel> priceData = [];

  @override
  void initState() {
    super.initState();
    getBaseData();
  }

  Future<void> getBaseData() async {
    List data = jsonDecode(
        await rootBundle.loadString('assets/data/dehkias_light.json'));
    Map items = {};
    for (Map item in data) {
      items['${item["code"]}_${item["enhancement_level"]}'] = item;
    }
    setState(() {
      baseData = items;
    });
    getPriceData();
  }

  Future<void> getPriceData() async {
    Map<String, List<String>> param = {};
    for (String key in baseData.keys) {
      if (!param.containsKey(baseData[key]["code"].toString())) {
        param[baseData[key]["code"].toString()] = [];
      }
      param[baseData[key]["code"].toString()]!
          .add(baseData[key]["enhancement_level"].toString());
    }
    List<TradeMarketDataModel> data =
        await TradeMarketProvider.getLatest(param);
    data.sort((a, b) {
      if ((a.currentStock > 0 && b.currentStock > 0) ||
          (a.currentStock == 0 && b.currentStock == 0)) {
        Map itemA = baseData['${a.code}_${a.enhancementLevel}'];
        Map itemB = baseData['${b.code}_${b.enhancementLevel}'];
        return (a.price / itemA["results"])
            .compareTo(b.price / itemB["results"]);
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
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: ListTile(
                title: TitleText('데키아의 불빛 재료'),
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
                          results: baseData[
                                  '${priceData[index].code}_${priceData[index].enhancementLevel}']
                              ['results'],
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
  final int results;

  const _ItemTile({super.key, required this.data, required this.results});

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
          grade: itemInfo.grade,
          enhancementLevel:
              itemInfo.enhancementLevelToString(data.enhancementLevel),
        ),
        title: Text(itemInfo.nameWithEnhancementLevel(data.enhancementLevel)),
        subtitle:
            Text('불빛 1개당 ${format.format((data.price / results).round())}'),
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
