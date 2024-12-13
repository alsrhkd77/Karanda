import 'package:flutter/material.dart';
import 'package:karanda/adventurer_hub/models/recruitment.dart';
import 'package:karanda/adventurer_hub/widgets/recruitment_list_card.dart';
import 'package:karanda/widgets/custom_base.dart';

class HomeTab extends StatefulWidget {
  final List<Recruitment> data;

  const HomeTab({super.key, required this.data});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  @override
  Widget build(BuildContext context) {
    return CustomBase(
      children: [
        ...widget.data.isEmpty
            ? [Text("empty")]
            : widget.data.map((item) => RecruitmentListCard(data: item)),
      ],
    );
  }
}
