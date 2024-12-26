import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:karanda/common/enums/applicant_status.dart';

class ApplicantStatusChip extends StatelessWidget {
  final ApplicantStatus status;

  const ApplicantStatusChip({super.key, required this.status});

  Color? get backgroundColor => getBackgroundColor();

  Color? getBackgroundColor() {
    switch (status) {
      case ApplicantStatus.approved:
        return Colors.green;
      case ApplicantStatus.canceled:
        return Colors.red;
      case ApplicantStatus.rejected:
        return Colors.red;
      case ApplicantStatus.applied:
        return Colors.orangeAccent;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(context.tr("recruitment post detail.chip.${status.name}")),
      backgroundColor: backgroundColor,
      labelStyle: const TextStyle(color: Colors.white),
      side: BorderSide.none,
    );
  }
}
