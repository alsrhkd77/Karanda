import 'package:flutter/material.dart';
import 'package:karanda/deprecated/verification_center/models/main_family.dart';
import 'package:karanda/widgets/class_symbol_widget.dart';

class FamilyNameWidget extends StatelessWidget {
  final MainFamily family;

  const FamilyNameWidget({super.key, required this.family});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: Text(family.familyName),
        ),
        ClassSymbolWidget(
          className: family.mainClass.name,
        ),
      ],
    );
  }
}
