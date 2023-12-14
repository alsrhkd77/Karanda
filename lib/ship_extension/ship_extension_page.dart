import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:karanda/common/custom_scroll_behavior.dart';
import 'package:karanda/ship_extension/ship_extension_item_model.dart';
import 'package:karanda/ship_extension/ship_extension_notifier.dart';
import 'package:karanda/widgets/default_app_bar.dart';
import 'package:karanda/widgets/loading_indicator.dart';
import 'package:karanda/widgets/title_text.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';

import 'item_widget.dart';

class ShipExtensionPage extends StatefulWidget {
  const ShipExtensionPage({Key? key}) : super(key: key);

  @override
  State<ShipExtensionPage> createState() => _ShipExtensionPageState();
}

class _ShipExtensionPageState extends State<ShipExtensionPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        appBar: const DefaultAppBar(),
        body: ChangeNotifierProvider(
          create: (_) => ShipExtensionNotifier(),
          child: Consumer<ShipExtensionNotifier>(
            builder: (_, notifier, __) {
              if (notifier.items.isEmpty) {
                return const LoadingIndicator();
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
                      child: const TitleText(
                        '증축 재료 수급 현황',
                        bold: true,
                      ),
                    ),
                    _HeadLine(),
                    const SizedBox(height: 24.0,),
                    SizedBox(
                      child: ScrollConfiguration(
                        behavior: CustomScrollBehavior(),
                        child: const SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Card(
                            margin: EdgeInsets.all(12.0),
                            elevation: 8.0,
                            child: Column(
                              children: [
                                _TitleLine(),
                                _ItemList(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24.0,),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _HeadLine extends StatelessWidget {
  _HeadLine({super.key});

  final List<String> shipType = [
    '에페리아 중범선 : 비상',
    '에페리아 중범선 : 용맹',
    '에페리아 중범선 : 점진',
    '에페리아 중범선 : 균형',
  ];

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

  @override
  Widget build(BuildContext context) {
    final double percent = context.select<ShipExtensionNotifier, double>(
        (ShipExtensionNotifier s) => s.percent);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: MediaQuery.of(context).size.width - 250,
          constraints: const BoxConstraints(
            maxWidth: 1100,
          ),
          padding: const EdgeInsets.all(12.0),
          child: LinearPercentIndicator(
            animation: true,
            lineHeight: 18.0,
            animationDuration: 500,
            percent: percent,
            center: Text(
              "${(percent * 100).toStringAsFixed(2)}%",
              style: const TextStyle(color: Colors.black),
            ),
            barRadius: const Radius.circular(15.0),
            progressColor: getColor(percent),
            animateFromLastPercent: true,
          ),
        ),
        Container(
          margin: const EdgeInsets.fromLTRB(0, 0, 12, 0),
          child: DecoratedBox(
            decoration: BoxDecoration(
                border: Border.all(color: Colors.blue),
                borderRadius: BorderRadius.circular(12.0)),
            child: DropdownButton<String>(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              borderRadius: BorderRadius.circular(12.0),
              value: context.select<ShipExtensionNotifier, String>(
                  (ShipExtensionNotifier s) => s.select),
              underline: Container(),
              focusColor: Colors.transparent,
              onChanged: (String? value) {
                if (value!.isEmpty) {
                  return;
                }
                context.read<ShipExtensionNotifier>().selectShipType(value);
              },
              items: shipType
                  .map<DropdownMenuItem<String>>((e) => DropdownMenuItem(
                        alignment: Alignment.center,
                        value: e,
                        child: Text(e),
                      ))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class _TitleLine extends StatelessWidget {
  const _TitleLine({super.key});

  final TextStyle style =
      const TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0);

  @override
  Widget build(BuildContext context) {
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
            width: 190,
            margin: const EdgeInsets.symmetric(horizontal: 6.0),
            child: Text(
              '재료',
              textAlign: TextAlign.center,
              style: style,
            ),
          ),
          const VerticalDivider(),
          Container(
            width: 480,
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
            width: 45,
            margin: const EdgeInsets.symmetric(horizontal: 6.0),
            child: Text(
              '필요',
              textAlign: TextAlign.center,
              style: style,
            ),
          ),
          const VerticalDivider(),
          Container(
            width: 40,
            margin: const EdgeInsets.symmetric(horizontal: 6.0),
            child: Text(
              '남은 일수',
              textAlign: TextAlign.center,
              style: style,
            ),
          ),
          const VerticalDivider(),
          Container(
            width: 40,
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
              '구매 가격',
              textAlign: TextAlign.center,
              style: style,
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemList extends StatelessWidget {
  const _ItemList({super.key});

  @override
  Widget build(BuildContext context) {
    //final extensionItems = context.select<ShipExtensionNotifier, List<ShipExtensionItemModel>>((ShipExtensionNotifier s) => s.extensionItems);
    final extensionItems = context.watch<ShipExtensionNotifier>().extensionItems;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12.0),
      //height: _extensionController.extensionItems.length * 99,
      width: 1200,
      child: ListView.separated(
        separatorBuilder: (context, index) => const Divider(),
        itemCount: extensionItems.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return ItemWidget(
            item: extensionItems[index],
            textField: TextFormField(
              initialValue: extensionItems[index].user > 0
                  ? extensionItems[index].user.toString()
                  : null,
              keyboardType: const TextInputType.numberWithOptions(),
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
                int insert = 0;
                if (value.isNotEmpty) {
                  insert = int.parse(value);
                }
                context
                    .read<ShipExtensionNotifier>()
                    .updateUserItem(extensionItems[index].name, insert);
              },
            ),
          );
        },
      ),
    );
  }
}
