import 'package:flutter/material.dart';

class MarettaBlacklistDialog extends StatefulWidget {
  const MarettaBlacklistDialog({super.key});

  @override
  State<MarettaBlacklistDialog> createState() => _MarettaBlacklistDialogState();
}

class _MarettaBlacklistDialogState extends State<MarettaBlacklistDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('제외한 제보자'),
      content: Column(
        children: [],
      ),
    );
  }
}
