import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:karanda/adventurer_hub/models/recruitment.dart';
import 'package:karanda/adventurer_hub/widgets/applicant_status_chip.dart';
import 'package:karanda/adventurer_hub/widgets/recruitment_list_card.dart';
import 'package:karanda/adventurer_hub/widgets/recruitment_status_chip.dart';
import 'package:karanda/auth/auth_notifier.dart';
import 'package:karanda/common/enums/applicant_status.dart';
import 'package:karanda/common/enums/recruit_method.dart';
import 'package:karanda/common/go_router_extension.dart';
import 'package:karanda/widgets/custom_base.dart';
import 'package:karanda/widgets/discord_name_widget.dart';
import 'package:karanda/widgets/family_name_widget.dart';
import 'package:provider/provider.dart';

class HomeTab extends StatefulWidget {
  final List<Recruitment> posts;

  const HomeTab({super.key, required this.posts});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  @override
  Widget build(BuildContext context) {
    return CustomBase(
      children: [
        _UserCard(
          posts: widget.posts,
        ),
        ListTile(
          title: Text(context.tr("recruitment post")),
        ),
        ...widget.posts.isEmpty
            ? [Text("empty")]
            : widget.posts.map((item) => RecruitmentListCard(post: item)),
      ],
    );
  }
}

class _UserCard extends StatelessWidget {
  final List<Recruitment> posts;

  const _UserCard({super.key, required this.posts});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: Consumer<AuthNotifier>(builder: (context, auth, _) {
        if (!auth.authenticated) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              context.tr("login required"),
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              ListTile(
                title: auth.mainFamily == null || !auth.mainFamily!.verified
                    ? DiscordNameWidget(user: auth.user!)
                    : FamilyNameWidget(family: auth.user!.mainFamily!),
                trailing: auth.mainFamily == null || !auth.mainFamily!.verified
                    ? const _RequireMainFamily()
                    : null,
              ),
              const Divider(),
              ListTile(
                title: Text(context.tr("adventurer hub.recently applied")),
              ),
              _RecentlyApplied(
                posts: posts
                    .where((data) => data.applicant != null)
                    .take(3)
                    .toList(),
              ),
              const Divider(),
              ListTile(
                title: Text(context.tr("adventurer hub.my posts")),
              ),
              _MyPosts(
                posts: posts
                    .where((data) => data.author!.discordId == auth.discordId)
                    .take(3)
                    .toList(),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _RecentlyApplied extends StatelessWidget {
  final List<Recruitment> posts;

  const _RecentlyApplied({super.key, required this.posts});

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return SizedBox(
        height: 48,
        child: Center(
          child: Text(
            context.tr("adventurer hub.recently applied empty"),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Column(
        children: posts.map((post) => _AppliedPostTile(post: post)).toList(),
      ),
    );
  }
}

class _MyPosts extends StatelessWidget {
  final List<Recruitment> posts;

  const _MyPosts({super.key, required this.posts});

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return SizedBox(
        height: 48,
        child: Center(
          child: Text(
            context.tr("adventurer hub.my posts empty"),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Column(
        children: posts.map((post) => _MyPostTile(post: post)).toList(),
      ),
    );
  }
}

class _AppliedPostTile extends StatelessWidget {
  final Recruitment post;

  const _AppliedPostTile({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    String members = post.maximumParticipants.toString();
    if (post.recruitMethod == RecruitMethod.karandaReservation) {
      members = "${post.currentParticipants} / ${post.maximumParticipants}";
    }
    return ListTile(
      leading: ApplicantStatusChip(status: post.applicant!.status),
      title: Text(post.title),
      subtitle: Text(post.createdAt.toString()),
      trailing: Text(
      context.tr("adventurer hub.members", args: [members]),
      textAlign: TextAlign.center,
    ),
      onTap: () {
        context.goWithGa('/adventurer-hub/posts/${post.id}');
      },
    );
  }
}

class _MyPostTile extends StatelessWidget {
  final Recruitment post;

  const _MyPostTile({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: RecruitmentStatusChip(status: post.status),
      title: Text(post.title),
      subtitle: Text(post.createdAt.toString()),
      trailing: Text(
        context.tr(
          "adventurer hub.members",
          args: ["${post.currentParticipants} / ${post.maximumParticipants}"],
        ),
        textAlign: TextAlign.center,
      ),
      onTap: () {
        context.goWithGa('/adventurer-hub/posts/${post.id}');
      },
    );
  }
}

class _RequireMainFamily extends StatelessWidget {
  const _RequireMainFamily({super.key});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: context.tr("adventurer hub.require main family"),
      child: const Icon(
        Icons.error,
        color: Colors.red,
      ),
    );
  }
}
