import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:karanda/adventurer_hub/models/applicant.dart';
import 'package:karanda/adventurer_hub/models/recruitment.dart';
import 'package:karanda/adventurer_hub/widgets/recruitment_status_chip.dart';
import 'package:karanda/auth/auth_notifier.dart';
import 'package:karanda/auth/user.dart';
import 'package:karanda/common/date_time_extension.dart';
import 'package:karanda/common/enums/applicant_status.dart';
import 'package:karanda/common/enums/recruit_method.dart';
import 'package:karanda/common/enums/recruitment_category.dart';
import 'package:karanda/common/launch_url.dart';
import 'package:karanda/widgets/button_loading_indicator.dart';
import 'package:karanda/widgets/custom_base.dart';
import 'package:karanda/widgets/discord_name_widget.dart';
import 'package:karanda/widgets/family_name_widget.dart';
import 'dart:developer' as developer;

import 'package:provider/provider.dart';

class RecruitmentDetailTab extends StatelessWidget {
  final Recruitment data;
  final Future<void> Function() applyFunction;
  final Future<void> Function() openFunction;

  const RecruitmentDetailTab(
      {super.key,
      required this.data,
      required this.applyFunction,
      required this.openFunction});

  @override
  Widget build(BuildContext context) {
    return CustomBase(
      children: [
        Text(
          data.createdAt!.toLocal().format(null),
          style: const TextStyle(color: Colors.grey),
        ),
        _BodyCard(post: data),
        _StatusButton(
          author: data.author!,
          status: data.status,
          applicant: data.applicant,
          method: data.recruitMethod,
          applyFunction: applyFunction,
          openFunction: openFunction,
        ),
      ],
    );
  }
}

class _StatusButton extends StatelessWidget {
  final Applicant? applicant;
  final User author;
  final bool status;
  final RecruitMethod method;
  final Future<void> Function() applyFunction;
  final Future<void> Function() openFunction;

  const _StatusButton({
    super.key,
    required this.applicant,
    required this.author,
    required this.status,
    required this.applyFunction,
    required this.openFunction,
    required this.method,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthNotifier>(
      builder: (context, auth, _) {
        if (auth.authenticated) {
          if (auth.discordId == author.discordId) {
            return _Button(
              onPressed: openFunction,
              name: status ? "close" : "open",
              color: status ? Colors.red : null,
            );
          } else if (method == RecruitMethod.karandaReservation) {
            if (applicant == null && status) {
              return _Button(
                onPressed: applyFunction,
                name: "apply",
              );
            } else if (applicant!.status != ApplicantStatus.rejected &&
                applicant!.status != ApplicantStatus.canceled) {
              return _Button(
                onPressed: applyFunction,
                name: "cancel",
                color: Colors.red,
              );
            }
          }
        }
        return const SizedBox();
      },
    );
  }
}

class _BodyCard extends StatelessWidget {
  final Recruitment post;

  const _BodyCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              leadingAndTrailingTextStyle:
                  Theme.of(context).textTheme.bodyMedium,
              leading: RecruitmentStatusChip(status: post.status),
              title: Text(
                post.category == RecruitmentCategory.guildWarHeroes
                    ? '<${post.guildName}> ${post.title}'
                    : post.title,
                textAlign: TextAlign.center,
              ),
              subtitle: _Members(
                method: post.recruitMethod,
                current: post.currentParticipants,
                max: post.maximumParticipants,
              ),
              trailing: _Author(author: post.author!),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 12.0,
                horizontal: 14.0,
              ),
              child: Text(post.content ?? ""),
            ),
            _DiscordLinkButton(link: post.discordLink),
          ],
        ),
      ),
    );
  }
}

class _Button extends StatefulWidget {
  final Future<void> Function() onPressed;
  final String name;
  final Color? color;

  const _Button({
    super.key,
    required this.onPressed,
    required this.name,
    this.color,
  });

  @override
  State<_Button> createState() => _ButtonState();
}

class _ButtonState extends State<_Button> {
  bool request = false;

  Future<void> submit() async {
    if (!request) {
      setState(() {
        request = true;
      });
      try {
        await widget.onPressed();
      } catch (e) {
        developer.log(e.toString());
      } finally {
        setState(() {
          request = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.color,
          padding: const EdgeInsets.symmetric(
            vertical: 18.0,
            horizontal: 4.0,
          ),
        ),
        onPressed: submit,
        child: request
            ? const ButtonLoadingIndicator(color: Colors.white)
            : Text(context.tr("recruitment post detail.action.${widget.name}")),
      ),
    );
  }
}

class _Members extends StatelessWidget {
  final RecruitMethod method;
  final int current;
  final int max;

  const _Members({
    super.key,
    required this.method,
    required this.current,
    required this.max,
  });

  @override
  Widget build(BuildContext context) {
    if (method == RecruitMethod.karandaReservation) {
      return Text(
        context.tr(
          "recruitment post detail.max count with current",
          args: [current.toString(), max.toString()],
        ),
        textAlign: TextAlign.center,
      );
    }
    return Text(
      context.tr(
        "recruitment post detail.max count",
        args: [max.toString()],
      ),
      textAlign: TextAlign.center,
    );
  }
}

class _Author extends StatelessWidget {
  final User author;

  const _Author({super.key, required this.author});

  @override
  Widget build(BuildContext context) {
    if (author.mainFamily == null || !author.mainFamily!.verified) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: DiscordNameWidget(user: author),
      );
    }
    return Tooltip(
      message: context.tr("recruitment post detail.copy family name"),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(6.0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: FamilyNameWidget(family: author.mainFamily!),
        ),
      ),
    );
  }
}

class _DiscordLinkButton extends StatelessWidget {
  final String? link;

  const _DiscordLinkButton({super.key, this.link});

  @override
  Widget build(BuildContext context) {
    if (link != null && link!.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 12.0,
          horizontal: 14.0,
        ),
        child: TextButton(
          onPressed: () => launchURL(link!),
          child: Text(link!),
        ),
      );
    }
    return const SizedBox();
  }
}
