import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:karanda/common/custom_scroll_behavior.dart';
import 'package:karanda/common/global_properties.dart';
import 'package:karanda/ship_upgrading/ship_upgrading_data_controller.dart';
import 'package:karanda/ship_upgrading/ship_upgrading_material.dart';
import 'package:karanda/ship_upgrading/ship_upgrading_setting.dart';
import 'package:karanda/ship_upgrading/ship_upgrading_settings_page.dart';
import 'package:karanda/ship_upgrading/ship_upgrading_ship.dart';
import 'package:karanda/ship_upgrading/widgets/list_by_materials.dart';
import 'package:karanda/ship_upgrading/widgets/list_by_parts.dart';
import 'package:karanda/widgets/default_app_bar.dart';
import 'package:karanda/widgets/loading_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class ShipUpgradingPage extends StatefulWidget {
  const ShipUpgradingPage({super.key});

  @override
  State<ShipUpgradingPage> createState() => _ShipUpgradingPageState();
}

class _ShipUpgradingPageState extends State<ShipUpgradingPage> {
  final ShipUpgradingDataController dataController =
      ShipUpgradingDataController();
  bool loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => ready());
  }

  Future<void> ready() async {
    bool result = await dataController.getBaseData();
    if (result) {
      setState(() {
        loading = true;
      });
    }
    dataController.subscribe();
  }

  @override
  void dispose() {
    dataController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: dataController.setting,
        builder: (context, setting) {
          if (!loading || !setting.hasData) {
            return const Center(
              child: LoadingIndicator(),
            );
          }
          return Scaffold(
            appBar: DefaultAppBar(
              title: "선박 증축",
              icon: FontAwesomeIcons.ship,
              actions: [
                IconButton(
                  onPressed: dataController.setChangeForm,
                  icon: Icon(
                    Icons.dynamic_form_outlined,
                    color: setting.requireData.changeForm
                        ? Colors.blue
                        : null,
                  ),
                  tooltip: "리스트 타입",
                ),
                Padding(
                  padding: GlobalProperties.appBarActionPadding,
                  child: IconButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ShipUpgradingSettingsPage(
                            dataController: dataController,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.construction),
                    tooltip: "설정",
                  ),
                ),
              ],
            ),
            body: ListView(
              padding: GlobalProperties.scrollViewPadding,
              children: [
                _Head(
                    selectedShipStream: dataController.selectedShipData,
                    shipData: dataController.ship,
                    updateSelected: dataController.updateSelected,
                    dataController: dataController),
                _Body(
                  dataController: dataController,
                  screenWidth: MediaQuery.of(context).size.width,
                  setting: setting.requireData,
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("TIP - 아이템 이름을 누르면 보유 갯수가 증가하고, 아이콘을 누르면 감소합니다!",
                      style: TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center),
                ),
                const SizedBox(
                  height: 36.0,
                )
              ],
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () async {
                bool? result = await showDialog(
                  context: context,
                  builder: (context) => const _AddDailyQuestDialog(),
                );
                if (result != null && result) {
                  dataController.runDailyQuest();
                }
              },
              //isExtended: false,
              tooltip: '일일퀘스트',
              icon: const Icon(Icons.add_task),
              label: const Text("일일퀘스트"),
              focusNode: FocusNode(skipTraversal: true),
            ),
          );
        },
      ),
    );
  }
}

class _Head extends StatelessWidget {
  final ShipUpgradingDataController dataController;
  final Stream<ShipUpgradingShip> selectedShipStream;
  final Map<String, ShipUpgradingShip> shipData;
  final Function(String) updateSelected;

  const _Head(
      {super.key,
      required this.selectedShipStream,
      required this.shipData,
      required this.updateSelected,
      required this.dataController});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: GlobalProperties.widthConstrains,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _ShipTypeSelector(
              selectedShipStream: selectedShipStream,
              shipData: shipData,
              updateSelected: updateSelected,
              dataController: dataController,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _PercentInHeader(stream: dataController.totalPercent),
          ),
        ],
      ),
    );
  }
}

