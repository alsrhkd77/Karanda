import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:karanda/common/global_properties.dart';
import 'package:karanda/horse_status/horse_status_data_controller.dart';
import 'package:karanda/horse_status/models/horse_equipment.dart';
import 'package:karanda/horse_status/models/horse.dart';
import 'package:karanda/horse_status/models/horse_status.dart';
import 'package:karanda/widgets/default_app_bar.dart';
import 'package:karanda/widgets/loading_indicator.dart';
import 'package:karanda/widgets/title_text.dart';

class HorseStatusPage extends StatefulWidget {
  const HorseStatusPage({super.key});

  @override
  State<HorseStatusPage> createState() => _HorseStatusPageState();
}

class _HorseStatusPageState extends State<HorseStatusPage> {
  final HorseStatusDataController dataController = HorseStatusDataController();
  bool dataLoaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => ready());
  }

  Future<void> ready() async {
    await dataController.getBaseData();
    setState(() {
      dataLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DefaultAppBar(),
      body: dataLoaded
          ? SingleChildScrollView(
              child: Column(
                children: [
                  const ListTile(
                    leading: Icon(FontAwesomeIcons.stickerMule),
                    title: TitleText('말 성장치 계산기', bold: true),
                  ),
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: GlobalProperties.widthConstrains,
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(),
                              _BreedSelector(
                                breeds: dataController.breeds,
                                onSelected: dataController.selectBreed,
                              ),
                            ],
                          ),
                        ),
                        _EquipmentCard(dataController: dataController),
                        _PearlEquipmentCard(dataController: dataController),
                        _StatusInputCard(dataController: dataController),
                        _ResultCard(dataController: dataController),
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "* 등급컷 - 최상급: 0.85, 상급: 0.81, 중급: 0.78, 하급: 0.75",
                            style: TextStyle(color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(
                          height: 12.0,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            )
          : const LoadingIndicator(),
    );
  }
}

class _BreedSelector extends StatelessWidget {
  final List<Horse> breeds;
  final Function(String) onSelected;

  const _BreedSelector(
      {super.key, required this.breeds, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<String>(
      initialSelection: breeds.first.nameEN,
      dropdownMenuEntries: breeds
          .map<DropdownMenuEntry<String>>(
            (e) => DropdownMenuEntry(
              value: e.nameEN,
              label: e.nameKR,
            ),
          )
          .toList(),
      onSelected: (String? value) {
        if (value != null) {
          onSelected(value);
        }
      },
    );
  }
}

class _EquipmentCard extends StatelessWidget {
  final HorseStatusDataController dataController;

  const _EquipmentCard({super.key, required this.dataController});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: dataController.selectedEquipments,
      builder: (context, selected) {
        if (!selected.hasData) {
          return Container();
        }
        return _ExpansionCard(
          title: '마구',
          child: Column(
            children: selected.requireData.keys
                .map(
                  (e) => ListTile(
                    title: _EquipmentDropdownMenu(
                      type: e,
                      items: dataController.equipments[e]!,
                      selected: selected.requireData[e]!,
                      onSelected: dataController.selectEquipments,
                    ),
                    leading: _EnhancementDropdownMenu(
                      type: e,
                      selected: selected.requireData[e]!.enhancementLevel,
                      onSelected: dataController.setEnhancementLevel,
                    ),
                    trailing: Text(
                      e,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }
}

class _EquipmentDropdownMenu extends StatelessWidget {
  final List<HorseEquipment> items;
  final HorseEquipment selected;
  final String type;
  final Function(String, String) onSelected;

  const _EquipmentDropdownMenu(
      {super.key,
      required this.items,
      required this.onSelected,
      required this.type,
      required this.selected});

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<String>(
      initialSelection: selected.nameEN,
      //width: 240,
      textStyle: const TextStyle(fontSize: 14.0),
      dropdownMenuEntries: items
          .map<DropdownMenuEntry<String>>(
            (e) => DropdownMenuEntry(
              value: e.nameEN,
              label: e.nameKR,
            ),
          )
          .toList(),
      onSelected: (String? value) {
        if (value != null) {
          onSelected(type, value);
        }
      },
    );
  }
}

class _EnhancementDropdownMenu extends StatelessWidget {
  final String type;
  final int selected;
  final Function(String, int) onSelected;

  const _EnhancementDropdownMenu({
    super.key,
    required this.type,
    required this.onSelected,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<int>(
      initialSelection: selected,
      width: 84,
      textStyle: const TextStyle(fontSize: 14.0),
      dropdownMenuEntries: List.generate(
          11, (index) => DropdownMenuEntry(value: index, label: '+$index')),
      onSelected: (int? value) {
        if (value != null) {
          onSelected(type, value);
        }
      },
    );
  }
}

class _PearlEquipmentCard extends StatelessWidget {
  final HorseStatusDataController dataController;

  const _PearlEquipmentCard({super.key, required this.dataController});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: dataController.selectedPearlEquipments,
        builder: (context, selected) {
          if (!selected.hasData) {
            return const LoadingIndicator();
          }
          return _ExpansionCard(
            title: '펄 마구',
            child: Column(
              children: dataController.pearlEquipments.keys
                  .map((e) => ListTile(
                        leading: Checkbox(
                          value: selected.requireData[e],
                          onChanged: (bool? value) {
                            if (value != null) {
                              dataController.setPearlEquipments(e, value);
                            }
                          },
                        ),
                        title: Text(dataController.pearlEquipments[e]!.nameKR),
                      ))
                  .toList(),
            ),
          );
        });
  }
}

class _ExpansionCard extends StatefulWidget {
  final String title;
  final Widget child;

  const _ExpansionCard({super.key, required this.title, required this.child});

  @override
  State<_ExpansionCard> createState() => _ExpansionCardState();
}

class _ExpansionCardState extends State<_ExpansionCard> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            ListTile(
              title: Text(widget.title),
              trailing: IconButton(
                  icon: Icon(isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down),
                  onPressed: () {
                    setState(() {
                      isExpanded = !isExpanded;
                    });
                  }),
            ),
            isExpanded ? const Divider() : Container(),
            isExpanded ? widget.child : Container(),
          ],
        ),
      ),
    );
  }
}

