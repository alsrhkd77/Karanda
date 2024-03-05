import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:karanda/common/date_time_extension.dart';
import 'package:karanda/common/global_properties.dart';
import 'package:karanda/trade_market/bdo_item_image_widget.dart';
import 'package:karanda/trade_market/market_item_model.dart';
import 'package:karanda/trade_market/trade_market_data_model.dart';
import 'package:karanda/trade_market/trade_market_detail_stream.dart';
import 'package:karanda/trade_market/trade_market_notifier.dart';
import 'package:karanda/widgets/default_app_bar.dart';
import 'package:karanda/widgets/loading_indicator.dart';
import 'package:karanda/widgets/loading_page.dart';
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
  TradeMarketDetailStream? dataStream;
  String selected = '';

  @override
  void initState() {
    super.initState();
    code = widget.code ?? '';
    name = widget.name ?? '';
  }

  @override
  Widget build(BuildContext context) {
    if (context.watch<TradeMarketNotifier>().itemInfo.isEmpty) {
      return const LoadingPage();
    } else if (!context
        .watch<TradeMarketNotifier>()
        .itemNames
        .containsKey(name)) {
      return const LoadingPage(); //error 없는 아이템
    }
    if (code.isEmpty) {
      code = context.read<TradeMarketNotifier>().itemNames[name] ?? '';
    }
    dataStream ??= TradeMarketDetailStream(
        item: context.watch<TradeMarketNotifier>().itemInfo[code]!);
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        appBar: const DefaultAppBar(),
        body: StreamBuilder(
            stream: dataStream?.marketDetailData,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: LoadingIndicator(),
              );
            } else if (snapshot.hasError) {
              return const Center(
                child: TitleText('정보를 가져오는데 실패했습니다!'),
              );
            }
            double horizontalPadding =
            GlobalProperties.scrollViewHorizontalPadding(
                MediaQuery.of(context).size.width);
            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: GlobalProperties.scrollViewPadding,
                  sliver: const SliverToBoxAdapter(
                    child: ListTile(
                      leading: Icon(FontAwesomeIcons.scaleUnbalanced),
                      title: TitleText(
                        '거래소 아이템 상세',
                        bold: true,
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding, vertical: 12.0),
                  sliver: SliverToBoxAdapter(
                    child: ListTile(
                      title: TitleText(
                        name,
                        bold: true,
                      ),
                      subtitle: Text(context
                          .watch<TradeMarketNotifier>()
                          .itemInfo[code]!
                          .category),
                      trailing: snapshot.data!.keys.length <= 1 ? null : DropdownMenu<String>(
                        initialSelection: '',
                        inputDecorationTheme: InputDecorationTheme(
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 12.0),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0)),
                        ),
                        dropdownMenuEntries: snapshot.data!.keys
                            .map<DropdownMenuEntry<String>>(
                                (e) => DropdownMenuEntry(
                              value: e,
                              label:
                              '${MarketItemModel.convertEnhancementLevel(e)}$name',
                            ))
                            .toList(),
                        onSelected: (String? value) {
                          if (value != null &&
                              snapshot.data!.containsKey(value)) {
                            setState(() {
                              selected = value;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding, vertical: 12.0),
                  sliver: _Head(
                    data: snapshot.data![selected]!.first,
                    itemInfo: context.watch<TradeMarketNotifier>().itemInfo[code]!,
                    enhancementLevel: selected,
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  sliver: const SliverToBoxAdapter(
                    child: ListTile(
                      title: TitleText('가격 추이'),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  sliver: _PriceChart(data: snapshot.data![selected]!.sublist(1)),
                ),
                SliverPadding(padding: GlobalProperties.scrollViewPadding),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    dataStream?.dispose();
    super.dispose();
  }
}

class _Head extends StatelessWidget {
  final TradeMarketDataModel data;
  final String enhancementLevel;
  final MarketItemModel itemInfo;
  final format = NumberFormat('###,###,###,###');

  _Head({super.key, required this.data, required this.enhancementLevel, required this.itemInfo});

  @override
  Widget build(BuildContext context) {
    final textStyle = const TextStyle(fontSize: 16.0);
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Wrap(
          alignment: WrapAlignment.spaceEvenly,
          crossAxisAlignment: WrapCrossAlignment.center,
          direction: Axis.horizontal,
          children: [
            BdoItemImageWidget(code: itemInfo.code, size: 74, enhancementLevel: enhancementLevel, grade: itemInfo.grade),
            SizedBox(
              width: 280,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    title: const Text('기준가'),
                    trailing: Text(
                      format.format(data.price),
                      style: textStyle,
                    ),
                  ),
                  ListTile(
                    title: const Text('판매 대기'),
                    trailing: Text(
                      format.format(data.currentStock),
                      style: textStyle,
                    ),
                  ),
                  ListTile(
                    title: const Text('누적 거래량'),
                    trailing: Text(
                      format.format(data.cumulativeVolume),
                      style: textStyle,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _PriceChart extends StatelessWidget {
  final List<TradeMarketDataModel> data;
  final format = NumberFormat('###,###,###,###');

  _PriceChart({super.key, required this.data});

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );
    String text = '';
    DateTime target = DateTime.fromMillisecondsSinceEpoch(value.toInt());
    if (target.day == 1) {
      //text = DateFormat.MMMM().format(target); // ex) December
      text = DateFormat.MMM().format(target); // ex) Dec
      //text = '${target.year} / ${target.month}';
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      fitInside: SideTitleFitInsideData.fromTitleMeta(meta),
      child: Text(text, style: style),
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    return SideTitleWidget(
      axisSide: meta.axisSide,
      //fitInside: SideTitleFitInsideData.fromTitleMeta(meta, distanceFromEdge: 0),
      child: Text(meta.formattedValue, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
    );
  }

  int getDigits(int number) {
    int count = 0;
    while (number > 0) {
      number = (number / 10).round();
      count++;
    }
    count = count - 2;
    return count > 0 ? count : 0;
  }

  LineTooltipItem getLineTooltipItem(LineBarSpot spot, Color textColor) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(spot.x.toInt());
    return LineTooltipItem(
      '${dateTime.format("yyyy/MM/dd")}\n',
      TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      textAlign: TextAlign.left,
      children: [
        TextSpan(
          text: format.format(spot.y.toInt()),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.normal,
            color: textColor,
          ),
        ),
        TextSpan(
          text: " 은화",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.normal,
            color: textColor,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final int maxPrice = data.map<int>((e) => e.price).reduce(max);
    final int minPrice = data.map<int>((e) => e.price).reduce(min);
    final int midPrice = minPrice + ((maxPrice - minPrice) / 2).round();
    final int digits = getDigits(maxPrice);
    return SliverToBoxAdapter(
      child: AspectRatio(
        aspectRatio: 2.7,
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 24, 24, 12),
            child: LineChart(
              LineChartData(
                lineBarsData: [
                  LineChartBarData(
                    show: true,
                    color: Colors.blue.shade400,
                    spots: data
                        .map<FlSpot>((e) => FlSpot(
                            e.date.millisecondsSinceEpoch.toDouble(),
                            e.price.toDouble()))
                        .toList(),
                    barWidth: 3,
                    isCurved: true,
                    curveSmoothness: 0.1,
                    isStrokeCapRound: false,
                    isStrokeJoinRound: false,
                    dotData: const FlDotData(show: false),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                      tooltipBgColor:
                          Theme.of(context).brightness == Brightness.light
                              ? Colors.black.withOpacity(0.6)
                              : Colors.white.withOpacity(0.9),
                      maxContentWidth: 160,
                      tooltipPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      getTooltipItems: (List<LineBarSpot> touchBarSpots) {
                        return touchBarSpots
                            .map((e) => getLineTooltipItem(
                                e,
                                Theme.of(context).brightness == Brightness.light
                                    ? Colors.white.withOpacity(0.75)
                                    : Colors.black.withOpacity(0.8)))
                            .toList();
                      }),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  drawHorizontalLine: true,
                  horizontalInterval: pow(10, digits).toDouble(),
                  verticalInterval:
                      const Duration(days: 14).inMilliseconds.toDouble(),
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withOpacity(0.1),
                      strokeWidth: 1,
                    );
                  },
                  getDrawingVerticalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withOpacity(0.1),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval:
                          const Duration(days: 1).inMilliseconds.toDouble(),
                      getTitlesWidget: bottomTitleWidgets,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      //interval: pow(10, digits).toDouble(),
                      interval: midPrice.toDouble(),
                      getTitlesWidget: leftTitleWidgets,
                      reservedSize: 54,
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: const Border(
                    left: BorderSide(color: Color(0xff37434d)),
                    top: BorderSide(color: Colors.transparent),
                    right: BorderSide(color: Colors.transparent),
                    bottom: BorderSide(color: Color(0xff37434d)),
                  ),
                  //border: Border.all(color: const Color(0xff37434d)),
                ),
                minX: data.last.date.millisecondsSinceEpoch.toDouble() -
                    const Duration(days: 1).inMilliseconds,
                maxX: data.first.date.millisecondsSinceEpoch.toDouble() +
                    const Duration(days: 1).inMilliseconds,
                minY: minPrice.toDouble() - (maxPrice / 20),
                maxY: maxPrice.toDouble() + (maxPrice / 20),
                extraLinesData: ExtraLinesData(horizontalLines: [
                  HorizontalLine(
                      y: midPrice.toDouble(),
                      color: Colors.red.withOpacity(0.5),
                      dashArray: [10, 10]),
                ]),
              ),
              duration: const Duration(milliseconds: 500),
            ),
          ),
        ),
      ),
    );
  }
}
