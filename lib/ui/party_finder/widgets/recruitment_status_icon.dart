import 'package:flutter/material.dart';

class RecruitmentStatusIcon extends StatelessWidget {
  final bool status;

  const RecruitmentStatusIcon({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: status ? "Opened" : "Closed",
      child: Icon(
        Icons.circle,
        color: status ? Colors.green : Colors.grey,
        size: 14,
      ),
    );
  }
}
