import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:karanda/model/recruitment.dart';
import 'package:karanda/ui/core/ui/page_base.dart';
import 'package:karanda/ui/core/ui/section.dart';

class RecruitmentPostDetailTab extends StatelessWidget {
  final Recruitment data;

  const RecruitmentPostDetailTab({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return PageBase(
      children: [
        ListTile(
          title: Text(
            data.title,
            style: TextTheme.of(context)
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          trailing: Text(data.author.username),
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Chip(
                label: Text("제한 없음"),
                //avatar: Icon(FontAwesomeIcons.fire, size: 14,),
                avatar: Text("⚔️"),
              ),
              Chip(
                label: Text(
                  "${data.currentParticipants} / ${data.maxMembers}",
                ),
                avatar: const Icon(Icons.groups),
              ),
              Chip(
                label: Text(
                  context.tr(
                    "adventurer hub.recruitment type.${data.recruitmentType.name}",
                  ),
                ),
              ),
            ],
          ),
        ),
        Section(
          title: "모집 내용",
          child: Container(
            padding: const EdgeInsets.all(12.0),
            alignment: Alignment.centerLeft,
            child: SelectableText(data.content),
          ),
        ),
        data.privateContent.isEmpty
            ? const SizedBox()
            : Section(
                title: "참여자 전용",
                child: Container(
                  padding: const EdgeInsets.all(12.0),
                  alignment: Alignment.centerLeft,
                  child: SelectableText(data.privateContent),
                ),
              ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: _CreatedAt(
            createdAt: data.createdAt,
            updatedAt: data.updatedAt,
          ),
        ),
      ],
    );
  }
}

class _CreatedAt extends StatelessWidget {
  final DateTime createdAt;
  final DateTime? updatedAt;

  const _CreatedAt({super.key, required this.createdAt, this.updatedAt});

  @override
  Widget build(BuildContext context) {
    final locale = context.locale.toStringWithSeparator();
    final style = TextTheme.of(context).bodySmall?.copyWith(color: Colors.grey);
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        DateFormat.yMMMEd(locale).format(createdAt),
        style: style,
      ),
    );
  }
}
