import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:karanda/widgets/title_text.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum TileType { weight, trade }

class OverloadedShipTab extends StatefulWidget {
  const OverloadedShipTab({Key? key}) : super(key: key);

  @override
  State<OverloadedShipTab> createState() => _OverloadedShipTabState();
}

class _OverloadedShipTabState extends State<OverloadedShipTab> {
  bool advancedMode = false;
  final numFormat = NumberFormat('###,###,###,###');
  final List<int> goodsWeight = [100, 800, 900, 1000, 1000, 1];
  final List<int> simpleWeight = [for (int i = 0; i < 6; i++) 0];
  final List<Map> advancedWeight = [];
  final List<int> tradeRatio = [for (int i = 0; i < 6; i++) 1];
  TextEditingController totalTextController = TextEditingController();
  TextEditingController sailorTextController = TextEditingController();
  TextEditingController equipTextController = TextEditingController();
  List<TextEditingController> simpleTextController = [
    for (int i = 0; i < 6; i++) TextEditingController()
  ];
  int totalWeight = 20900;
  int sailorWeight = 500;
  int equipWeight = 9;

  @override
  void initState() {
    super.initState();
    getData();
  }

  void initValue() {
    totalTextController.text = totalWeight.toString();
    sailorTextController.text = sailorWeight.toString();
    equipTextController.text = equipWeight.toString();
  }

