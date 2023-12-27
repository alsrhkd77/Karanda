import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingIndicator extends StatelessWidget {
  final double size;

  const LoadingIndicator({Key? key, this.size = 120.0}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: SpinKitPulsingGrid(
          size: size,
          color: Colors.blue,
        ),
      ),
    );
  }
}
