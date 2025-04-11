import 'package:flutter/material.dart';
import 'package:karanda/ui/core/ui/loading_indicator.dart';

class LoadingIndicatorPage extends StatelessWidget {
  const LoadingIndicatorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: LoadingIndicator(),
    );
  }
}
