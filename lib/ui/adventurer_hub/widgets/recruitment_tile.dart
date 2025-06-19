import 'package:flutter/material.dart';
import 'package:karanda/model/recruitment.dart';
import 'package:karanda/ui/adventurer_hub/widgets/recruitment_status_icon.dart';
import 'package:karanda/utils/extension/go_router_extension.dart';

class RecruitmentTile extends StatelessWidget {
  final Recruitment data;

  const RecruitmentTile({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        title: Text(data.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _SpecLimit(specLimit: data.specLimit),
                _MemberCount(
                  current: data.currentParticipants,
                  slot: data.maxMembers,
                ),
              ],
            ),
            Text(data.author.username),
          ],
        ),
        trailing: RecruitmentStatusIcon(status: data.status),
        onTap: () {
          context.goWithGa("/adventurer-hub/recruit/${data.id}");
        },
      ),
    );
  }
}

class _SpecLimit extends StatelessWidget {
  final int? specLimit;

  const _SpecLimit({super.key, this.specLimit});

  @override
  Widget build(BuildContext context) {
    if (specLimit != null) {
      return Row(
        children: [
          //const Icon(FontAwesomeIcons.fire),
          const Text("⚔️"),
          Text(specLimit.toString()),
          const SizedBox(width: 12),
        ],
      );
    }
    return const SizedBox();
  }
}

class _MemberCount extends StatelessWidget {
  final int current;
  final int slot;

  const _MemberCount({super.key, required this.current, required this.slot});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.groups, size: 16),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(
            "$current / $slot",
            style: TextTheme.of(context).labelMedium,
          ),
        ),
      ],
    );
  }
}
