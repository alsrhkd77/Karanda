import 'package:flutter/material.dart';

class TitleText extends StatelessWidget {
  final String data;
  final bool bold;
  const TitleText(this.data, {Key? key, this.bold = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(data, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal, fontSize: 18.0),);
  }
}
