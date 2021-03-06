import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:karanda/common/custom_scroll_behavior.dart';
import 'package:karanda/ship_extension/ship_extension_controller.dart';
import 'package:karanda/widgets/default_app_bar.dart';
import 'package:karanda/widgets/title_text.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import 'item_widget.dart';

class ShipExtensionPage extends StatefulWidget {
  const ShipExtensionPage({Key? key}) : super(key: key);

  @override
  State<ShipExtensionPage> createState() => _ShipExtensionPageState();
}

class _ShipExtensionPageState extends State<ShipExtensionPage> {
  final ShipExtensionController _extensionController =
      ShipExtensionController();
  List<String> shipType = [
    '에페리아 중범선 : 비상',
    '에페리아 중범선 : 용맹',
    '에페리아 중범선 : 점진',
    '에페리아 중범선 : 균형',
  ];

  @override
  void initState() {
    super.initState();
  }

  MaterialColor getColor(double percent){
    if(percent < 0.25){
      return Colors.red;
    }else if(percent < 0.5){
      return Colors.orange;
    }else if(percent < 0.75){
      return Colors.yellow;
    }else if(percent < 1){
      return Colors.green;
    }
    return Colors.blue;
  }

  Widget buildItemList() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12.0),
      height: _extensionController.extensionItems.length * 99,
      width: 1120,
      child: ListView.separated(
        separatorBuilder: (context, index) => const Divider(),
        itemCount: _extensionController.extensionItems.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return ItemWidget(
            item: _extensionController.extensionItems[index],
            textField: TextFormField(
              initialValue: _extensionController.extensionItems[index].user > 0
                  ? _extensionController.extensionItems[index].user.toString()
                  : null,
              keyboardType:
              const TextInputType.numberWithOptions(),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^(\d{0,3})')),
              ],
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(color: Colors.blue),
                ),
              ),
              onChanged: (value) {
                if (value.isEmpty) {
                  _extensionController.updateUserItem(
                      _extensionController.extensionItems[index].name, 0);
                } else {
                  _extensionController.updateUserItem(
                      _extensionController.extensionItems[index].name,
                      int.parse(value));
                }
              },
            ),
          );
        },
      ),
    );
  }

  Widget buildTitleLine() {
    TextStyle style =
        const TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0);
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.all(12.0),
      height: 60,
      child: Row(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 6.0),
            child: const SizedBox(
              width: 40,
              height: 40,
            ),
          ),
          const VerticalDivider(),
          Container(
            width: 135,
            margin: const EdgeInsets.symmetric(horizontal: 6.0),
            child: Text(
              '재료',
              textAlign: TextAlign.center,
              style: style,
            ),
          ),
          const VerticalDivider(),
          Container(
            width: 470,
            margin: const EdgeInsets.symmetric(horizontal: 6.0),
            child: Text(
              '주요 획득처',
              textAlign: TextAlign.center,
              style: style,
            ),
          ),
          const VerticalDivider(),
          SizedBox(
            width: 60,
            child: Text(
              '보유',
              textAlign: TextAlign.center,
              style: style,
            ),
          ),
          const VerticalDivider(),
          Container(
            width: 40,
            margin: const EdgeInsets.symmetric(horizontal: 6.0),
            child: Text(
              '필요',
              textAlign: TextAlign.center,
              style: style,
            ),
          ),
          const VerticalDivider(),
          Container(
            width: 35,
            margin: const EdgeInsets.symmetric(horizontal: 6.0),
            child: Text(
              '남은 일수',
              textAlign: TextAlign.center,
              style: style,
            ),
          ),
          const VerticalDivider(),
          Container(
            width: 35,
            margin: const EdgeInsets.symmetric(horizontal: 6.0),
            child: Text(
              '소요 일수',
              textAlign: TextAlign.center,
              style: style,
            ),
          ),
          const VerticalDivider(),
          Container(
            width: 70,
            margin: const EdgeInsets.symmetric(horizontal: 6.0),
            child: Text(
              '까마귀\n주화',
              textAlign: TextAlign.center,
              style: style,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DefaultAppBar(),
      body: GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: FutureBuilder(
            future: _extensionController.getShipData(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: SpinKitFadingCube(
                    size: 120.0,
                    color: Colors.blue,
                  ),
                );
              }
              return SingleChildScrollView(
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: ListTile(
                        leading: Icon(FontAwesomeIcons.ship),
                        title: TitleText(
                          '선박 증축',
                          bold: true,
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.all(12.0),
                      child: const TitleText('증축재료 수급 현황', bold: true,),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Obx(
                            () => LinearPercentIndicator(
                              width: MediaQuery.of(context).size.width - 250,
                              animation: true,
                              lineHeight: 18.0,
                              animationDuration: 500,
                              percent: _extensionController.percent,
                              center: Text("${(_extensionController.percent * 100).toStringAsFixed(2)}%"),
                              barRadius: const Radius.circular(15.0),
                              progressColor: getColor(_extensionController.percent),
                              animateFromLastPercent: true,
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.fromLTRB(0, 0, 12, 0),
                          child: DecoratedBox(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.blue),
                                borderRadius: BorderRadius.circular(15.0)
                              ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Obx(
                                    () => DropdownButton<String>(
                                  value: _extensionController.select.value,
                                  underline: Container(),
                                  focusColor: Colors.transparent,
                                  onChanged: (String? value) {
                                    if (value!.isEmpty) {
                                      return;
                                    }
                                    _extensionController.selectShipType(value);
                                  },
                                  items: shipType
                                      .map<DropdownMenuItem<String>>(
                                          (e) => DropdownMenuItem(
                                        value: e,
                                        child: Text(e),
                                      ))
                                      .toList(),
                                ),
                              ),
                            ),
                          ),
                        ),

                      ],
                    ),
                    SizedBox(
                      height:
                          ((_extensionController.extensionItems.length + 1) *
                                  99) +
                              33,
                      child: ScrollConfiguration(
                        behavior: CustomScrollBehavior(),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Card(
                            margin: const EdgeInsets.all(24.0),
                            elevation: 8.0,
                            child: Column(
                              children: [
                                buildTitleLine(),
                                Obx(buildItemList),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
      ),
    );
  }
}
