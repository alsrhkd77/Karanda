import 'package:flutter/material.dart';

class EditModeCardWidget extends StatelessWidget {
  final String title;

  const EditModeCardWidget({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Center(
        child: Text(
          title,
          style: Theme.of(context).textTheme.displayMedium,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