  Future<void> saveData() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    await sharedPreferences.setInt('overloadedShipTotalWeight', totalWeight);
    await sharedPreferences.setInt('overloadedShipSailorWeight', sailorWeight);
    await sharedPreferences.setInt('overloadedShipEquipWeight', equipWeight);
    await sharedPreferences.setBool('overloadedShipFormType', advancedMode);
  }

  Future<bool> getData() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    totalWeight =
        sharedPreferences.getInt('overloadedShipTotalWeight') ?? totalWeight;
    sailorWeight =
        sharedPreferences.getInt('overloadedShipSailorWeight') ?? sailorWeight;
    equipWeight =
        sharedPreferences.getInt('overloadedShipEquipWeight') ?? equipWeight;
    setState(() {
      advancedMode =
          sharedPreferences.getBool('overloadedShipFormType') ?? advancedMode;
    });
    initValue();
    return true;
  }

  MaterialColor selectColor(double percent) {
    if (percent > 1.7) return Colors.red;
    if (percent >= 1.0) return Colors.orange;
    return Colors.green;
  }

  Widget simpleBuilder() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12.0),
      constraints: const BoxConstraints(maxWidth: 1000),
      child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: goodsWeight.length,
          itemBuilder: (context, index) {
            return Card(
              margin: const EdgeInsets.all(8.0),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        index == 5
                            ? const Text('기타')
                            : Text('[${index + 1}단계 물교품]'),
                        index == 5
                            ? const SizedBox(width: 75)
                            : const SizedBox(width: 12),
                        SizedBox(
                          width: 120,
                          child: TextField(
                            controller: simpleTextController[index],
                            keyboardType:
                                const TextInputType.numberWithOptions(),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'^(\d{0,5})')),
                            ],
                            decoration: InputDecoration(
                              suffixText: index == 5 ? 'LT' : '개',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide:
                                    const BorderSide(color: Colors.blue),
                              ),
                            ),
                            onChanged: (value) {
                              if (value.isEmpty) {
                                setState(() {
                                  simpleWeight[index] = goodsWeight[index] * 0;
                                });
                              } else {
                                setState(() {
                                  simpleWeight[index] =
                                      goodsWeight[index] * int.parse(value);
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    Text('${numFormat.format(simpleWeight[index])} LT')
                  ],
                ),
              ),
            );
          }),
    );
  }

  Widget advancedTradeContents(int index) {
    int _weight = 0;
    if (advancedWeight[index]['grade'] == 1) {
      _weight = (goodsWeight[advancedWeight[index]['grade'] - 1] *
          advancedWeight[index]['count']) as int;
    } else {
      _weight = (goodsWeight[advancedWeight[index]['grade'] - 1] *
          advancedWeight[index]['count'] *
          advancedWeight[index]['ratio']) as int;
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue),
                  borderRadius: BorderRadius.circular(12.0)),
              child: DropdownButton<String>(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                borderRadius: BorderRadius.circular(12.0),
                value: advancedWeight[index]['grade'] == 1
                    ? '재료 → 1단계'
                    : '${advancedWeight[index]['grade'] - 1} → ${advancedWeight[index]['grade']}단계',
                underline: Container(),
                focusColor: Colors.transparent,
                onChanged: (String? value) {
                  if (value!.isEmpty) {
                    return;
                  }
                  setState(() {
                    advancedWeight[index]['grade'] =
                        int.parse(value.split(' ').last.split('').first);
                  });
                },
                items: ['재료 → 1단계', '1 → 2단계', '2 → 3단계', '3 → 4단계', '4 → 5단계']
                    .map<DropdownMenuItem<String>>((e) => DropdownMenuItem(
                          alignment: Alignment.center,
                          value: e,
                          child: Text(e),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(width: 12.0),
            advancedWeight[index]['grade'] != 1
                ? DecoratedBox(
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue),
                        borderRadius: BorderRadius.circular(12.0)),
                    child: DropdownButton<String>(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      borderRadius: BorderRadius.circular(12.0),
                      value: '1 : ${advancedWeight[index]['ratio']}',
                      underline: Container(),
                      focusColor: Colors.transparent,
                      onChanged: (String? value) {
                        if (value!.isEmpty) {
                          return;
                        }
                        setState(() {
                          advancedWeight[index]['ratio'] =
                              int.parse(value.split('').last);
                        });
                      },
                      items: ['1 : 1', '1 : 2', '1 : 3']
                          .map<DropdownMenuItem<String>>(
                              (e) => DropdownMenuItem(
                                    alignment: Alignment.center,
                                    value: e,
                                    child: Text(e),
                                  ))
                          .toList(),
                    ),
                  )
                : const SizedBox(),
            const SizedBox(width: 12.0),
            DecoratedBox(
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue),
                  borderRadius: BorderRadius.circular(12.0)),
              child: DropdownButton<String>(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                borderRadius: BorderRadius.circular(12.0),
                value: '${advancedWeight[index]['count']}회',
                underline: Container(),
                focusColor: Colors.transparent,
                onChanged: (String? value) {
                  if (value!.isEmpty) {
                    return;
                  }
                  setState(() {
                    advancedWeight[index]['count'] =
                        int.parse(value.replaceAll('회', ''));
                  });
                },
                items: [
                  '0회',
                  '1회',
                  '2회',
                  '3회',
                  '4회',
                  '5회',
                  '6회',
                  '7회',
                  '8회',
                  '9회',
                  '10회'
                ]
                    .map<DropdownMenuItem<String>>((e) => DropdownMenuItem(
                          alignment: Alignment.center,
                          value: e,
                          child: Text(e),
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
        Text('${numFormat.format(_weight)} LT'),
      ],
    );
  }

  Widget advancedWeightContents(int index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Text('기타'),
            const SizedBox(
              width: 12.0,
            ),
            SizedBox(
              width: 100,
              child: TextField(
                controller: advancedWeight[index]['text'],
                keyboardType: const TextInputType.numberWithOptions(),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^(\d{0,5})')),
                ],
                decoration: InputDecoration(
                  suffixText: 'LT',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(color: Colors.blue),
                  ),
                ),
                onChanged: (value) {
                  if (value.isEmpty) {
                    setState(() {
                      advancedWeight[index]['weight'] = 0;
                    });
                  } else {
                    setState(() {
                      advancedWeight[index]['weight'] = int.parse(value);
                    });
                  }
                },
              ),
            ),
          ],
        ),
        Text('${numFormat.format(advancedWeight[index]['weight'])} LT')
      ],
    );
  }

  Widget advancedBuilder() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12.0),
      constraints: const BoxConstraints(maxWidth: 1000),
      child: Column(
        children: [
          ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: advancedWeight.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12.0, horizontal: 24.0),
                    child: advancedWeight[index]['type'] == TileType.weight
                        ? advancedWeightContents(index)
                        : advancedTradeContents(index),
                  ),
                );
              }),
          Container(
            margin: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    child: Container(
                      margin: const EdgeInsets.all(8.0),
                      child: const Column(
                        children: [
                          Icon(Icons.add_circle_rounded, color: Colors.blue),
                          Text('물물교환')
                        ],
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        advancedWeight.add({
                          'type': TileType.trade,
                          'ratio': 1,
                          'grade': 3,
                          'count': 0,
                        });
                      });
                    },
                  ),
                ),
                Expanded(
                  child: InkWell(
                    child: Container(
                      margin: const EdgeInsets.all(8.0),
                      child: const Column(
                        children: [
                          Icon(Icons.add_circle_rounded, color: Colors.blue),
                          Text('직접입력')
                        ],
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        advancedWeight.add({
                          'type': TileType.weight,
                          'text': TextEditingController(),
                          'weight': 0,
                        });
                      });
                    },
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget buildPercent() {
    double percent = 0;
    int _nowWeight = 0;
    if (advancedMode) {
      for (Map m in advancedWeight) {
        if (m['type'] == TileType.trade) {
          if (m['grade'] == 1) {
            _nowWeight += (goodsWeight[m['grade'] - 1] * m['count']) as int;
          } else {
            _nowWeight +=
                (goodsWeight[m['grade'] - 1] * m['count'] * m['ratio']) as int;
          }
        }
        if (m['type'] == TileType.weight) {
          _nowWeight += m['weight'] as int;
        }
      }
    } else {
      for (int i in simpleWeight) {
        _nowWeight += i;
      }
    }
    int _weightSnapshot = sailorWeight + equipWeight + _nowWeight;
    if (totalWeight != 0 && _weightSnapshot != 0) {
      percent = _weightSnapshot / totalWeight;
    }
    return LinearPercentIndicator(
      percent: percent > 1 ? 1 : percent,
      barRadius: const Radius.circular(15.0),
      animation: true,
      animateFromLastPercent: true,
      animationDuration: 300,
      lineHeight: 22.0,
      progressColor: selectColor(percent),
      center: Text(
        '${numFormat.format(_weightSnapshot)} LT / ${numFormat.format(totalWeight)} LT (${(percent * 100).toStringAsFixed(2)}%)',
        style: const TextStyle(color: Colors.black),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(FontAwesomeIcons.weightHanging),
              title: const TitleText(
                '과적 계산기',
                bold: true,
              ),
              trailing: IconButton(
                onPressed: () {
                  setState(() {
                    advancedMode = !advancedMode;
                  });
                  saveData();
                },
                icon: Icon(
                  Icons.dynamic_form_outlined,
                  color: advancedMode ? Colors.blue : null,
                ),
              ),
            ),
            Container(
              constraints: const BoxConstraints(
                maxWidth: 1400,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: TextField(
                            controller: sailorTextController,
                            keyboardType:
                                const TextInputType.numberWithOptions(),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'^(\d{0,5})')),
                            ],
                            decoration: InputDecoration(
                              labelText: '선원 무게',
                              suffixText: 'LT',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide:
                                    const BorderSide(color: Colors.blue),
                              ),
                            ),
                            onChanged: (value) {
                              if (value.isNotEmpty) {
                                setState(() {
                                  sailorWeight = int.parse(value);
                                });
                                saveData();
                              }
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: TextField(
                            controller: equipTextController,
                            keyboardType:
                                const TextInputType.numberWithOptions(),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'^(\d{0,5})')),
                            ],
                            decoration: InputDecoration(
                              labelText: '장비 무게',
                              suffixText: 'LT',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide:
                                    const BorderSide(color: Colors.blue),
                              ),
                            ),
                            onChanged: (value) {
                              if (value.isNotEmpty) {
                                setState(() {
                                  equipWeight = int.parse(value);
                                });
                                saveData();
                              }
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: TextField(
                            controller: totalTextController,
                            keyboardType:
                                const TextInputType.numberWithOptions(),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'^(\d{0,5})')),
                            ],
                            decoration: InputDecoration(
                              labelText: '최대 무게',
                              suffixText: 'LT',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide:
                                    const BorderSide(color: Colors.blue),
                              ),
                            ),
                            onChanged: (value) {
                              if (value.isNotEmpty) {
                                setState(() {
                                  totalWeight = int.parse(value);
                                });
                                saveData();
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const ListTile(
                    title: TitleText('적재품목'),
                  ),
                  buildPercent(),
                  advancedMode ? advancedBuilder() : simpleBuilder(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
