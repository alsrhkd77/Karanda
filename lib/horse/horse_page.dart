import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../horse/horse_controller.dart';
import '../horse/horse_info.dart';
import '../widgets/default_app_bar.dart';
import '../widgets/title_text.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class HorsePage extends StatefulWidget {
  const HorsePage({Key? key}) : super(key: key);

  @override
  State<HorsePage> createState() => _HorsePageState();
}

class _HorsePageState extends State<HorsePage> {
  final HorseInfo _horseInfo = HorseInfo();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HorseController>(
      init: HorseController(),
      builder: (horse) {
        return GestureDetector(
          onTap: (){
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Scaffold(
            appBar: const DefaultAppBar(),
            body: SingleChildScrollView(
              child: Center(
                child: Column(
                  children: [
                    const ListTile(
                      leading: Icon(FontAwesomeIcons.chessKnight),
                      title: TitleText('말 성장치 계산기', bold: true),
                    ),
                    Wrap(
                      spacing: 20.0,
                      children: [
                        Container(
                          margin: const EdgeInsets.all(12.0),
                          constraints: const BoxConstraints(maxWidth: 700),
                          child: ExpansionTile(
                            title: const TitleText('종류'),
                            subtitle: Text(horse.breed),
                            children: [
                              const Divider(),
                              const ListTile(
                                title: Text('꿈결 환상마'),
                              ),
                              RadioListTile<String>(
                                title: const Text('꿈결 아두아나트'),
                                value: '꿈결 아두아나트',
                                groupValue: horse.breed,
                                onChanged: (value) => horse.breed = value!,
                              ),
                              RadioListTile<String>(
                                title: const Text('꿈결 디네'),
                                value: '꿈결 디네',
                                groupValue: horse.breed,
                                onChanged: (value) => horse.breed = value!,
                              ),
                              const Divider(),
                              const ListTile(
                                title: Text('환상마'),
                              ),
                              RadioListTile<String>(
                                title: const Text('아두아나트'),
                                value: '아두아나트',
                                groupValue: horse.breed,
                                onChanged: (value) => horse.breed = value!,
                              ),
                              RadioListTile<String>(
                                title: const Text('디네'),
                                value: '디네',
                                groupValue: horse.breed,
                                onChanged: (value) => horse.breed = value!,
                              ),
                              RadioListTile<String>(
                                title: const Text('둠'),
                                value: '둠',
                                groupValue: horse.breed,
                                onChanged: (value) => horse.breed = value!,
                              ),
                            ],
                          ),
                        ),
                        /*
                    Container(
                      margin: EdgeInsets.all(12.0),
                      constraints: BoxConstraints(maxWidth: 720),
                      child: ExpansionTile(
                        title: const TitleText('장비'),
                        children: [
                          Divider(),
                          ListTile(
                            title: Text('꿈결 환상마'),
                          ),
                          RadioListTile<String>(
                            title: Text('꿈결 아두아나트'),
                            value: '꿈결 아두아나트',
                            groupValue: _horse,
                            onChanged: (value) {
                              setState(() {
                                _horse = value!;
                              });
                            },
                          ),
                          RadioListTile<String>(
                            title: Text('꿈결 디네'),
                            value: '꿈결 디네',
                            groupValue: _horse,
                            onChanged: (value) {
                              setState(() {
                                _horse = value!;
                              });
                            },
                          ),
                          Divider(),
                          ListTile(
                            title: Text('환상마'),
                          ),
                          RadioListTile<String>(
                            title: Text('아두아나트'),
                            value: '아두아나트',
                            groupValue: _horse,
                            onChanged: (value) {
                              setState(() {
                                _horse = value!;
                              });
                            },
                          ),
                          RadioListTile<String>(
                            title: Text('디네'),
                            value: '디네',
                            groupValue: _horse,
                            onChanged: (value) {
                              setState(() {
                                _horse = value!;
                              });
                            },
                          ),
                          RadioListTile<String>(
                            title: Text('둠'),
                            value: '둠',
                            groupValue: _horse,
                            onChanged: (value) {
                              setState(() {
                                _horse = value!;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                     */
                        Container(
                          margin: const EdgeInsets.all(12.0),
                          constraints: const BoxConstraints(maxWidth: 700),
                          child: ExpansionTile(
                            title: const TitleText('성장치'),
                            childrenPadding: const EdgeInsets.all(30.0),
                            children: [
                              ListTile(
                                leading: const Text('레벨'),
                                title: TextFormField(
                                  decoration: const InputDecoration(
                                    hintText: ' * 30레벨 까지만 성장치가 상승합니다.'
                                  ),
                                  keyboardType:
                                      const TextInputType.numberWithOptions(),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'^(\d{0,3})')),
                                  ],
                                  initialValue: horse.level > 0
                                      ? horse.level.toString()
                                      : null,
                                  onChanged: (value) {
                                    if (value.isEmpty) {
                                      horse.level = 0;
                                    } else {
                                      horse.level = int.parse(value);
                                    }
                                  },
                                ),
                              ),
                              ListTile(
                                leading: const Text('속도'),
                                title: TextFormField(
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'^(\d{0,3})?\.?\d{0,2}')),
                                  ],
                                  initialValue: horse.speed > 0
                                      ? horse.speed.toString()
                                      : null,
                                  onChanged: (value) {
                                    if (value.isEmpty) {
                                      horse.speed = 0.0;
                                    } else {
                                      horse.speed = double.parse(value);
                                    }
                                  },
                                ),
                                trailing: Text(
                                    ' 기본: ${_horseInfo.detail[horse.breed]!['속도']} '),
                              ),
                              ListTile(
                                leading: const Text('가속'),
                                title: TextFormField(
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'^(\d{0,3})?\.?\d{0,2}')),
                                  ],
                                  initialValue: horse.acceleration > 0
                                      ? horse.acceleration.toString()
                                      : null,
                                  onChanged: (value) {
                                    if (value.isEmpty) {
                                      horse.acceleration = 0.0;
                                    } else {
                                      horse.acceleration = double.parse(value);
                                    }
                                  },
                                ),
                                trailing: Text(
                                    ' 기본: ${_horseInfo.detail[horse.breed]!['가속']} '),
                              ),
                              ListTile(
                                leading: const Text('회전'),
                                title: TextFormField(
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'^(\d{0,3})?\.?\d{0,2}')),
                                  ],
                                  initialValue: horse.rotForce > 0
                                      ? horse.rotForce.toString()
                                      : null,
                                  onChanged: (value) {
                                    if (value.isEmpty) {
                                      horse.rotForce = 0.0;
                                    } else {
                                      horse.rotForce = double.parse(value);
                                    }
                                  },
                                ),
                                trailing: Text(
                                    ' 기본: ${_horseInfo.detail[horse.breed]!['회전']} '),
                              ),
                              ListTile(
                                leading: const Text('제동'),
                                title: TextFormField(
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'^(\d{0,3})?\.?\d{0,2}')),
                                  ],
                                  initialValue: horse.brake > 0
                                      ? horse.brake.toString()
                                      : null,
                                  onChanged: (value) {
                                    if (value.isEmpty) {
                                      horse.brake = 0.0;
                                    } else {
                                      horse.brake = double.parse(value);
                                    }
                                  },
                                ),
                                trailing: Text(
                                    ' 기본: ${_horseInfo.detail[horse.breed]!['제동']} '),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.all(12.0),
                          constraints: const BoxConstraints(maxWidth: 700),
                          child: Card(
                            elevation: 3.0,
                            child: Container(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.all(8.0),
                                    child: const Text(
                                      '결과',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18.0),
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Chip(
                                          label: const Text('최상급'),
                                          backgroundColor: horse.grade == '최상급'
                                              ? Colors.blue
                                              : null,
                                        ),
                                        Chip(
                                          label: const Text('상급'),
                                          backgroundColor: horse.grade == '상급'
                                              ? Colors.blue
                                              : null,
                                        ),
                                        Chip(
                                          label: const Text('중급'),
                                          backgroundColor: horse.grade == '중급'
                                              ? Colors.blue
                                              : null,
                                        ),
                                        Chip(
                                          label: const Text('하급'),
                                          backgroundColor: horse.grade == '하급'
                                              ? Colors.blue
                                              : null,
                                        ),
                                        Chip(
                                          label: const Text('최하급'),
                                          backgroundColor: horse.grade == '최하급'
                                              ? Colors.blue
                                              : null,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: 400,
                                    height: 400,
                                    margin: const EdgeInsets.all(12.0),
                                    child: RadarChart(
                                      RadarChartData(
                                        dataSets: [
                                          RadarDataSet(
                                            dataEntries: [
                                              const RadarEntry(value: 100),
                                              const RadarEntry(value: 100),
                                              const RadarEntry(value: 100),
                                              const RadarEntry(value: 100),
                                            ],
                                            borderColor: Colors.blueAccent,
                                            fillColor: Colors.blueAccent
                                                .withOpacity(0.5),
                                            borderWidth: 1.0,
                                            entryRadius: 1.0,
                                          ),
                                          RadarDataSet(
                                            dataEntries: [
                                              RadarEntry(value: horse.speedPercent),
                                              RadarEntry(
                                                  value: horse.accelerationPercent),
                                              RadarEntry(value: horse.rotForcePercent),
                                              RadarEntry(value: horse.brakePercent),
                                            ],
                                            borderColor: Colors.green,
                                            fillColor:
                                                Colors.green.withOpacity(0.5),
                                            borderWidth: 2.0,
                                            entryRadius: 2.0,
                                          ),
                                          RadarDataSet(
                                            dataEntries: [
                                              const RadarEntry(value: 0),
                                              const RadarEntry(value: 0),
                                              const RadarEntry(value: 0),
                                              const RadarEntry(value: 0),
                                            ],
                                            borderColor: Colors.red,
                                            fillColor:
                                                Colors.red.withOpacity(0.5),
                                            borderWidth: 1.0,
                                            entryRadius: 1.0,
                                          ),
                                        ],
                                        getTitle: (index) {
                                          switch (index) {
                                            case 0:
                                              return '속도';
                                            case 1:
                                              return '가속';
                                            case 2:
                                              return '회전';
                                            case 3:
                                              return '제동';
                                            default:
                                              return '';
                                          }
                                        },
                                        titlePositionPercentageOffset: 0.1,
                                        tickCount: 10,
                                        ticksTextStyle:
                                            const TextStyle(fontSize: 10.0, color: Colors.transparent),
                                        tickBorderData: const BorderSide(
                                            color: Colors.transparent),
                                        radarBorderData: const BorderSide(
                                            color: Colors.transparent),
                                        gridBorderData: BorderSide(
                                            color: Colors.black.withOpacity(0.2)),
                                        borderData: FlBorderData(show: false),
                                      ),
                                      swapAnimationDuration:
                                          const Duration(milliseconds: 200),
                                      swapAnimationCurve: Curves.linear,
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Text('레벨: ${horse.level}'),
                                        Text(
                                            '성장치 합: ${horse.grownStat.toStringAsFixed(2)}'),
                                        Text(
                                            '평균 성장치: ${horse.average.toStringAsFixed(2)}'),
                                      ],
                                    ),
                                  ),
                                  DataTable(
                                    columns: const <DataColumn>[
                                      DataColumn(
                                        label: Text(
                                          '능력치',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          '입력값',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          '평균 성장치',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          '등급',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                    rows: <DataRow>[
                                      DataRow(
                                        cells: <DataCell>[
                                          const DataCell(Text(
                                            '속도',
                                            style: TextStyle(
                                                fontStyle: FontStyle.italic),
                                          )),
                                          DataCell(Text(
                                              horse.speed.toStringAsFixed(2))),
                                          DataCell(Text(
                                              horse.speedAvg.toStringAsFixed(2))),
                                          DataCell(Text(horse.speedGrade)),
                                        ],
                                      ),
                                      DataRow(
                                        cells: <DataCell>[
                                          const DataCell(Text(
                                            '가속',
                                            style: TextStyle(
                                                fontStyle: FontStyle.italic),
                                          )),
                                          DataCell(Text(horse.acceleration
                                              .toStringAsFixed(2))),
                                          DataCell(Text(horse.accelerationAvg
                                              .toStringAsFixed(2))),
                                          DataCell(Text(horse.accelerationGrade)),
                                        ],
                                      ),
                                      DataRow(
                                        cells: <DataCell>[
                                          const DataCell(Text(
                                            '회전',
                                            style: TextStyle(
                                                fontStyle: FontStyle.italic),
                                          )),
                                          DataCell(Text(
                                              horse.rotForce.toStringAsFixed(2))),
                                          DataCell(Text(horse.rotForceAvg
                                              .toStringAsFixed(2))),
                                          DataCell(Text(horse.rotForceGrade)),
                                        ],
                                      ),
                                      DataRow(
                                        cells: <DataCell>[
                                          const DataCell(Text(
                                            '제동',
                                            style: TextStyle(
                                                fontStyle: FontStyle.italic),
                                          )),
                                          DataCell(Text(
                                              horse.brake.toStringAsFixed(2))),
                                          DataCell(Text(
                                              horse.brakeAvg.toStringAsFixed(2))),
                                          DataCell(Text(horse.brakeGrade)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
