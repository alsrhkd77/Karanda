import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../widgets/default_app_bar.dart';
import '../widgets/title_text.dart';

class MaterialCostCalculator extends StatefulWidget {
  const MaterialCostCalculator({Key? key}) : super(key: key);

  @override
  State<MaterialCostCalculator> createState() => _MaterialCostCalculatorState();
}

class _MaterialCostCalculatorState extends State<MaterialCostCalculator> {
  final numFormat = NumberFormat('###,###,###,###');
  final List<Map> items = [];

  int getTotalPrice(Map data) {
    int _price = data['trade'];
    if (data['count'].text.isNotEmpty) {
      _price = _price * int.parse(data['count'].text);
    } else {
      _price = _price * 0;
    }
    if (data['price'].text.isNotEmpty) {
      _price = _price * int.parse(data['price'].text);
    } else {
      _price = _price * 0;
    }
    return _price;
  }

  Widget itemTile(int index) {
    int _price = getTotalPrice(items[index]);
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              margin: const EdgeInsets.all(4.0),
              width: 100,
              child: TextField(
                controller: items[index]['count'],
                keyboardType: const TextInputType.numberWithOptions(),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^(\d{0,5})')),
                ],
                decoration: InputDecoration(
                  labelText: '필요 수량',
                  suffixText: '개',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(color: Colors.blue),
                  ),
                ),
                onChanged: (value) => setState(() {}),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(4.0),
              width: 120,
              child: TextField(
                controller: items[index]['price'],
                keyboardType: const TextInputType.numberWithOptions(),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^(\d{0,7})')),
                ],
                decoration: InputDecoration(
                  labelText: '개당 가격',
                  suffixText: '은화',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(color: Colors.blue),
                  ),
                ),
                onChanged: (value) => setState(() {}),
              ),
            ),
            Container(
              width: 65,
              margin: const EdgeInsets.all(4.0),
              child: DecoratedBox(
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue),
                    borderRadius: BorderRadius.circular(12.0)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: DropdownButton<String>(
                    value: '${items[index]['trade']}회',
                    underline: Container(),
                    focusColor: Colors.transparent,
                    onChanged: (String? value) {
                      if (value!.isEmpty) {
                        return;
                      }
                      setState(() {
                        items[index]['trade'] =
                            int.parse(value.split('').first);
                      });
                    },
                    items: ['0회', '1회', '2회', '3회', '4회', '5회', '6회']
                        .map<DropdownMenuItem<String>>((e) => DropdownMenuItem(
                              value: e,
                              child: Text(e),
                            ))
                        .toList(),
                  ),
                ),
              ),
            ),
            Expanded(
              child: AutoSizeText(
                '${numFormat.format(_price)} 은화',
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 16.0),
                minFontSize: 10.0,
                maxLines: 1,
              ),
            ),
            IconButton(
              icon: const Icon(
                FontAwesomeIcons.xmark,
                color: Colors.red,
              ),
              onPressed: () {
                setState(() {
                  items.removeAt(index);
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int _price = items
        .map((e) => getTotalPrice(e))
        .fold(0, (previousValue, element) => previousValue + element);
    return Scaffold(
      appBar: const DefaultAppBar(),
      body: GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.calculate),
                  title: TitleText('재료비 계산기'),
                ),
                TitleText('합계: ${numFormat.format(_price)} 은화'),
                const Divider(),
                Container(
                  constraints: const BoxConstraints(
                    maxWidth: 1400,
                  ),
                  child: Column(
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: items.length,
                        itemBuilder: (context, index) => itemTile(index),
                      ),
                      Card(
                        margin: const EdgeInsets.all(8.0),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(13.0),
                          child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(
                                    Icons.add,
                                    color: Colors.blue,
                                  ),
                                  SizedBox(
                                    width: 8.0,
                                    height: 60.0,
                                  ),
                                  Text('추가'),
                                ],
                              )),
                          onTap: () {
                            setState(() {
                              items.add({
                                'count': TextEditingController(),
                                'price': TextEditingController(),
                                'trade': 6
                              });
                            });
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
