import 'package:flutter/material.dart';
import 'package:karanda/bdo_news/widgets/bdo_event_widget.dart';
import 'package:karanda/bdo_news/widgets/bdo_update_widget.dart';

class HomeNewsSection extends StatelessWidget {
  final int count;
  const HomeNewsSection({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: count,
      childAspectRatio: 1.25,
      children: [
        BdoEventWidget(), BdoUpdateWidget(),
      ],
    );
  }
}
