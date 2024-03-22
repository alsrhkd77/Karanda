import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:karanda/common/global_properties.dart';
import 'package:karanda/common/go_router_extension.dart';
import 'package:karanda/trade_market/bdo_item_image_widget.dart';
import 'package:karanda/trade_market/trade_market_data_model.dart';
import 'package:karanda/trade_market/trade_market_provider.dart';
import 'package:karanda/widgets/default_app_bar.dart';
import 'package:karanda/widgets/loading_indicator.dart';
import 'package:karanda/widgets/title_text.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CookingBoxPage extends StatefulWidget {
  const CookingBoxPage({super.key});

  @override
  State<CookingBoxPage> createState() => _CookingBoxPageState();
}

class _CookingBoxPageState extends State<CookingBoxPage> {
  Map boxData = {};
  Map<String, List> priceData = {};
  String selected = '9856';
  int contributions = 200; //공헌도
  int proficiency = 1200; //요리 숙련도
  final TextEditingController _contributionsController =
      TextEditingController();
  final TextEditingController _proficiencyController = TextEditingController();
  final List<int> proficiencyList = [
    0,
    50,
    100,
    150,
    200,
    250,
    300,
    350,
    400,
    450,
    500,
    550,
    600,
    650,
    700,
    750,
    800,
    850,
    900,
    950,
    1000,
    1050,
    1100,
    1150,
    1200,
    1250,
    1300,
    1350,
    1400,
    1450,
    1500,
    1550,
    1600,
    1650,
    1700,
    1750,
    1800,
    1850,
    1900,
    1950,
    2000,
  ].reversed.toList();
  final List<double> additionalMarginList = [
    0.0,
    0.0185,
    0.0296,
    0.0433,
    0.0595,
    0.0784,
    0.0999,
    0.1239,
    0.1505,
    0.1798,
    0.2116,
    0.246,
    0.283,
    0.3226,
    0.3648,
    0.4096,
    0.457,
    0.5069,
    0.5595,
    0.6147,
    0.6724,
    0.7327,
    0.7957,
    0.8612,
    0.9293,
    0.9584,
    0.988,
    1.0181,
    1.0486,
    1.0795,
    1.1109,
    1.1428,
    1.1751,
    1.2078,
    1.241,
    1.2746,
    1.3087,
    1.3433,
    1.3783,
    1.4137,
    1.4496,
  ].reversed.toList();

  @override
  void initState() {
    super.initState();
    getUserData();
    getBoxData();
  }

