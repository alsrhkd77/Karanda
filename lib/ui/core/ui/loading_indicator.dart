import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingIndicator extends StatelessWidget {
  final double size;

  const LoadingIndicator({Key? key, this.size = 120.0}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 120.0,
        height: 120.0,
        margin: const EdgeInsets.all(30.0),
        child: AspectRatio(
          aspectRatio: 1.0,
          child: SpinKitDualRing(
            size: size,
            color: Colors.blue,
          ),
        ),
      ),
    );
  }
}
