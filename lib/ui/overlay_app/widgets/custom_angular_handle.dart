import 'package:flutter/material.dart';
import 'package:flutter_box_transform/flutter_box_transform.dart';

class CustomAngularHandle extends StatelessWidget {
  final HandlePosition handle;

  const CustomAngularHandle({super.key, required this.handle});

  @override
  Widget build(BuildContext context) {
    return AngularHandle(
      handle: handle,
      thickness: 3.0,
      color: Colors.blue,
    );
  }
}
