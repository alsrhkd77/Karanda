import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:karanda/common/custom_scroll_behavior.dart';
import 'package:karanda/widgets/title_text.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NormalParleyCalculator extends StatefulWidget {
  const NormalParleyCalculator({Key? key}) : super(key: key);

  @override
  State<NormalParleyCalculator> createState() => _NormalParleyCalculatorState();
}

class _NormalParleyCalculatorState extends State<NormalParleyCalculator> {
  List<Map> parleyList = [
    {
      'name': '내해 교역',
      'parley': 14286,
      'decreased parley': 0,
      'count': 0,
      'txt controller': TextEditingController(),
    },
    {
      'name': '일반 교역',
      'parley': 14286,
      'decreased parley': 0,
      'count': 0,
      'txt controller': TextEditingController(),
    },
    {
      'name': '4단계 → 까마귀 주화',
      'parley': 21650,
      'decreased parley': 0,
      'count': 0,
      'txt controller': TextEditingController(),
    },
    {
      'name': '카슈마, 할마드',
      'parley': 29430,
      'decreased parley': 0,
      'count': 0,
      'txt controller': TextEditingController(),
    },
    {
      'name': '더코',
      'parley': 36420,
      'decreased parley': 0,
      'count': 0,
      'txt controller': TextEditingController(),
    },
    {
      'name': '하코번',
      'parley': 43780,
      'decreased parley': 0,
      'count': 0,
      'txt controller': TextEditingController(),
    },
    {
      'name': '난파된 하란의 수송선, 떠내려온 미완성 선박, 랑티니아의 전투 뗏목',
      'parley': 46544,
      'decreased parley': 0,
      'count': 0,
      'txt controller': TextEditingController(),
    },
    {
      'name': '파키오의 전투 뗏목, 까마귀 상단소유 선박, 난파된 릭쿤의 배, 난파된 콕스해적선, 난파된 해상군의 배',
      'parley': 58180,
      'decreased parley': 0,
      'count': 0,
      'txt controller': TextEditingController(),
    },
    {
      'name': '4단계 → 5단계 (마고리아)',
      'parley': 58180,
      'decreased parley': 0,
      'count': 0,
      'txt controller': TextEditingController(),
    },
  ];
  Map tradeLevelList = {
    '교역 레벨': {'name': '교역 레벨', 'decrease': 0.0},
  };
  String tradeLevel = '교역 레벨';
  NumberFormat numberFormat = NumberFormat('###,###,###,###');

  bool useValuePack = false;

  int get parley {
    int _total = 0;
    for (Map item in parleyList) {
      _total += (item['decreased parley'] * item['count']) as int;
    }
    return _total;
  }

  Future<bool> loadTradeLevelData() async {
    if (tradeLevelList.length > 1) {
      return true;
    }
    String jsonString = await http
        .get(Uri.parse(
            'https://raw.githubusercontent.com/HwanSangYeonHwa/Karanda/main/assets/assets/data/tradeLevel.json'))
        .then((response) => response.body);
    tradeLevelList.addAll(jsonDecode(jsonString));

    getTradeLevel();
    getValuePack();
    return true;
  }

