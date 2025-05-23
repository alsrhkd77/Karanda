import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:karanda/common/global_properties.dart';
import 'package:karanda/ship_upgrading/ship_upgrading_data_controller.dart';
import 'package:karanda/ship_upgrading/ship_upgrading_material.dart';
import 'package:karanda/trade_market/bdo_item_image_widget.dart';
import 'package:karanda/widgets/default_app_bar.dart';
import 'package:karanda/widgets/loading_indicator.dart';
import 'package:karanda/widgets/loading_indicator_dialog.dart';
import 'package:karanda/widgets/title_text.dart';

class ShipUpgradingSettingsPage extends StatefulWidget {
  final ShipUpgradingDataController dataController;

  const ShipUpgradingSettingsPage({super.key, required this.dataController});

  @override
  State<ShipUpgradingSettingsPage> createState() =>
      _ShipUpgradingSettingsPageState();
}

class _ShipUpgradingSettingsPageState extends State<ShipUpgradingSettingsPage> {
  late ShipUpgradingDataController dataController;

  @override
  void initState() {
    super.initState();
    dataController = widget.dataController;
    WidgetsBinding.instance
        .addPostFrameCallback((timeStamp) => dataController.subscribe());
  }

  Future<void> resetUserStock() async {
    bool? result = await showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: const Text('보유 재고 초기화'),
              content: const Text('모든 재료의 보유 재고를 초기화합니다.'),
              actionsAlignment: MainAxisAlignment.spaceBetween,
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: const Text('취소'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: const Text('초기화'),
                )
              ],
            ));
    if(result != null && result){
      showDialog(
        context: context,
        builder: (_) => const LoadingIndicatorDialog(
          title: '처리중',
        ),
      );
      await dataController.resetUserStock();
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DefaultAppBar(
        title: "선박 증축",
        icon: FontAwesomeIcons.ship,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(12.0),
            constraints: BoxConstraints(
              maxWidth: GlobalProperties.widthConstrains,
            ),
            child: StreamBuilder(
              stream: dataController.materials,
              builder: (context, materials) {
                return StreamBuilder(
                  stream: dataController.setting,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || !materials.hasData) {
                      return const LoadingIndicator();
                    }
                    return Column(
                      children: [
                        const ListTile(
                          title: TitleText('선박 증축 설정', bold: true),
                        ),
                        const Divider(),
                        snapshot.requireData.changeForm ? ListTile(
                          title: const Text('제작 완료된 카드 닫기'),
                          trailing: Switch(
                            value: snapshot.requireData.closeFinishedParts,
                            onChanged: (value) {
                              widget.dataController.setCardCloseSetting(value);
                            },
                          ),
                        ) : Container(),
                        ListTile(
                          title: const Text('항목 이름 표시'),
                          trailing: Switch(
                            value: snapshot.requireData.showTableHeader,
                            onChanged: (value) {
                              widget.dataController.setShowTableHeaders(value);
                            },
                          ),
                        ),
                        snapshot.requireData.changeForm ? ListTile(
                          title: const Text('재료 합계 표시'),
                          subtitle: const Text(
                            "모든 파츠 제작에 필요한 재료 합계를 표시합니다",
                            style: TextStyle(color: Colors.grey),
                          ),
                          trailing: Switch(
                            value: snapshot.requireData.showTotalNeeded,
                            onChanged: (value) {
                              widget.dataController.setShowTotalNeeded(value);
                            },
                          ),
                        ) : Container(),
                        ExpansionTile(
                          //initiallyExpanded: true,
                          title: const Text('일일퀘스트'),
                          subtitle: const Text(
                            "일일퀘스트 버튼으로 추가할 재료를 설정합니다",
                            style: TextStyle(color: Colors.grey),
                          ),
                          childrenPadding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 4.0),
                          children: materials.requireData.values
                              .map((e) => _MaterialListTile(
                                    material: e,
                                    update: dataController.setDailyQuest,
                                    count: snapshot.requireData
                                        .dailyQuest[e.code.toString()],
                                  ))
                              .toList(),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: ElevatedButton(
                            onPressed: () => resetUserStock(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                            child: Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.all(8.0),
                              width: double.infinity,
                              child: const Text('보유 재고 초기화'),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 24.0,
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _MaterialListTile extends StatelessWidget {
  final ShipUpgradingMaterial material;
  final Function(String, int) update;
  final int? count;

  const _MaterialListTile(
      {super.key, required this.material, required this.update, this.count});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: BdoItemImageWidget(
        code: material.code.toString(),
        grade: material.grade,
        size: 38,
      ),
      title: Text(material.nameKR),
      trailing: SizedBox(
        width: 92.0,
        height: 36.0,
        child: TextFormField(
          initialValue: count != null ? count.toString() : '',
          keyboardType: const TextInputType.numberWithOptions(),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^(\d{0,3})')),
          ],
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: Colors.blue),
            ),
            contentPadding: EdgeInsets.zero,
          ),
          textAlign: TextAlign.center,
          onChanged: (String value) {
            if (value.isEmpty) {
              update(material.code.toString(), 0);
            } else {
              update(material.code.toString(), int.parse(value));
            }
          },
        ),
      ),
    );
  }
}
