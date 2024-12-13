import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:karanda/adventurer_hub/models/recruitment.dart';
import 'package:karanda/adventurer_hub/recruitment_data_controller.dart';
import 'package:karanda/adventurer_hub/widgets/recruitment_status_chip.dart';
import 'package:karanda/auth/auth_notifier.dart';
import 'package:karanda/common/date_time_extension.dart';
import 'package:karanda/common/enums/recruitment_category.dart';
import 'package:karanda/common/global_properties.dart';
import 'package:karanda/widgets/button_loading_indicator.dart';
import 'package:karanda/widgets/class_symbol_widget.dart';
import 'package:karanda/widgets/custom_base.dart';
import 'package:karanda/widgets/default_app_bar.dart';
import 'package:karanda/widgets/loading_indicator.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as developer;

class RecruitmentDetailPage extends StatefulWidget {
  final int postId;
  final bool authenticated;

  const RecruitmentDetailPage({
    super.key,
    required this.postId,
    required this.authenticated,
  });

  @override
  State<RecruitmentDetailPage> createState() => _RecruitmentDetailPageState();
}

class _RecruitmentDetailPageState extends State<RecruitmentDetailPage> {
  late RecruitmentDataController dataController;

  @override
  void initState() {
    dataController = RecruitmentDataController(
      postId: widget.postId,
      authenticated: widget.authenticated,
    );
    super.initState();
  }

  void showResultSnackBar(bool status) {
    final snackbar = SnackBar(
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      margin: GlobalProperties.snackBarMargin,
      showCloseIcon: true,
      content:
          Text("recruitment post detail.${status ? "success" : "failed"}").tr(),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: dataController.recruitmentStream,
      builder: (context, snapshot) {
        return Scaffold(
          appBar: DefaultAppBar(
            title: "모험가 허브 (Beta)",
            icon: FontAwesomeIcons.circleNodes,
            actions: !snapshot.hasData || !widget.authenticated
                ? null
                : [
                    Padding(
                      padding: GlobalProperties.appBarActionPadding,
                      child: IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.more_vert),
                      ),
                    )
                  ],
          ),
          body: !snapshot.hasData
              ? const LoadingIndicator()
              : CustomBase(
                  children: [
                    Text(
                      snapshot.requireData.createdAt!.toLocal().format(null),
                      style: const TextStyle(color: Colors.grey),
                    ),
                    _BodyCard(post: snapshot.requireData),
                    Consumer<AuthNotifier>(
                      builder: (context, auth, _) {
                        if (!auth.authenticated) {
                          return const SizedBox();
                        }
                        String author = snapshot.requireData.author!.discordId;
                        bool status = snapshot.requireData.status;
                        return _StatusButton(
                          status: auth.discordId == author ? !status : status,
                          onPressed: () async {
                            bool result = false;
                            if (auth.discordId == author) {
                              result = await dataController.changePostStatus();
                            } else {
                              result = await dataController.changeApplyStatus();
                            }
                            showResultSnackBar(result);
                          },
                          name: auth.discordId == author
                              ? (status ? "close" : "open")
                              : (status ? "apply" : "cancel"),
                        );
                      },
                    ),
                  ],
                ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: null,
            label: Text(
              "모집 인원\n1 / 15",
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    dataController.dispose();
    super.dispose();
  }
}

class _StatusButton extends StatefulWidget {
  final bool status;
  final Future<void> Function() onPressed;
  final String name;

  const _StatusButton({
    super.key,
    required this.status,
    required this.onPressed,
    required this.name,
  });

  @override
  State<_StatusButton> createState() => _StatusButtonState();
}

class _StatusButtonState extends State<_StatusButton> {
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
          backgroundColor: widget.status ? null : Colors.red,
        ),
        onPressed: submit,
        child: request
            ? const ButtonLoadingIndicator(color: Colors.white)
            : Text("recruitment post detail.action.${widget.name}").tr(),
      ),
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
              leading: RecruitmentStatusChip(status: post.status),
              title: Text(
                post.category == RecruitmentCategory.guildRaidMercenaries
                    ? '<${post.guildName}> ${post.title}'
                    : post.title,
                textAlign: TextAlign.center,
              ),
              trailing: Tooltip(
                message: context.tr("recruitment post detail.copy"),
                child: InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(6.0),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                            post.author!.mainFamily!.familyName,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        ClassSymbolWidget(
                          className: post.author!.mainFamily!.mainClass.name,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
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
          onPressed: () {},
          child: Text(link!),
        ),
      );
    }
    return const SizedBox();
  }
}
