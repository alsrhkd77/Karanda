import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import '../widgets/default_app_bar.dart';
import '../widgets/title_text.dart';

class TradeHomePage extends StatefulWidget {
  const TradeHomePage({Key? key}) : super(key: key);

  @override
  State<TradeHomePage> createState() => _TradeHomePageState();
}

class _TradeHomePageState extends State<TradeHomePage> {
  List<Widget> buildButton() {
    return <Widget>[
      SizedBox(
        width: 300,
        height: 100,
        child: Card(
          margin: const EdgeInsets.all(8.0),
          child: InkWell(
            borderRadius: BorderRadius.circular(13.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                Icon(FontAwesomeIcons.weightHanging),
                SizedBox(
                  height: 8.0,
                ),
                Text('선박 과적 계산기'),
              ],
            ),
            onTap: () {
              Get.toNamed('overloaded-ship');
            },
          ),
        ),
      ),
      SizedBox(
        width: 300,
        height: 100,
        child: Card(
          margin: const EdgeInsets.all(8.0),
          child: InkWell(
            borderRadius: BorderRadius.circular(13.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                Icon(Icons.calculate),
                SizedBox(
                  height: 8.0,
                ),
                Text('재료비 계산기'),
              ],
            ),
            onTap: () {
              Get.toNamed('material-cost-calculator');
            },
          ),
        ),
      ),
      SizedBox(
        width: 300,
        height: 100,
        child: Card(
          margin: const EdgeInsets.all(8.0),
          child: InkWell(
            borderRadius: BorderRadius.circular(13.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                Icon(FontAwesomeIcons.coins),
                SizedBox(
                  height: 8.0,
                ),
                Text('까마귀 주화 효율 계산기'),
              ],
            ),
            onTap: () {
              Get.toNamed('crow-coin');
            },
          ),
        ),
      ),
      SizedBox(
        width: 300,
        height: 100,
        child: Card(
          margin: const EdgeInsets.all(8.0),
          child: InkWell(
            borderRadius: BorderRadius.circular(13.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                Icon(FontAwesomeIcons.solidHandshake),
                SizedBox(
                  height: 8.0,
                ),
                Text('교섭력 계산기'),
              ],
            ),
            onTap: () {
              Get.toNamed('parley-calculator');
            },
          ),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DefaultAppBar(),
      body: Container(
        margin: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            const ListTile(
              leading: Icon(FontAwesomeIcons.arrowRightArrowLeft),
              title: TitleText(
                '물물교환 계산기',
                bold: true,
              ),
            ),
            Wrap(
              children: buildButton(),
            ),
          ],
        ),
      ),
    );
  }
}
