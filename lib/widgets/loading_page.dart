import 'package:flutter/material.dart';
import 'package:karanda/widgets/default_app_bar.dart';
import 'package:karanda/widgets/loading_indicator.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: DefaultAppBar(),
      body: Center(
        child: LoadingIndicator(),
      ),
    );
  }
}
