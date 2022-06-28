import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:karanda/widgets/default_app_bar.dart';
import 'package:karanda/widgets/title_text.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

enum InputMode { simple, advanced }

class OverloadedShipPage extends StatefulWidget {
  const OverloadedShipPage({Key? key}) : super(key: key);

  @override
  State<OverloadedShipPage> createState() => _OverloadedShipPageState();
}

class _OverloadedShipPageState extends State<OverloadedShipPage> {
  var inputMode = InputMode.simple;
  final numFormat = NumberFormat('###,###,###,###');
  final List<int> goodsWeight = [800, 800, 900, 1000, 1000, 1];
  TextEditingController totalTextController = TextEditingController();
  TextEditingController sailorTextController = TextEditingController();
  TextEditingController equipTextController = TextEditingController();
  List<TextEditingController> simpleTextController = [];
  int totalWeight = 20900;
  int sailorWeight = 500;
  int equipWeight = 9;
  int nowWeight = 0;

  @override
  void initState() {
    super.initState();
    totalTextController.text = totalWeight.toString();
    sailorTextController.text = sailorWeight.toString();
    equipTextController.text = equipWeight.toString();
  }

  void simpleWeightCalculation(){
    List _list = simpleTextController;
    int _weight = 0;
    for(int i=0;i<_list.length;i++){
      if(_list[i].text.isNotEmpty){
        _weight = _weight + (int.parse(_list[i].text) * goodsWeight[i]);
      }
    }
    setState((){
      nowWeight = _weight;
    });
  }

  MaterialColor selectColor(double percent){
    if(percent > 1.7) return Colors.red;
    if(percent >= 1.0) return Colors.orange;
    return Colors.green;
  }

  Widget simpleBuilder() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 1000),
      child: ListView.builder(
          shrinkWrap: true,
          itemCount: goodsWeight.length,
          itemBuilder: (context, index) {
            if (simpleTextController.length < index + 1) {
              simpleTextController.add(TextEditingController());
            }
            int _calc = 0;
            if (simpleTextController[index].text.isNotEmpty) {
              _calc = goodsWeight[index] *
                  int.parse(simpleTextController[index].text);
            }
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
                              simpleWeightCalculation();
                            },
                          ),
                        ),
                      ],
                    ),
                    Text('${numFormat.format(_calc)} LT')
                  ],
                ),
              ),
            );
          }),
    );
  }

  Widget buildPercent() {
    double percent = 0;
    int _weightSnapshot = sailorWeight + equipWeight + nowWeight;
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
          '${numFormat.format(_weightSnapshot)} LT / ${numFormat.format(totalWeight)} LT (${(percent * 100).toStringAsFixed(2)}%)'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DefaultAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              const ListTile(
                leading: Icon(FontAwesomeIcons.arrowRightArrowLeft),
                title: TitleText(
                  '과적 계산기',
                  bold: true,
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: TextField(
                        controller: sailorTextController,
                        keyboardType: const TextInputType.numberWithOptions(),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^(\d{0,5})')),
                        ],
                        decoration: InputDecoration(
                          labelText: '선원 무게',
                          suffixText: 'LT',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(color: Colors.blue),
                          ),
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            setState(() {
                              sailorWeight = int.parse(value);
                            });
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
                        keyboardType: const TextInputType.numberWithOptions(),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^(\d{0,5})')),
                        ],
                        decoration: InputDecoration(
                          labelText: '장비 무게',
                          suffixText: 'LT',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(color: Colors.blue),
                          ),
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            setState(() {
                              equipWeight = int.parse(value);
                            });
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
                        keyboardType: const TextInputType.numberWithOptions(),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^(\d{0,5})')),
                        ],
                        decoration: InputDecoration(
                          labelText: '최대 무게',
                          suffixText: 'LT',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(color: Colors.blue),
                          ),
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            setState(() {
                              totalWeight = int.parse(value);
                            });
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
              simpleBuilder(),
            ],
          ),
        ),
      ),
    );
  }
}
