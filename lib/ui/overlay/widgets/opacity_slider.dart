import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class OpacitySlider extends StatelessWidget {
  final int opacity;
  final void Function(double) onChanged;

  const OpacitySlider({
    super.key,
    required this.opacity,
    required this.onChanged,
  });

  double get value => opacity / 255;
  int get percent => (value * 100).round();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(context.tr("overlay.settings.opacity")),
      subtitle: Slider(
        value: value,
        onChanged: onChanged,
        divisions: 100,
        label: "$percent%",
      ),
    );
  }
}