class _StatusInputCard extends StatefulWidget {
  final HorseStatusDataController dataController;

  const _StatusInputCard({super.key, required this.dataController});

  @override
  State<_StatusInputCard> createState() => _StatusInputCardState();
}

class _StatusInputCardState extends State<_StatusInputCard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((timeStamp) => widget.dataController.subscribe());
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: widget.dataController.selectedBreed,
        builder: (context, breed) {
          if (!breed.hasData) {
            return const LoadingIndicator();
          }
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  const ListTile(
                    title: Text('성장치'),
                  ),
                  const Divider(),
                  Container(
                    constraints: const BoxConstraints(maxWidth: 540),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Text(
                            '레벨',
                            style: TextStyle(fontSize: 14),
                          ),
                          title: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: TextField(
                              decoration: const InputDecoration(
                                  hintText: ' * 30레벨 까지 성장치가 상승합니다.'),
                              keyboardType:
                                  const TextInputType.numberWithOptions(),
                              textAlign: TextAlign.center,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'^(\d{0,3})')),
                              ],
                              onChanged: (String? value) {
                                int parsed = 0;
                                if (value != null) {
                                  parsed = int.tryParse(value) ?? 0;
                                }
                                widget.dataController.setLevel(parsed);
                              },
                            ),
                          ),
                        ),
                        ListTile(
                          leading: const Text(
                            '속도',
                            style: TextStyle(fontSize: 14),
                          ),
                          title: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: TextField(
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              textAlign: TextAlign.center,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'^(\d{0,3})?\.?\d{0,2}')),
                              ],
                              onChanged: (String? value) {
                                double parsed = 0.0;
                                if (value != null) {
                                  parsed = double.tryParse(value) ?? 0.0;
                                }
                                widget.dataController.setSpeed(parsed);
                              },
                            ),
                          ),
                          trailing: Text(
                            '기본: ${breed.requireData.spec.speed}',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        ListTile(
                          leading: const Text(
                            '가속',
                            style: TextStyle(fontSize: 14),
                          ),
                          title: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: TextField(
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              textAlign: TextAlign.center,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'^(\d{0,3})?\.?\d{0,2}')),
                              ],
                              onChanged: (String? value) {
                                double parsed = 0.0;
                                if (value != null) {
                                  parsed = double.tryParse(value) ?? 0.0;
                                }
                                widget.dataController.setAccel(parsed);
                              },
                            ),
                          ),
                          trailing: Text(
                            '기본: ${breed.requireData.spec.accel}',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        ListTile(
                          leading: const Text(
                            '회전',
                            style: TextStyle(fontSize: 14),
                          ),
                          title: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: TextField(
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              textAlign: TextAlign.center,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'^(\d{0,3})?\.?\d{0,2}')),
                              ],
                              onChanged: (String? value) {
                                double parsed = 0.0;
                                if (value != null) {
                                  parsed = double.tryParse(value) ?? 0.0;
                                }
                                widget.dataController.setTurn(parsed);
                              },
                            ),
                          ),
                          trailing: Text(
                            '기본: ${breed.requireData.spec.turn}',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        ListTile(
                          leading: const Text(
                            '제동',
                            style: TextStyle(fontSize: 14),
                          ),
                          title: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: TextField(
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              textAlign: TextAlign.center,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'^(\d{0,3})?\.?\d{0,2}')),
                              ],
                              onChanged: (String? value) {
                                double parsed = 0.0;
                                if (value != null) {
                                  parsed = double.tryParse(value) ?? 0.0;
                                }
                                widget.dataController.setBrake(parsed);
                              },
                            ),
                          ),
                          trailing: Text(
                            '기본: ${breed.requireData.spec.brake}',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}

