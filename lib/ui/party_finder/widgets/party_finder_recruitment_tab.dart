import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:karanda/model/recruitment.dart';
import 'package:karanda/ui/core/ui/page_base.dart';
import 'package:karanda/ui/party_finder/widgets/recruitment_tile.dart';

class PartyFinderRecruitmentTab extends StatelessWidget {
  final List<Recruitment> data;

  const PartyFinderRecruitmentTab({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if(data.isEmpty){
      return Center(
        child: Text(context.tr("partyFinder.noPosts")),
      );
    }
    return PageBase(
      children: data.map((value) => RecruitmentTile(data: value)).toList(),
    );
  }
}
