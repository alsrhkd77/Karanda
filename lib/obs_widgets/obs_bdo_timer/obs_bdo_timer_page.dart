import 'package:flutter/material.dart';

class ObsBdoTimerPage extends StatefulWidget {
  const ObsBdoTimerPage({super.key});

  @override
  State<ObsBdoTimerPage> createState() => _ObsBdoTimerPageState();
}

class _ObsBdoTimerPageState extends State<ObsBdoTimerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Card(
          child: Text(DateTime.now().toString()),
        ),
      ),
    );
  }
}