class _ResultCard extends StatelessWidget {
  final HorseStatusDataController dataController;

  const _ResultCard({super.key, required this.dataController});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const ListTile(
              title: Text('결과'),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _ResultContents(dataController: dataController),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultContents extends StatefulWidget {
  final HorseStatusDataController dataController;

  const _ResultContents({super.key, required this.dataController});

  @override
  State<_ResultContents> createState() => _ResultContentsState();
}

class _ResultContentsState extends State<_ResultContents> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((timeStamp) => widget.dataController.subscribe());
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: widget.dataController.selectedBreed,
        builder: (context, breed) {
          return StreamBuilder(
              stream: widget.dataController.resultStatus,
              builder: (context, result) {
                if (!breed.hasData || !result.hasData) {
                  return const LoadingIndicator();
                }
                return Column(
                  children: [
                    _ResultGradeChipLine(
                      grade: Horse.getGrade(result.requireData.avgTotalGrown),
                    ),
                    _ResultChart(result: result.requireData),
                    _ResultLine(
                      breed: breed.requireData.nameKR,
                      totalGrown: result.requireData.totalGrown,
                      avgTotalGrown: result.requireData.avgTotalGrown,
                    ),
                    _ResultTable(data: result.requireData),
                  ],
                );
              });
        });
  }
}

class _ResultGradeChipLine extends StatefulWidget {
  final String grade;

  const _ResultGradeChipLine({super.key, required this.grade});

  @override
  State<_ResultGradeChipLine> createState() => _ResultGradeChipLineState();
}

class _ResultGradeChipLineState extends State<_ResultGradeChipLine> {
  final List<String> grades = ['최하급', '하급', '중급', '상급', '최상급'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      constraints: const BoxConstraints(maxWidth: 540),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: grades
            .map((e) => Chip(
                  label: Text(e),
                  backgroundColor: widget.grade == e ? Colors.blue : null,
                ))
            .toList(),
      ),
    );
  }
}

class _ResultLine extends StatelessWidget {
  final String breed;
  final double totalGrown;
  final double avgTotalGrown;

