import 'package:flutter/material.dart';
import 'package:karanda/widgets/default_app_bar.dart';

class TradePathExplorer extends StatefulWidget {
  const TradePathExplorer({Key? key}) : super(key: key);

  @override
  State<TradePathExplorer> createState() => _TradePathExplorerState();
}

class _TradePathExplorerState extends State<TradePathExplorer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DefaultAppBar(),
      body: ListView(
        children: [
          ListTile(title: Text('경로 탐색기'),),
        ],
      ),
    );
  }
}
