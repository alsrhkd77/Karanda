import 'package:flutter/material.dart';
import 'package:karanda/widgets/default_app_bar.dart';

class ShipUpgradingPage extends StatefulWidget {
  const ShipUpgradingPage({super.key});

  @override
  State<ShipUpgradingPage> createState() => _ShipUpgradingPageState();
}

class _ShipUpgradingPageState extends State<ShipUpgradingPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: DefaultAppBar(),
    );
  }
}
