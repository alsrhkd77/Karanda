import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:karanda/widgets/default_app_bar.dart';
import 'package:karanda/widgets/title_text.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ParleyCalculatorPage extends StatefulWidget {
  const ParleyCalculatorPage({Key? key}) : super(key: key);

  @override
  State<ParleyCalculatorPage> createState() => _ParleyCalculatorPageState();
}

class _ParleyCalculatorPageState extends State<ParleyCalculatorPage> {
  List<Map> parleyList = [
    {
      'name': '내해 교역',
      'parley': 10320,
      'decreased parley': 0,
      'count': 0,
      'txt controller': TextEditingController(),
    },
    {
      'name': '[마고]까주',
      'parley': 43200,
      'decreased parley': 0,
      'count': 0,
      'txt controller': TextEditingController(),
    },
    {
      'name': '[마고]4 → 5단',
      'parley': 43200,
      'decreased parley': 0,
      'count': 0,
      'txt controller': TextEditingController(),
    }
  ];
  NumberFormat numberFormat = NumberFormat('###,###,###,###');

  TextEditingController decreaseTextEditingController = TextEditingController();

  bool useValuePack = false;
  double decrease = 0.0;

  @override
  void initState() {
    super.initState();
    getDecrease();
  }

  int get parley {
    int _total = 0;
    for(Map item in  parleyList){
      _total += (item['decreased parley'] * item['count']) as int;
    }
    return _total;
  }

  Future<void> getDecrease() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    double? _decrease = sharedPreferences.getDouble('parley decrease');
    if (_decrease != null) {
      decreaseTextEditingController.text = _decrease.toString();
      setState(() {
        decrease = _decrease;
      });
    }
  }

  Future<void> saveDecrease() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    String text = decreaseTextEditingController.text.trim();
    if (text.isEmpty) {
      text = '0.0';
    }
    sharedPreferences.setDouble('parley decrease', double.parse(text));
    setState(() {
      decrease = double.parse(text);
    });
  }

  Widget buildParleyList() {
    double _decrease = decrease;
    if (useValuePack) {
      _decrease += 10;
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: parleyList.length,
      itemBuilder: (context, index) {
        parleyList[index]['decreased parley'] = (parleyList[index]['parley'] * (100 - _decrease) / 100).round();
        return Row(
          children: [
            Expanded(
              child: Card(
                margin: const EdgeInsets.all(8.0),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${parleyList[index]['name']} (${numberFormat.format(parleyList[index]['decreased parley'])})'),
                      Row(
                        children: [
                          Container(
                            constraints: const BoxConstraints(maxWidth: 100),
                            margin: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: TextField(
                              controller: parleyList[index]['txt controller'],
                              keyboardType:
                              const TextInputType.numberWithOptions(),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'^(\d{0,3})')),
                              ],
                              decoration: InputDecoration(
                                labelText: '교환 횟수',
                                suffixText: '회',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide:
                                  const BorderSide(color: Colors.blue),
                                ),
                              ),
                              onChanged: (value) {
                                if(value.isEmpty){
                                  setState(() {
                                    parleyList[index]['count'] = 0;
                                  });
                                }else{
                                  setState(() {
                                    parleyList[index]['count'] = int.parse(value);
                                  });
                                }
                              },
                            ),
                          ),
                          IconButton(
                              onPressed: () {
                                if(parleyList[index]['count'] < 1000){
                                  parleyList[index]['txt controller'].text = (parleyList[index]['count'] + 1).toString();
                                  setState(() {
                                    parleyList[index]['count']++;
                                  });
                                }
                              },
                              icon: const Icon(Icons.add_circle_outline)),
                          IconButton(
                              onPressed: () {
                                if(parleyList[index]['count'] > 0){
                                  parleyList[index]['txt controller'].text = (parleyList[index]['count'] - 1).toString();
                                  setState(() {
                                    parleyList[index]['count']--;
                                  });
                                }
                              },
                              icon: const Icon(Icons.remove_circle_outline)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 90,
                child: Text('= ${numberFormat.format(parleyList[index]['decreased parley'] * parleyList[index]['count'])}'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DefaultAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const ListTile(
              leading: Icon(FontAwesomeIcons.solidHandshake),
              title: TitleText(
                '교섭력 계산기',
                bold: true,
              ),
            ),
            Container(
              constraints: const BoxConstraints(maxWidth: 1400),
              child: Column(
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
                              maxWidth: 250,
                            ),
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              controller: decreaseTextEditingController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'^(\d{0,3})?\.?\d{0,2}')),
                              ],
                              decoration: InputDecoration(
                                labelText: '교섭력 감소량',
                                suffixText: '%',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide:
                                      const BorderSide(color: Colors.blue),
                                ),
                              ),
                              onChanged: (value) {
                                saveDecrease();
                              },
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
                                  }
                                },
                              ),
                              const Text('밸류 패키지 사용 (10% 감소)'),
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
                  buildParleyList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
