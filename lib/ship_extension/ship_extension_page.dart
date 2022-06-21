import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:karanda/common/custom_scroll_behavior.dart';
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
  int _count = 15;
  final List<TextEditingController> _textControllers = [];

  Widget buildItemList(){
    return Container(
      margin: const EdgeInsets.all(12.0),
      height: _count * 104,
      width: 635 + 48 + 400,
      child: ListView.builder(
        itemCount: _count,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index){
          if(_textControllers.length < index + 1){
            _textControllers.add(TextEditingController());
          }else{
            _textControllers[index] = TextEditingController();
          }
          return ItemWidget(
            textField: TextField(
              controller: _textControllers[index],
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                    RegExp(r'^(\d{0,3})')),
              ],
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(color: Colors.blue),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DefaultAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: ListTile(
                leading: Icon(FontAwesomeIcons.ship),
                title: TitleText('선박 증축', bold: true,),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: LinearPercentIndicator(
                width: MediaQuery.of(context).size.width - 25,
                animation: true,
                lineHeight: 25.0,
                animationDuration: 1500,
                percent: 0.1,
                center: Text("13.0%"),
                barRadius: const Radius.circular(15.0),
                progressColor: Colors.blue,
              ),
            ),
            SizedBox(
              height: (_count * 104) + 24,
              child: ScrollConfiguration(
                behavior: CustomScrollBehavior(),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: buildItemList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