  Future<void> getTradeLevel() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    String? _tradeLevel = sharedPreferences.getString('trade level');
    if (_tradeLevel != null && _tradeLevel.isNotEmpty) {
      setState(() {
        tradeLevel = _tradeLevel;
      });
    }
  }

  Future<void> saveTradeLevel() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    sharedPreferences.setString('trade level', tradeLevel);
  }

  Future<void> getValuePack() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    if (sharedPreferences.containsKey('use value pack')) {
      setState(() {
        useValuePack = sharedPreferences.getBool('use value pack')!;
      });
    }
  }

  Future<void> saveValuePack() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    sharedPreferences.setBool('use value pack', useValuePack);
  }

  Widget buildParleyList() {
    double _decrease = tradeLevelList[tradeLevel]['decrease'];
    if (useValuePack) {
      _decrease += 10;
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: parleyList.length,
      itemBuilder: (context, index) {
        parleyList[index]['decreased parley'] =
            (parleyList[index]['parley'] * (100 - _decrease) / 100).round();
        return Card(
          margin: const EdgeInsets.all(8.0),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    '[${numberFormat.format(parleyList[index]['decreased parley'])}] ${parleyList[index]['name']}'),
                Row(
                  children: [
                    Container(
                      constraints: const BoxConstraints(maxWidth: 120),
                      margin: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: TextField(
                        controller: parleyList[index]['txt controller'],
                        keyboardType: const TextInputType.numberWithOptions(),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^(\d{0,3})')),
                        ],
                        decoration: InputDecoration(
                          labelText: '교환 횟수',
                          suffixText: '회',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(color: Colors.blue),
                          ),
                        ),
                        onChanged: (value) {
                          if (value.isEmpty) {
                            setState(() {
                              parleyList[index]['count'] = 0;
                            });
                          } else {
                            setState(() {
                              parleyList[index]['count'] = int.parse(value);
                            });
                          }
                        },
                      ),
                    ),
                    IconButton(
                        onPressed: () {
                          if (parleyList[index]['count'] < 1000) {
                            parleyList[index]['txt controller'].text =
                                (parleyList[index]['count'] + 1).toString();
                            setState(() {
                              parleyList[index]['count']++;
                            });
                          }
                        },
                        icon: const Icon(Icons.add_circle_outline)),
                    IconButton(
                        onPressed: () {
                          if (parleyList[index]['count'] > 0) {
                            parleyList[index]['txt controller'].text =
                                (parleyList[index]['count'] - 1).toString();
                            setState(() {
                              parleyList[index]['count']--;
                            });
                          }
                        },
                        icon: const Icon(Icons.remove_circle_outline)),
                    SizedBox(
                      width: 90,
                      child: Text(
                          ' ${numberFormat.format(parleyList[index]['decreased parley'] * parleyList[index]['count'])}'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: loadTradeLevelData(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            heightFactor: 5,
            child: SpinKitFadingCube(
              size: 120.0,
              color: Colors.blue,
            ),
          );
        }
        return Column(
          children: [
            ListView(
              padding: const EdgeInsets.all(12.0),
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      constraints: const BoxConstraints(
                        maxWidth: 160,
                      ),
                      padding: const EdgeInsets.all(8.0),
                      child: DropdownButton(
                        focusColor: Colors.transparent,
                        menuMaxHeight: 600,
                        borderRadius: BorderRadius.circular(8.0),
                        value: tradeLevel,
                        items: tradeLevelList.keys
                            .map<DropdownMenuItem<String>>(
                                (e) => DropdownMenuItem(
                                    value: e,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(e),
                                    )))
                            .toList(),
                        onChanged: (String? value) {
                          if (value!.isEmpty) {
                            return;
                          }
                          setState(() {
                            tradeLevel = value;
                          });
                          saveTradeLevel();
                        },
                        isExpanded: true,
                      ),
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: useValuePack,
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                useValuePack = value;
                              });
                              saveValuePack();
                            }
                          },
                        ),
                        const Text('밸류 패키지 (10% 감소)'),
                      ],
                    )
                  ],
                ),
                Container(
                  margin: const EdgeInsets.all(24.0),
                  alignment: Alignment.center,
                  child: TitleText('필요 교섭력 합계: ${numberFormat.format(parley)}'),
                ),
                const Divider(),
              ],
            ),
            ScrollConfiguration(
              behavior: CustomScrollBehavior(),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Container(
                  width: MediaQuery.of(context).size.width - 20,
                  constraints: const BoxConstraints(
                    minWidth: 1050,
                    maxWidth: 1350,
                  ),
                  child: buildParleyList(),
                ),
              ),
            ),
            const SizedBox(
              height: 18.0,
            )
          ],
        );
      },
    );
  }
}