  Future<void> getUserData() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    int? userContributions =
        sharedPreferences.getInt('cooking_box_user_contributions'); //공헌도
    int? userProficiency =
        sharedPreferences.getInt('cooking_box_user_proficiency'); //요리 숙련도
    if (userContributions != null || userProficiency != null) {
      contributions = userContributions ?? contributions;
      proficiency = userProficiency ?? proficiency;
    }
    setState(() {
      _contributionsController.text = contributions.toString();
      _proficiencyController.text = proficiency.toString();
    });
  }

  Future<void> updateContributions(String value) async {
    //공헌도
    if (value.isNotEmpty) {
      setState(() {
        contributions = int.parse(value);
      });
    }
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    sharedPreferences.setInt('cooking_box_user_contributions', contributions);
  }

  Future<void> updateProficiency(String value) async {
    //요리 숙련도
    if (value.isNotEmpty) {
      setState(() {
        proficiency = int.parse(value);
      });
      final SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      sharedPreferences.setInt('cooking_box_user_proficiency', proficiency);
    }
  }

  Future<void> getBoxData() async {
    List data =
        jsonDecode(await rootBundle.loadString('assets/data/cooking_box.json'));
    data = data.reversed.toList();
    Map result = {};
    for (Map box in data) {
      result[box["code"].toString()] = box;
      priceData[box["code"].toString()] = [];
    }
    setState(() {
      boxData = result;
      selected = boxData.keys.first;
    });
    getPriceData(selected);
  }

  Future<void> getPriceData(String key) async {
    Map<String, List<String>> param = {};
    for (Map item in boxData[key]["materials"]) {
      param[item["code"].toString()] = ['0'];
    }
    List<TradeMarketDataModel> data =
        await TradeMarketProvider.getLatest(param);
    data.sort((a, b) {
      if (a.currentStock > 0 && b.currentStock > 0) {
        Map itemA = boxData[key]["materials"]
            .firstWhere((element) => element["code"] == a.code);
        Map itemB = boxData[key]["materials"]
            .firstWhere((element) => element["code"] == b.code);
        return (a.price * itemA["needed"]).compareTo(b.price * itemB["needed"]);
      }
      return b.currentStock.compareTo(a.currentStock);
    });
    setState(() {
      priceData[key] = data;
    });
  }

  double getAdditionalMargin() {
    int skillSteps =
        proficiencyList.firstWhere((element) => proficiency >= element);
    return additionalMarginList[proficiencyList.indexOf(skillSteps)];
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double additionalMargin = getAdditionalMargin();
    return Scaffold(
      appBar: const DefaultAppBar(),
      body: boxData.isEmpty
          ? const Center(child: LoadingIndicator())
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListTile(
                      title: const TitleText('황납용 요리 가격'),
                      trailing: DropdownMenu<String>(
                        initialSelection: boxData.keys.first,
                        inputDecorationTheme: InputDecorationTheme(
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 12.0),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0)),
                        ),
                        dropdownMenuEntries: boxData.keys
                            .map<DropdownMenuEntry<String>>((e) =>
                                DropdownMenuEntry(
                                    value: e, label: boxData[e]["name"]))
                            .toList(),
                        onSelected: (String? value) {
                          if (value != null && boxData.containsKey(value)) {
                            setState(() {
                              selected = value;
                            });
                            if (priceData[value]!.isEmpty) {
                              getPriceData(value);
                            }
                          }
                        },
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.symmetric(
                    horizontal:
                        GlobalProperties.scrollViewHorizontalPadding(width),
                    vertical: 12.0,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      children: [
                        Container(
                          margin: const EdgeInsets.all(12.0),
                          constraints: const BoxConstraints(maxWidth: 140),
                          child: TextField(
                            keyboardType:
                                const TextInputType.numberWithOptions(),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'^(\d{0,3})')),
                            ],
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              labelText: '공헌도',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide:
                                    const BorderSide(color: Colors.blue),
                              ),
                            ),
                            controller: _contributionsController,
                            onChanged: updateContributions,
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.all(12.0),
                          constraints: const BoxConstraints(maxWidth: 140),
                          child: TextField(
                            keyboardType:
                                const TextInputType.numberWithOptions(),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'^(\d{0,4})')),
                            ],
                            textAlign: TextAlign.center,
                            controller: _proficiencyController,
                            decoration: InputDecoration(
                              labelText: '요리 숙련도',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide:
                                    const BorderSide(color: Colors.blue),
                              ),
                            ),
                            onChanged: updateProficiency,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.symmetric(
                      horizontal:
                          GlobalProperties.scrollViewHorizontalPadding(width)),
                  sliver: const SliverToBoxAdapter(
                    child: ListTile(
                      title: Text('요리'),
                      trailing: Text('예상 이윤'),
                    ),
                  ),
                ),
                priceData[selected]!.isEmpty
                    ? const SliverToBoxAdapter(
                        child: Center(child: LoadingIndicator()),
                      )
                    : SliverPadding(
                        padding: EdgeInsets.symmetric(
                          horizontal:
                              GlobalProperties.scrollViewHorizontalPadding(
                                  width),
                        ),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              TradeMarketDataModel price =
                                  priceData[selected]?[index];
                              return _ItemTile(
                                priceData: price,
                                foodData: boxData[selected]["materials"]
                                    .firstWhere((element) =>
                                        element["code"] == price.code),
                                boxCount: (contributions / 2).floor(),
                                additionalMargin: additionalMargin,
                                boxPrice:
                                    (boxData[selected]["price"] * 2.5).floor() +
                                        (boxData[selected]["price"] *
                                                additionalMargin)
                                            .floor(),
                              );
                            },
                            childCount: priceData[selected]?.length ?? 0,
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
  final TradeMarketDataModel priceData;
  final Map foodData;
  final int boxCount;
  final double additionalMargin;
  final int boxPrice;

  const _ItemTile(
      {super.key,
      required this.priceData,
      required this.foodData,
      required this.boxCount,
      required this.additionalMargin,
      required this.boxPrice});

  String _stockStatus() {
    if (priceData.currentStock == 0) {
      return ' (품절)';
    } else if (priceData.currentStock <
        boxCount * (foodData["needed"] as int)) {
      return ' (재고 부족)';
    } else {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final format = NumberFormat('###,###,###,###');
    final int materialCosts = priceData.price * foodData["needed"] as int;
    final int materialTotalCosts = materialCosts * boxCount;
    final int margin = (boxCount * boxPrice) - materialTotalCosts;
    final Color? color;
    if (priceData.currentStock == 0) {
      color = Colors.red;
    } else if (priceData.currentStock <
        boxCount * (foodData["needed"] as int)) {
      color = Colors.orangeAccent;
    } else if (margin < 0) {
      color = Colors.orangeAccent;
    } else {
      color = null;
    }

    return Card(
      clipBehavior: Clip.hardEdge,
      margin: const EdgeInsets.all(6.0),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
        onTap: () {
          context.goWithGa(
            '/trade-market/detail?name=${foodData["name"]}',
            extra: priceData.code.toString(),
          );
        },
        leading: BdoItemImageWidget(
          code: priceData.code.toString(),
          size: 49,
          grade: foodData["grade"],
        ),
        title: Text('${foodData["name"]} × ${foodData["needed"]}'),
        subtitle: Text(
            '${format.format(materialCosts)} (요리당 ${format.format(priceData.price)})'),
        trailing: Text(
          '${format.format(margin)}${_stockStatus()}',
          style: TextStyle(fontSize: 12, color: color),
        ),
      ),
    );
  }
}