class _ShipTypeSelector extends StatelessWidget {
  final ShipUpgradingDataController dataController;
  final Stream<ShipUpgradingShip> selectedShipStream;
  final Map<String, ShipUpgradingShip> shipData;
  final Function(String) updateSelected;

  const _ShipTypeSelector(
      {super.key,
      required this.selectedShipStream,
      required this.shipData,
      required this.updateSelected,
      required this.dataController});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: dataController.selectedShipData,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(
            height: 15.0,
          );
        }
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(),
            DropdownMenu<String>(
              initialSelection: snapshot.data?.nameEN,
              dropdownMenuEntries: shipData.keys
                  .map<DropdownMenuEntry<String>>(
                    (e) => DropdownMenuEntry(
                      value: shipData[e]!.nameEN,
                      label: shipData[e]!.nameKR,
                    ),
                  )
                  .toList(),
              onSelected: (String? value) {
                if (value != null) {
                  updateSelected(value);
                }
              },
            ),
          ],
        );
      },
    );
  }
}

class _PercentInHeader extends StatelessWidget {
  final Stream<double> stream;

  const _PercentInHeader({super.key, required this.stream});

  MaterialColor getColor(double percent) {
    if (percent < 0.25) {
      return Colors.red;
    } else if (percent < 0.5) {
      return Colors.orange;
    } else if (percent < 0.75) {
      return Colors.yellow;
    } else if (percent < 1) {
      return Colors.green;
    }
    return Colors.blue;
  }

  double getPercent(List<ShipUpgradingMaterial> dataList) {
    double need = 0;
    double stock = 0;
    for (ShipUpgradingMaterial data in dataList) {
      need += data.neededPoint;
      stock += data.stockPointWithFinished;
    }
    if (need <= 0) {
      return 0;
    }
    return stock / need;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(
            height: 15.0,
          );
        }
        //double percent = getPercent(snapshot.data!.values.toList());
        return Flex(
          direction: Axis.horizontal,
          children: [
            Flexible(
              fit: FlexFit.tight,
              child: LinearPercentIndicator(
                animation: true,
                animationDuration: 500,
                percent: snapshot.data!,
                barRadius: const Radius.circular(4.0),
                progressColor: getColor(snapshot.data!),
                animateFromLastPercent: true,
              ),
            ),
            const SizedBox(
              width: 4,
            ),
            Text(
              "${(snapshot.data! * 100).toStringAsFixed(2)}%",
            ),
          ],
        );
      },
    );
  }
}

class _Body extends StatelessWidget {
  final ShipUpgradingDataController dataController;
  final double screenWidth;
  final ShipUpgradingSetting setting;

  const _Body({
    super.key,
    required this.dataController,
    required this.screenWidth,
    required this.setting,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ScrollConfiguration(
        behavior: CustomScrollBehavior(),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: GlobalProperties.widthConstrains - 48,
            child: setting.changeForm
                ? ListByParts(
                    dataController: dataController,
                    screenWidth: screenWidth,
                    setting: setting,
                  )
                : ListByMaterials(
                    dataController: dataController,
                    setting: setting,
                  ),
          ),
        ),
      ),
    );
  }
}

class _AddDailyQuestDialog extends StatelessWidget {
  const _AddDailyQuestDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('일일퀘스트 재료 추가'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("일일 퀘스트로 얻는 재료 하루치 분량을 \n한 번에 추가합니다"),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "재료별 추가 갯수는 오른쪽 상단의\n설정탭에서 변경할 수 있습니다",
              style: TextStyle(color: Colors.grey, fontSize: 12.5),
            ),
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        ElevatedButton(
          onPressed: () {
            context.pop(false);
          },
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.red,
          ),
          child: const Text("취소"),
        ),
        ElevatedButton(
          onPressed: () {
            context.pop(true);
          },
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.blue,
          ),
          child: const Text("추가"),
        ),
      ],
    );
  }
}
