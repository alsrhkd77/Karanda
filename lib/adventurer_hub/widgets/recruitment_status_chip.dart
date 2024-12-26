import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class RecruitmentStatusChip extends StatelessWidget {
  final bool status;

  const RecruitmentStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        context.tr(
          "recruitment post detail.chip.${status ? "open" : "closed"}",
        ),
      ),
      backgroundColor: status ? Colors.green : Colors.red,
      labelStyle: const TextStyle(color: Colors.white),
      side: BorderSide.none,
    );
  }
}
