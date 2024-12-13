import 'package:flutter/material.dart';
import 'package:karanda/adventurer_hub/models/recruitment.dart';
import 'package:karanda/common/go_router_extension.dart';

class RecruitmentListCard extends StatefulWidget {
  final Recruitment data;

  const RecruitmentListCard({super.key, required this.data});

  @override
  State<RecruitmentListCard> createState() => _RecruitmentListCardState();
}

class _RecruitmentListCardState extends State<RecruitmentListCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        title: Text(widget.data.title),
        subtitle: Row(
          children: [
            Text(widget.data.author!.mainFamily?.familyName ?? widget.data.author!.username)
          ],
        ),
        onTap: (){
          context.goWithGa('/adventurer-hub/posts/${widget.data.id}');
        },
      ),
    );
  }
}
