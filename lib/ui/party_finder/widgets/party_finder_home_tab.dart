import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:karanda/enums/recruitment_join_status.dart';
import 'package:karanda/model/user.dart';
import 'package:karanda/ui/party_finder/widgets/recruitment_tile.dart';
import 'package:karanda/utils/extension/go_router_extension.dart';
import 'package:karanda/widgets/custom_base.dart';

import '../../../model/applicant.dart';
import '../../../model/recruitment.dart';
import '../../core/ui/class_symbol_widget.dart';
import '../../core/ui/section.dart';

class PartyFinderHomeTab extends StatelessWidget {
  final bool authenticated;
  final User? user;
  final List<Recruitment> recruitments;
  final List<Recruitment> applied;
  final List<Applicant> applicants;

  const PartyFinderHomeTab({
    super.key,
    required this.authenticated,
    this.user,
    required this.recruitments,
    required this.applied,
    required this.applicants,
  });

  @override
  Widget build(BuildContext context) {
    return CustomBase(children: [
      Section(
        icon: Icons.groups_outlined,
        title: context.tr("family.family"),
        child: _AccountInfo(authenticated: authenticated, user: user),
      ),
      authenticated
          ? _Section(
              icon: Icons.person_add_alt_1_outlined,
              title: context.tr("partyFinder.recentlyApplied"),
              child: applicants.isEmpty
                  ? Container(
                      height: 120,
                      alignment: Alignment.center,
                      child:
                          Text(context.tr("partyFinder.recentlyAppliedEmpty")),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: applicants.map((data) {
                        return _ApplicationTile(
                          applicant: data,
                          recruitment: applied.firstWhere((post) {
                            return post.id == data.postId;
                          }),
                        );
                      }).toList(),
                    ),
            )
          : const SizedBox(),
      authenticated
          ? _Section(
              icon: Icons.assignment_outlined,
              title: context.tr("partyFinder.myPosts"),
              child: recruitments.isEmpty
                  ? Container(
                      height: 120,
                      alignment: Alignment.center,
                      child: Text(context.tr("partyFinder.myPostsEmpty")),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: recruitments.map((data) {
                        return RecruitmentTile(data: data);
                      }).toList(),
                    ),
            )
          : const SizedBox(),
    ]);
  }
}

class _AccountInfo extends StatelessWidget {
  final bool authenticated;
  final User? user;

  const _AccountInfo({super.key, required this.authenticated, this.user});

  @override
  Widget build(BuildContext context) {
    if (!authenticated) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: Text(context.tr("needLogin")),
      );
    } else if (user?.family == null) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: Text(context.tr("family.empty")),
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          title: Text(context.tr("family.familyName")),
          trailing: Text(user!.family!.familyName),
        ),
        ListTile(
          title: Text(context.tr("family.mainClass")),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClassSymbolWidget(bdoClass: user!.family!.mainClass),
              Text(user!.family!.mainClass.name),
            ],
          ),
        ),
        ListTile(
          title: Text(context.tr("family.maxGearScore")),
          trailing: Text(user!.family?.maxGearScore?.toString() ?? "-"),
        ),
        ListTile(
          title: Text(context.tr("family.verificationStatus")),
          trailing: _Verified(value: user!.family?.verified ?? false),
        ),
        ListTile(
          title: Text(context.tr("family.lastUpdate")),
          trailing: Text(user!.family?.lastUpdated == null
              ? "-"
              : DateFormat.yMMMEd(context.locale.toStringWithSeparator())
                  .add_Hm()
                  .format(user!.family!.lastUpdated!)),
        ),
      ],
    );
  }
}

class _ApplicationTile extends StatelessWidget {
  final Applicant applicant;
  final Recruitment recruitment;

  const _ApplicationTile({
    super.key,
    required this.applicant,
    required this.recruitment,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        title: Text(recruitment.title),
        subtitle: Text(applicant.joinAt.toLocal().toString()),
        trailing: Tooltip(
          message: context.tr(
            "partyFinder.recruitmentJoinStatus.${applicant.status.name}",
          ),
          child: switch (applicant.status) {
            RecruitmentJoinStatus.pending => const Icon(Icons.pending_outlined),
            RecruitmentJoinStatus.accepted => const Icon(
                Icons.check_circle_outline,
                color: Colors.blue,
              ),
            RecruitmentJoinStatus.cancelled => const Icon(
                Icons.cancel_outlined,
                color: Colors.red,
              ),
            RecruitmentJoinStatus.rejected => const Icon(
                Icons.block,
                color: Colors.red,
              ),
          },
        ),
        onTap: () {
          context.goWithGa("/party-finder/recruit/${recruitment.id}");
        },
      ),
    );
  }
}

class _Verified extends StatelessWidget {
  final bool value;

  const _Verified({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(context.tr("family.${value ? "verified" : "unverified"}")),
        const SizedBox(
          width: 4,
        ),
        Icon(
          Icons.verified,
          color: value ? Colors.blue : Colors.grey,
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  final IconData? icon;
  final String title;
  final Widget child;

  const _Section({
    super.key,
    this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Column(
        children: [
          ListTile(
            title: Text(title),
            leading: icon == null ? null : Icon(icon),
          ),
          child,
        ],
      ),
    );
  }
}
