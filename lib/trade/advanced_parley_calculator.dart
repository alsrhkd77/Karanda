import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:karanda/common/custom_scroll_behavior.dart';
import 'package:karanda/widgets/title_text.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdvancedParleyCalculator extends StatefulWidget {
  const AdvancedParleyCalculator({Key? key}) : super(key: key);

  @override
  State<AdvancedParleyCalculator> createState() =>
      _AdvancedParleyCalculatorState();
}

class _AdvancedParleyCalculatorState extends State<AdvancedParleyCalculator> {
  List<Map> parleyList = [
    {
      'parley': 0,
      'count': 0,
      'count text controller': TextEditingController(),
      'parley text controller': TextEditingController(),
    }
  ];

  NumberFormat numberFormat = NumberFormat('###,###,###,###');

  int get parley => parleyList.isEmpty
      ? 0
      : parleyList
          .map((e) => e['parley'] * e['count'])
          .reduce((value, element) => value + element);

  @override
  void initState() {
    super.initState();
    getParleyList();
  }

  Future<void> saveParleyList() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    List<String> _list = parleyList.map((e) => e['parley'].toString()).toList();
    sharedPreferences.setStringList('custom parley list', _list);
  }

  Future<bool> getParleyList() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    List<String> item =
        sharedPreferences.getStringList('custom parley list') ?? [];
    if (item.isNotEmpty) {
      List<Map> _item = item.map((e) {
        Map m = {
          'parley': int.parse(e),
          'count': 0,
          'count text controller': TextEditingController(),
          'parley text controller': TextEditingController(),
        };
        m['parley text controller'].text = e;
        return m;
      }).toList();
      setState(() {
        parleyList = _item;
      });
    }
    return true;
  }

  Widget buildParleyList() {
    return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: parleyList.length + 1,
        itemBuilder: (context, index) {
          if (index == parleyList.length) {
            return Card(
              margin: const EdgeInsets.all(8.0),
              elevation: 0,
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: Theme.of(context).colorScheme.outline,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(12)),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12.0),
                child: const Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Icon(Icons.add),
                ),
                onTap: () {
                  setState(() {
                    parleyList.add({
                      'parley': 0,
                      'count': 0,
                      'count text controller': TextEditingController(),
                      'parley text controller': TextEditingController(),
                    });
                  });
                },
              ),
            );
          }
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        constraints: const BoxConstraints(maxWidth: 160),
                        margin: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: TextField(
                          controller: parleyList[index]
                              ['parley text controller'],
                          keyboardType: const TextInputType.numberWithOptions(),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^(\d{0,6})')),
                          ],
                          decoration: InputDecoration(
                            labelText: '1회당 교섭력',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: const BorderSide(color: Colors.blue),
                            ),
                          ),
                          onChanged: (value) {
                            if (value.isEmpty) {
                              setState(() {
                                parleyList[index]['parley'] = 0;
                              });
                            } else {
                              setState(() {
                                parleyList[index]['parley'] = int.parse(value);
                              });
                            }
                            saveParleyList();
                          },
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        constraints: const BoxConstraints(maxWidth: 120),
                        margin: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: TextField(
                          controller: parleyList[index]
                              ['count text controller'],
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
                            saveParleyList();
                          },
                        ),
                      ),
                      IconButton(
                          onPressed: () {
                            if (parleyList[index]['count'] < 1000) {
                              parleyList[index]['count text controller'].text =
                                  (parleyList[index]['count'] + 1).toString();
                              setState(() {
                                parleyList[index]['count']++;
                              });
                            }
                            saveParleyList();
                          },
                          icon: const Icon(Icons.add_circle_outline)),
                      IconButton(
                          onPressed: () {
                            if (parleyList[index]['count'] > 0) {
                              parleyList[index]['count text controller'].text =
                                  (parleyList[index]['count'] - 1).toString();
                              setState(() {
                                parleyList[index]['count']--;
                              });
                            }
                            saveParleyList();
                          },
                          icon: const Icon(Icons.remove_circle_outline)),
                      SizedBox(
                        width: 90,
                        child: Text(
                            ' ${numberFormat.format(parleyList[index]['parley'] * parleyList[index]['count'])}'),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            parleyList.removeAt(index);
                          });
                          saveParleyList();
                        },
                        icon: const Icon(Icons.close),
                        color: Colors.red,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListView(
          padding: const EdgeInsets.all(12.0),
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          children: [
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
  }
}
