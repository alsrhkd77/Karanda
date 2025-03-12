import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:karanda/common/blacklist_model.dart';
import 'package:provider/provider.dart';

import 'maretta_notifier.dart';

class MarettaBlacklistDialog extends StatefulWidget {
  const MarettaBlacklistDialog({super.key});

  @override
  State<MarettaBlacklistDialog> createState() => _MarettaBlacklistDialogState();
}

class _MarettaBlacklistDialogState extends State<MarettaBlacklistDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      insetPadding: const EdgeInsets.all(40),
      title: const Text('제외한 제보자'),
      content: Consumer<MarettaNotifier>(
        builder: (context, notifier, _) {
          if (notifier.blacklist.isEmpty) {
            return const Text('제외한 제보자가 없습니다');
          }
          return Column(
            children: notifier.blacklist.values
                .map((e) => _BlacklistTile(blocked: e))
                .toList(),
          );
        },
      ),
      actions: [
        ElevatedButton(onPressed: context.pop, child: const Text('확인'))
      ],
    );
  }
}

class _BlacklistTile extends StatelessWidget {
  final BlacklistModel blocked;

  const _BlacklistTile({super.key, required this.blocked});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      child: ListTile(
        title: Text(blocked.userName),
      ),
    );
  }
}