  const _ResultLine({
    super.key,
    required this.breed,
    required this.totalGrown,
    required this.avgTotalGrown,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 540),
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(breed, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: '총 성장치: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: totalGrown.toStringAsFixed(2)),
              ],
            ),
          ),
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: '평균 성장치: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: avgTotalGrown.toStringAsFixed(2)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultChart extends StatelessWidget {
  final HorseStatus result;

  const _ResultChart({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      constraints: const BoxConstraints(maxWidth: 400),
      child: AspectRatio(
        aspectRatio: 1.0,
        child: RadarChart(
          RadarChartData(
            dataSets: [
              RadarDataSet(
                dataEntries: [
                  RadarEntry(value: min(result.avgGrownSpec.speed, 1.3)),
                  RadarEntry(value: min(result.avgGrownSpec.accel, 1.3)),
                  RadarEntry(value: min(result.avgGrownSpec.turn, 1.3)),
                  RadarEntry(value: min(result.avgGrownSpec.brake, 1.3)),
                ],
                borderColor: Colors.blueAccent,
                fillColor: Colors.blueAccent.withOpacity(0.8),
                borderWidth: 2.0,
                entryRadius: 1.0,
              ),
              RadarDataSet(
                dataEntries:
                    List.generate(4, (index) => const RadarEntry(value: 1.3)),
                fillColor: Colors.transparent,
                borderColor: Colors.grey.withOpacity(0.5),
                borderWidth: 1.0,
                entryRadius: 0.0,
              )
            ],
            getTitle: (index, angle) {
              switch (index) {
                case 0:
                  return RadarChartTitle(text: '속도', angle: angle);
                case 1:
                  return RadarChartTitle(text: '가속', angle: angle);
                case 2:
                  return RadarChartTitle(text: '회전', angle: angle);
                case 3:
                  return RadarChartTitle(text: '제동', angle: angle);
                default:
                  return const RadarChartTitle(text: '');
              }
            },
            titlePositionPercentageOffset: 0.1,
            ticksTextStyle: const TextStyle(
              fontSize: 10.0,
              color: Colors.transparent,
            ),
            tickCount: 10,
            tickBorderData: const BorderSide(color: Colors.transparent),
            radarBorderData: const BorderSide(color: Colors.transparent),
            gridBorderData: BorderSide(color: Colors.black.withOpacity(0.2)),
            borderData: FlBorderData(show: false),
          ),
          swapAnimationDuration: const Duration(milliseconds: 200),
          swapAnimationCurve: Curves.linear,
        ),
      ),
    );
  }
}

class _ResultTable extends StatelessWidget {
  final HorseStatus data;

  const _ResultTable({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 540),
      child: Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          TableRow(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),
            children: [
              _CenterText('LV ${data.level}', bold: true),
              const _CenterText('입력값', bold: true),
              const _CenterText('마구 제거', bold: true),
              const _CenterText('평균 성장치', bold: true),
              const _CenterText('등급', bold: true),
            ],
          ),
          _tableRow(
            title: '속도',
            userInput: data.finalSpec.speed,
            additional: data.additionalSpec.speed,
            avgGrown: data.avgGrownSpec.speed,
            grade: Horse.getGrade(data.avgGrownSpec.speed),
            borderSide: BorderSide(color: Theme.of(context).dividerColor),
          ),
          _tableRow(
            title: '가속',
            userInput: data.finalSpec.accel,
            additional: data.additionalSpec.accel,
            avgGrown: data.avgGrownSpec.accel,
            grade: Horse.getGrade(data.avgGrownSpec.accel),
            borderSide: BorderSide(color: Theme.of(context).dividerColor),
          ),
          _tableRow(
            title: '회전',
            userInput: data.finalSpec.turn,
            additional: data.additionalSpec.turn,
            avgGrown: data.avgGrownSpec.turn,
            grade: Horse.getGrade(data.avgGrownSpec.turn),
            borderSide: BorderSide(color: Theme.of(context).dividerColor),
          ),
          _tableRow(
            title: '제동',
            userInput: data.finalSpec.brake,
            additional: data.additionalSpec.brake,
            avgGrown: data.avgGrownSpec.brake,
            grade: Horse.getGrade(data.avgGrownSpec.brake),
            borderSide: BorderSide(color: Theme.of(context).dividerColor),
          ),
        ],
      ),
    );
  }

  TableRow _tableRow({
    required String title,
    required double userInput,
    required double additional,
    required double avgGrown,
    required String grade,
    required BorderSide borderSide,
  }) {
    return TableRow(
      decoration: BoxDecoration(border: Border(top: borderSide)),
      children: [
        _CenterText(title, bold: true),
        _CenterText(userInput.toStringAsFixed(2)),
        _CenterText(max((userInput - additional), 0.0).toStringAsFixed(2)),
        _CenterText(avgGrown.toStringAsFixed(2)),
        _CenterText(grade),
      ],
    );
  }
}

class _CenterText extends StatelessWidget {
  final String data;
  final bool bold;

  const _CenterText(this.data, {super.key, this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        data,
        style: TextStyle(fontWeight: bold ? FontWeight.bold : null),
        textAlign: TextAlign.center,
      ),
    );
  }
}
