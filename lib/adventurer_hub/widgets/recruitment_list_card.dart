import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:karanda/adventurer_hub/models/recruitment.dart';
import 'package:karanda/adventurer_hub/widgets/recruitment_status_chip.dart';
import 'package:karanda/common/enums/recruit_method.dart';
import 'package:karanda/common/go_router_extension.dart';
import 'package:karanda/widgets/discord_name_widget.dart';
import 'package:karanda/widgets/family_name_widget.dart';

class RecruitmentListCard extends StatelessWidget {
  final Recruitment post;

  const RecruitmentListCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    String members = post.maximumParticipants.toString();
    if (post.recruitMethod == RecruitMethod.karandaReservation) {
      members = "${post.currentParticipants} / ${post.maximumParticipants}";
    }
    return Card(
      margin: const EdgeInsets.all(4),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0),
        leading: RecruitmentStatusChip(status: post.status),
        title: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(post.title),
        ),
        subtitle:
            post.author!.mainFamily != null && post.author!.mainFamily!.verified
                ? FamilyNameWidget(family: post.author!.mainFamily!)
                : DiscordNameWidget(user: post.author!),
        trailing: Text(
          context.tr("adventurer hub.members", args: [members]),
          textAlign: TextAlign.center,
        ),
        onTap: () {
          context.goWithGa('/adventurer-hub/posts/${post.id}');
        },
      ),
    );
  }
}
