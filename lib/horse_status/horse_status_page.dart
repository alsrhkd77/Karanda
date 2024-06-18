import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:karanda/common/global_properties.dart';
import 'package:karanda/horse_status/horse_status_data_controller.dart';
import 'package:karanda/horse_status/models/horse_equipment_model.dart';
import 'package:karanda/horse_status/models/horse_model.dart';
import 'package:karanda/horse_status/models/horse_status_model.dart';
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
                        const SizedBox(
                          height: 12.0,
                        )
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
  final List<HorseModel> breeds;
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
  final List<HorseEquipmentModel> items;
  final HorseEquipmentModel selected;
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

class _StatusInputCard extends StatelessWidget {
  final HorseStatusDataController dataController;

  const _StatusInputCard({super.key, required this.dataController});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: dataController.selectedBreed,
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
                                dataController.setLevel(parsed);
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
                                dataController.setSpeed(parsed);
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
                                dataController.setAccel(parsed);
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
                                dataController.setTurn(parsed);
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
                                dataController.setBrake(parsed);
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
            _ResultContents(dataController: dataController),
          ],
        ),
      ),
    );
  }
}

class _ResultContents extends StatelessWidget {
  final HorseStatusDataController dataController;

  const _ResultContents({super.key, required this.dataController});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: dataController.resultStatus,
        builder: (context, result) {
          if (!result.hasData) {
            return const LoadingIndicator();
          }
          return Column(
            children: [
              _ResultChart(result: result.requireData),
            ],
          );
        });
  }
}

class _ResultChart extends StatelessWidget {
  final HorseStatusModel result;

  const _ResultChart({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 400
      ),
      child: AspectRatio(
        aspectRatio: 1.0,
        child: RadarChart(
          RadarChartData(
            dataSets: [
              RadarDataSet(
                dataEntries: [
                  RadarEntry(value: result.grownAvg.speed),
                  RadarEntry(value: result.grownAvg.accel),
                  RadarEntry(value: result.grownAvg.turn),
                  RadarEntry(value: result.grownAvg.brake),
                ],
                borderColor: Colors.green,
                fillColor: Colors.green.withOpacity(0.5),
                borderWidth: 2.0,
                entryRadius: 1.0,
              ),
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
                color: Colors.transparent),
            tickBorderData: const BorderSide(
                color: Colors.transparent),
            radarBorderData: const BorderSide(
                color: Colors.transparent),
            gridBorderData: BorderSide(
                color: Colors.black.withOpacity(0.2)),
            borderData: FlBorderData(show: false),
          ),
          swapAnimationDuration: const Duration(milliseconds: 200),
          swapAnimationCurve: Curves.linear,
        ),
      ),
    );
  }
}
