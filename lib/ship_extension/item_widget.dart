import 'package:flutter/material.dart';

class ItemWidget extends StatefulWidget {
  final Widget textField;

  const ItemWidget({Key? key, required this.textField}) : super(key: key);

  @override
  State<ItemWidget> createState() => _ItemWidgetState();
}

class _ItemWidgetState extends State<ItemWidget> {

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(4.0),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(12.0),
        height: 80,
        child: Row(
          children: [
            Container(
              width: 135,
              margin: EdgeInsets.symmetric(horizontal: 6.0),
              child: Text('짙은 파도빛이 감도는 규격 각목', overflow: TextOverflow.clip, textAlign: TextAlign.center),
            ),
            VerticalDivider(),
            Container(
              width: 470,
              margin: EdgeInsets.symmetric(horizontal: 6.0),
              child: Text('[일일] 그믐달 길드의 검은무쇠이빨 사냥꾼 ( 1개 ) - 오킬루아의 눈 <라비켈>', textAlign: TextAlign.left),
            ),
            VerticalDivider(),
            Container(
              width: 60,
              child: widget.textField,
            ),
            VerticalDivider(),
            Container(
              width: 40,
              margin: EdgeInsets.symmetric(horizontal: 6.0),
              child: Text('600개', textAlign: TextAlign.center),
            ),
            VerticalDivider(),
            Container(
              width: 30,
              margin: EdgeInsets.symmetric(horizontal: 6.0),
              child: Text('남은 일수', textAlign: TextAlign.center),
            ),
            VerticalDivider(),
            Container(
              width: 30,
              margin: EdgeInsets.symmetric(horizontal: 6.0),
              child: Text('소요 일수', textAlign: TextAlign.center),
            ),
            VerticalDivider(),
            Container(
              width: 70,
              margin: EdgeInsets.symmetric(horizontal: 6.0),
              child: Text('1500 주화', textAlign: TextAlign.center),
            ),
          ],
        ),
      ),
    );
  }
}
