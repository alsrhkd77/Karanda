import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:karanda/widgets/title_text.dart';

class CrowCoinExchangeTab extends StatefulWidget {
  const CrowCoinExchangeTab({Key? key}) : super(key: key);

  @override
  State<CrowCoinExchangeTab> createState() => _CrowCoinExchangeTabState();
}

class _CrowCoinExchangeTabState extends State<CrowCoinExchangeTab> {
  final numFormat = NumberFormat('###,###,###,###');
  List<int> ratio = [for (int i = 0; i < 4; i++) 1];
  int count = 0;
  int price = 0;
  int crowCoin = 0;

  @override
  Widget build(BuildContext context) {
    double _ratio = 0; //1은화:n까마귀주화
    double _reverseRatio = 0; // 1까마귀주화:n은화
    if (count != 0 && price != 0 && crowCoin != 0) {
      _ratio = (ratio.reduce((value, element) => value * element) * crowCoin) /
          (count * price);
      _reverseRatio = (count * price) /
          (ratio.reduce((value, element) => value * element) * crowCoin);
    }
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const ListTile(
              leading: Icon(FontAwesomeIcons.coins),
              title: TitleText(
                '까마귀 주화 효율 계산기',
                bold: true,
              ),
            ),
            Container(
              constraints: const BoxConstraints(
                maxWidth: 1400,
              ),
              child: Column(
                children: [
                  Text(
                    '1단계 교역품 1개로 얻을 수 있는 까마귀 주화 = ${numFormat.format(ratio.reduce((value, element) => value * element) * crowCoin)} 까마귀 주화',
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.clip,
                  ),
                  Text(
                      '${numFormat.format(count * price)} 은화 = ${numFormat.format(ratio.reduce((value, element) => value * element) * crowCoin)} 까마귀 주화'),
                  Text(
                      '100,000,000 은화 = ${numFormat.format((100000000 * _ratio).floor())} 까마귀 주화'),
                  Text(
                      '100 까마귀 주화 = ${numFormat.format((100 * _reverseRatio).floor())} 은화'),
                  const Divider(),
                  Card(
                    margin: const EdgeInsets.all(8.0),
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 720),
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              const TitleText('재료 → 1단계'),
                              Container(
                                width: 100.0,
                                margin: const EdgeInsets.all(8.0),
                                child: TextField(
                                  keyboardType:
                                      const TextInputType.numberWithOptions(),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'^(\d{0,4})')),
                                  ],
                                  decoration: InputDecoration(
                                    labelText: '필요 수량',
                                    hintText: '1회',
                                    suffixText: '개',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                      borderSide:
                                          const BorderSide(color: Colors.blue),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    if (value.isEmpty) {
                                      setState(() {
                                        count = 0;
                                      });
                                    } else {
                                      setState(() {
                                        count = int.parse(value);
                                      });
                                    }
                                  },
                                ),
                              ),
                              Container(
                                width: 140.0,
                                margin: const EdgeInsets.all(8.0),
                                child: TextField(
                                  keyboardType:
                                      const TextInputType.numberWithOptions(),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'^(\d{0,8})')),
                                  ],
                                  decoration: InputDecoration(
                                    labelText: '개당 가격',
                                    suffixText: '은화',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                      borderSide:
                                          const BorderSide(color: Colors.blue),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    if (value.isEmpty) {
                                      setState(() {
                                        price = 0;
                                      });
                                    } else {
                                      setState(() {
                                        price = int.parse(value);
                                      });
                                    }
                                  },
                                ),
                              ),
                              const Text('1개'),
                            ],
                          ),
                          ListView.builder(
                            itemCount: ratio.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  TitleText('${index + 1}단계 → ${index + 2}단계'),
                                  Container(
                                    margin: const EdgeInsets.all(12.0),
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.blue),
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                      ),
                                      child: DropdownButton<String>(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 24.0),
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                        value: '1 : ${ratio[index]}',
                                        underline: Container(),
                                        focusColor: Colors.transparent,
                                        onChanged: (String? value) {
                                          if (value!.isEmpty) {
                                            return;
                                          }
                                          setState(() {
                                            ratio[index] =
                                                int.parse(value.split('').last);
                                          });
                                        },
                                        items: ['1 : 1', '1 : 2', '1 : 3']
                                            .map<DropdownMenuItem<String>>(
                                                (e) => DropdownMenuItem(
                                                      alignment:
                                                          Alignment.center,
                                                      value: e,
                                                      child: Text(e),
                                                    ))
                                            .toList(),
                                      ),
                                    ),
                                  ),
                                  Text(
                                      '${ratio.take(index + 1).reduce((value, element) => value * element)}개'),
                                ],
                              );
                            },
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              const TitleText('5단계 → 까마귀 주화'),
                              Container(
                                width: 140.0,
                                margin: const EdgeInsets.all(8.0),
                                child: TextField(
                                  keyboardType:
                                      const TextInputType.numberWithOptions(),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'^(\d{0,5})')),
                                  ],
                                  decoration: InputDecoration(
                                    labelText: '개당 가격',
                                    hintText: '1회 교환',
                                    suffixText: '주화',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                      borderSide:
                                          const BorderSide(color: Colors.blue),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    if (value.isEmpty) {
                                      setState(() {
                                        crowCoin = 0;
                                      });
                                    } else {
                                      setState(() {
                                        crowCoin = int.parse(value);
                                      });
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
