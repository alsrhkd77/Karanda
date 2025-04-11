import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:karanda/enums/bdo_region.dart';
import 'package:karanda/model/trade_market_price_data.dart';
import 'package:karanda/ui/core/ui/bdo_item_image.dart';
import 'package:karanda/ui/core/ui/karanda_app_bar.dart';
import 'package:karanda/ui/core/ui/loading_indicator.dart';
import 'package:karanda/ui/core/ui/page_base.dart';
import 'package:karanda/ui/core/ui/section.dart';
import 'package:karanda/ui/trade_market/controllers/trade_market_detail_controller.dart';
import 'package:karanda/utils/extension/build_context_extension.dart';
import 'package:karanda/utils/extension/int_extension.dart';
import 'package:provider/provider.dart';

class TradeMarketDetailPage extends StatelessWidget {
  final String code;
  final BDORegion region;

  const TradeMarketDetailPage({
    super.key,
    required this.code,
    required this.region,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TradeMarketDetailController(
        marketService: context.read(),
        itemInfoService: context.read(),
        code: code,
        region: region,
      ),
      child: Scaffold(
        appBar: KarandaAppBar(
          title: context.tr("trade market.trade market"),
          icon: FontAwesomeIcons.scaleUnbalanced,
        ),
        body: Consumer(
          builder: (context, TradeMarketDetailController controller, child) {
            if (controller.data == null) {
              return const LoadingIndicator();
            } else if (controller.itemInfo == null ||
                controller.data!.isEmpty) {
              return Center(
                child: Text(context.tr("trade market.failed to get data")),
              );
            }
            return PageBase(
              children: [
                ListTile(
                  title: Text(context.itemName(code)),
                  //subtitle: Text("${context.itemInfo(code).mainCategory} > ${context.itemInfo(code).subCategory}"),
                  trailing: DropdownMenu(
                    initialSelection: 0,
                    dropdownMenuEntries:
                        controller.enhancementLevels.map((level) {
                      return DropdownMenuEntry(
                        value: level,
                        label: context.itemName(code, level),
                      );
                    }).toList(),
                    onSelected: (int? value) {
                      if (value != null) {
                        controller.selectItem(value);
                      }
                    },
                  ),
                ),
                _Head(
                  code: code,
                  enhancementLevel: controller.selected,
                  latest: controller.latest,
                ),
                _PriceChart(
                  maxPrice: controller.maxPrice,
                  minPrice: controller.minPrice,
                  midPrice: controller.midPrice,
                  data: controller.prices.sublist(1),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Head extends StatelessWidget {
  final String code;
  final int enhancementLevel;
  final TradeMarketPriceData latest;

  const _Head({
    super.key,
    required this.code,
    required this.enhancementLevel,
    required this.latest,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = TextTheme.of(context).bodyLarge;
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Wrap(
        alignment: WrapAlignment.spaceEvenly,
        crossAxisAlignment: WrapCrossAlignment.center,
        direction: Axis.horizontal,
        children: [
          BdoItemImage(
            code: code,
            enhancementLevel: enhancementLevel,
            size: 74,
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text(context.tr("trade market.base price")),
                  trailing: Text(
                    latest.price.format(),
                    style: textStyle,
                  ),
                ),
                ListTile(
                  title: Text(context.tr("trade market.current stock")),
                  trailing: Text(
                    latest.currentStock.format(),
                    style: textStyle,
                  ),
                ),
                ListTile(
                  title: Text(context.tr("trade market.cumulative volume")),
                  trailing: Text(
                    latest.cumulativeVolume.format(),
                    style: textStyle,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceChart extends StatefulWidget {
  final int maxPrice;
  final int minPrice;
  final int midPrice;
  final List<TradeMarketPriceData> data;

  const _PriceChart({
    super.key,
    required this.maxPrice,
    required this.minPrice,
    required this.midPrice,
    required this.data,
  });

  @override
  State<_PriceChart> createState() => _PriceChartState();
}

class _PriceChartState extends State<_PriceChart> {
  final tooltipPadding = const EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 8,
  );
  final emptyTitle = const AxisTitles(
    sideTitles: SideTitles(showTitles: false),
  );
  final border = FlBorderData(
    show: true,
    border: const Border(
      left: BorderSide(color: Colors.grey),
      top: BorderSide(color: Colors.transparent),
      right: BorderSide(color: Colors.transparent),
      bottom: BorderSide(color: Colors.grey),
    ),
  );

  List<LineTooltipItem> getTooltipItems(List<LineBarSpot> spots) {
    final locale = context.locale.toStringWithSeparator();
    final textColor = Theme.of(context).brightness == Brightness.light
        ? Colors.white
        : Colors.black;
    return spots.map((spot) {
      final dateTime = DateTime.fromMillisecondsSinceEpoch(spot.x.toInt());
      return LineTooltipItem(
        "${DateFormat.yMMMMd(locale).format(dateTime)}\n",
        TextTheme.of(context).labelLarge?.copyWith(color: textColor) ??
            const TextStyle(),
        children: [
          TextSpan(
            text: context.tr(
              "trade market.silver",
              args: [spot.y.toInt().format()],
            ),
            style:
                TextTheme.of(context).labelMedium?.copyWith(color: textColor),
          ),
        ],
      );
    }).toList();
  }

  FlLine drawingLine(double value) {
    return FlLine(
      color: Colors.grey.withAlpha(25),
      strokeWidth: 1,
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    return _BottomTitle(
      dateTime: DateTime.fromMillisecondsSinceEpoch(value.toInt()),
      meta: meta,
      locale: context.locale.toStringWithSeparator(),
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    return SideTitleWidget(
      axisSide: meta.axisSide,
      //fitInside: SideTitleFitInsideData.fromTitleMeta(meta, distanceFromEdge: 0),
      child: Text(
        meta.formattedValue,
        textAlign: TextAlign.center,
        style: TextTheme.of(context).labelMedium,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data.length <= 2) {
      return Section(
        title: context.tr("trade market.price trends"),
        child: AspectRatio(
          aspectRatio: 2.7,
          child: Center(
            child: Text(context.tr("trade market.not enough data")),
          ),
        ),
      );
    }
    return Section(
      title: context.tr("trade market.price trends"),
      child: AspectRatio(
        aspectRatio: 2.7,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 24, 24, 12),
          child: LineChart(
            LineChartData(
              lineBarsData: [
                LineChartBarData(
                  show: true,
                  color: Colors.blue.shade400,
                  spots: widget.data.map((item) {
                    return FlSpot(
                      item.date.millisecondsSinceEpoch.toDouble(),
                      item.price.toDouble(),
                    );
                  }).toList(),
                  barWidth: 3,
                  isCurved: true,
                  isStrokeCapRound: false,
                  isStrokeJoinRound: false,
                  preventCurveOverShooting: true,
                  dotData: const FlDotData(show: false),
                ),
              ],
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  tooltipBgColor:
                      Theme.of(context).brightness == Brightness.light
                          ? Colors.black.withAlpha(153)
                          : Colors.white.withAlpha(210),
                  maxContentWidth: 160,
                  tooltipPadding: tooltipPadding,
                  getTooltipItems: getTooltipItems,
                  fitInsideVertically: true,
                  fitInsideHorizontally: true,
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                drawHorizontalLine: true,
                horizontalInterval: pow(
                  10,
                  max(widget.midPrice.toString().length - 1, 0),
                ).toDouble(),
                verticalInterval:
                    const Duration(days: 14).inMilliseconds.toDouble(),
                getDrawingHorizontalLine: drawingLine,
                getDrawingVerticalLine: drawingLine,
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: const Duration(days: 1).inMilliseconds.toDouble(),
                    getTitlesWidget: bottomTitleWidgets,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: widget.midPrice.toDouble(),
                    reservedSize: 54,
                    getTitlesWidget: leftTitleWidgets,
                  ),
                ),
                topTitles: emptyTitle,
                rightTitles: emptyTitle,
              ),
              borderData: border,
              minX: widget.data.last.date.millisecondsSinceEpoch.toDouble() -
                  const Duration(days: 1).inMilliseconds,
              maxX: widget.data.first.date.millisecondsSinceEpoch.toDouble() +
                  const Duration(days: 1).inMilliseconds,
              minY: widget.minPrice.toDouble() - (widget.maxPrice / 20),
              maxY: widget.maxPrice.toDouble() + (widget.maxPrice / 20),
              extraLinesData: ExtraLinesData(
                horizontalLines: [
                  HorizontalLine(
                    y: widget.midPrice.toDouble(),
                    color: Colors.red.withAlpha(127),
                    dashArray: [10, 10],
                  ),
                ],
              ),
            ),
            duration: const Duration(milliseconds: 500),
          ),
        ),
      ),
    );
  }
}

class _BottomTitle extends StatelessWidget {
  final DateTime dateTime;
  final TitleMeta meta;
  final String locale;

  const _BottomTitle({
    super.key,
    required this.dateTime,
    required this.meta,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    final text =
        dateTime.day == 1 ? DateFormat.MMM(locale).format(dateTime) : "";
    return SideTitleWidget(
      axisSide: meta.axisSide,
      fitInside: SideTitleFitInsideData.fromTitleMeta(meta),
      child: Text(text, style: TextTheme.of(context).bodyLarge),
    );
  }
}
