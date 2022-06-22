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

  @override
  void initState() {
    super.initState();
  }

  Widget buildItemList() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12.0),
      height: _extensionController.extensionItems.length * 99,
      width: 1110,
      child: ListView.separated(
        separatorBuilder: (context, index) => Divider(),
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
      margin: EdgeInsets.all(12.0),
      height: 60,
      child: Row(
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 6.0),
            child: SizedBox(
              width: 40,
              height: 40,
            ),
          ),
          VerticalDivider(),
          Container(
            width: 135,
            margin: EdgeInsets.symmetric(horizontal: 6.0),
            child: Text(
              '재료',
              textAlign: TextAlign.center,
              style: style,
            ),
          ),
          VerticalDivider(),
          Container(
            width: 470,
            margin: EdgeInsets.symmetric(horizontal: 6.0),
            child: Text(
              '주요 획득처',
              textAlign: TextAlign.center,
              style: style,
            ),
          ),
          VerticalDivider(),
          Container(
            width: 60,
            child: Text(
              '보유',
              textAlign: TextAlign.center,
              style: style,
            ),
          ),
          VerticalDivider(),
          Container(
            width: 40,
            margin: EdgeInsets.symmetric(horizontal: 6.0),
            child: Text(
              '필요',
              textAlign: TextAlign.center,
              style: style,
            ),
          ),
          VerticalDivider(),
          Container(
            width: 30,
            margin: EdgeInsets.symmetric(horizontal: 6.0),
            child: Text(
              '남은 일수',
              textAlign: TextAlign.center,
              style: style,
            ),
          ),
          VerticalDivider(),
          Container(
            width: 30,
            margin: EdgeInsets.symmetric(horizontal: 6.0),
            child: Text(
              '소요 일수',
              textAlign: TextAlign.center,
              style: style,
            ),
          ),
          VerticalDivider(),
          Container(
            width: 70,
            margin: EdgeInsets.symmetric(horizontal: 6.0),
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
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: LinearPercentIndicator(
                        width: MediaQuery.of(context).size.width - 25,
                        animation: true,
                        lineHeight: 18.0,
                        animationDuration: 1500,
                        percent: 0.1,
                        center: Text("13.0%"),
                        barRadius: const Radius.circular(15.0),
                        progressColor: Colors.blue,
                      ),
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
                            margin: EdgeInsets.all(24.0),
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
