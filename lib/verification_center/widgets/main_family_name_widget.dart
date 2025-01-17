import 'package:flutter/material.dart';
import 'package:karanda/auth/auth_notifier.dart';
import 'package:karanda/verification_center/models/bdo_family.dart';
import 'package:provider/provider.dart';

class MainFamilyNameWidget extends StatelessWidget {
  final BdoFamily family;

  const MainFamilyNameWidget({super.key, required this.family});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(family.familyName),
        Provider.of<AuthNotifier>(context).mainFamily?.isSame(family) ?? false
            ? const _MainFamilyChip()
            : const SizedBox(),
      ],
    );
  }
}

class _MainFamilyChip extends StatelessWidget {
  const _MainFamilyChip({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.0),
      child: Chip(
        label: Text('대표'),
        padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        backgroundColor: Colors.blue,
        labelStyle: TextStyle(color: Colors.white),
        side: BorderSide.none,
      ),
    );
  }
}
