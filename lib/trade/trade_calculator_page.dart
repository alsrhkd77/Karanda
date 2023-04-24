import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:karanda/trade/crow_coin_exchange_tab.dart';
import 'package:karanda/trade/material_cost_calculator_tab.dart';
import 'package:karanda/trade/overloaded_ship_tab.dart';
import 'package:karanda/trade/parley_calculator_tab.dart';
import 'package:karanda/widgets/default_app_bar.dart';

class TradeCalculatorPage extends StatefulWidget {
  const TradeCalculatorPage({Key? key}) : super(key: key);

  @override
  State<TradeCalculatorPage> createState() => _TradeCalculatorPageState();
}

class _TradeCalculatorPageState extends State<TradeCalculatorPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: const DefaultAppBar(
          bottom: TabBar(
            automaticIndicatorColorAdjustment: true,
            indicatorSize: TabBarIndicatorSize.tab,
            tabs: [
              Tab(
                icon: Icon(FontAwesomeIcons.weightHanging),
              ),
              Tab(
                icon: Icon(Icons.calculate),
              ),
              Tab(
                icon: Icon(FontAwesomeIcons.coins),
              ),
              Tab(
                icon: Icon(FontAwesomeIcons.solidHandshake),
              ),
            ],
          ),
        ),
        body: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus,
          child: Center(
            child: TabBarView(
              children: [
                OverloadedShipTab(),
                MaterialCostCalculatorTab(),
                CrowCoinExchangeTab(),
                ParleyCalculatorTab(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
