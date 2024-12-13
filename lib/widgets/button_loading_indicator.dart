import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ButtonLoadingIndicator extends StatelessWidget {
  final double size;
  final Color color;

  const ButtonLoadingIndicator({
    super.key,
    this.size = 15.0,
    this.color = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return SpinKitThreeBounce(
      size: size,
      color: color,
    );
  }
}
