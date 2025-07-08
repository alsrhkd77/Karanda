import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:karanda/enums/recruitment_type.dart';
import 'package:karanda/model/recruitment.dart';
import 'package:karanda/ui/core/ui/karanda_app_bar.dart';
import 'package:karanda/ui/core/ui/loading_indicator.dart';
import 'package:karanda/ui/core/ui/loading_indicator_dialog.dart';
import 'package:karanda/ui/core/ui/snack_bar_kit.dart';
import 'package:karanda/ui/party_finder/widgets/recruitment_post_detail_tab.dart';
import 'package:karanda/utils/extension/go_router_extension.dart';
import 'package:provider/provider.dart';

import '../controllers/recruitment_post_controller.dart';
import 'edit_recruitment_post_page.dart';
import 'recruitment_post_applicants_tab.dart';

class RecruitmentPostPage extends StatefulWidget {
  final int postId;

  const RecruitmentPostPage({super.key, required this.postId});

  @override
  State<RecruitmentPostPage> createState() => _RecruitmentPostPageState();
}

class _RecruitmentPostPageState extends State<RecruitmentPostPage>
    with TickerProviderStateMixin {
  late final TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => RecruitmentPostController(
        partyFinderService: context.read(),
        postId: widget.postId,
      )..getPost(postId: widget.postId),
      child: Consumer(
        builder: (context, RecruitmentPostController controller, child) {
          if (controller.recruitment == null) {
            return Scaffold(
              appBar: KarandaAppBar(
                icon: FontAwesomeIcons.circleNodes,
                title: context.tr("partyFinder.partyFinder"),
              ),
              body: const LoadingIndicator(),
            );
          }
          final Recruitment data = controller.recruitment!;
          return Scaffold(
            appBar: KarandaAppBar(
              icon: FontAwesomeIcons.circleNodes,
              title: context.tr("partyFinder.partyFinder"),
              actions: [
                controller.isOwner ? _EditButton(data: data) : const SizedBox(),
              ],
              bottom: controller.isOwner &&
                      data.recruitmentType == RecruitmentType.karandaReservation
                  ? TabBar(
                      controller: tabController,
                      tabs: const [
                        Tab(icon: Icon(Icons.description)),
                        Tab(icon: Icon(Icons.groups)),
                      ],
                    )
                  : null,
            ),
            body: controller.isOwner
                ? TabBarView(
                    controller: tabController,
                    children: [
                      RecruitmentPostDetailTab(data: data),
                      RecruitmentPostApplicantsTab(
                        applicants: controller.applicants,
                        accept: controller.accept,
                        reject: controller.reject,
                      ),
                    ],
                  )
                : RecruitmentPostDetailTab(data: data),
            floatingActionButton: controller.isOwner ||
                    data.recruitmentType == RecruitmentType.karandaReservation
                ? _FAB(
                    isOwner: controller.isOwner,
                    isOpened: controller.isOpened,
                    isJoined: controller.applicant != null,
                    authenticated: controller.user != null,
                    join: controller.join,
                    cancel: controller.cancel,
                    updatePostStatus: controller.changePostStatus,
                  )
                : null,
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
          );
        },
      ),
    );
  }
}

class _FAB extends StatefulWidget {
  final bool isOwner;
  final bool isOpened;
  final bool isJoined;
  final bool authenticated;
  final Future<bool> Function() join;
  final Future<bool> Function() cancel;
  final Future<bool> Function() updatePostStatus;

  const _FAB({
    super.key,
    required this.isOwner,
    required this.isOpened,
    required this.isJoined,
    required this.authenticated,
    required this.join,
    required this.cancel,
    required this.updatePostStatus,
  });

  @override
  State<_FAB> createState() => _FABState();
}

class _FABState extends State<_FAB> {
  Future<void> submit() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const LoadingIndicatorDialog(),
    );
    bool result = false;
    if (widget.isJoined) {
      result = await widget.cancel();
    } else {
      result = await widget.join();
    }
    if (mounted) {
      Navigator.of(context).pop();
      if (result) {
        SnackBarKit.of(context).requestFailed();
      }
    }
  }

  Future<void> updateStatus() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const LoadingIndicatorDialog(),
    );
    final result = await widget.updatePostStatus();
    if (mounted) {
      Navigator.of(context).pop();
      if (!result) {
        SnackBarKit.of(context).requestFailed();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isOwner) {
      return FloatingActionButton.extended(
        onPressed: updateStatus,
        backgroundColor: widget.isOpened ? Colors.red : null,
        foregroundColor: widget.isOpened ? Colors.white : null,
        icon:
            widget.isOpened ? const Icon(Icons.close) : const Icon(Icons.check),
        label: Text(
          context.tr(
            "partyFinder.post.${widget.isOpened ? "close" : "open"}",
          ),
        ),
      );
    } else if (widget.isJoined) {
      return FloatingActionButton.extended(
        onPressed: submit,
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.close),
        label: Text(
          context.tr("partyFinder.post.cancel"),
        ),
      );
    }
    return FloatingActionButton.extended(
      onPressed: widget.isOpened
          ? () {
              if (widget.authenticated) {
                submit();
              } else {
                SnackBarKit.of(context).needLogin();
              }
            }
          : null,
      backgroundColor: widget.isOpened ? null : Colors.grey.shade700,
      foregroundColor: widget.isOpened ? null : Colors.white,
      icon: const Icon(Icons.check),
      label: Text(
        context.tr(
          "partyFinder.post.join",
        ),
      ),
    );
  }
}

class _EditButton extends StatelessWidget {
  final Recruitment data;

  const _EditButton({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        final Recruitment? result = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => EditRecruitmentPostPage(
              region: data.region,
              recruitment: data,
            ),
          ),
        );
        if (context.mounted && result != null) {
          Navigator.of(context).pop();
          context.goWithGa("/party-finder/recruit/${result.id}");
        }
      },
      icon: const Icon(Icons.edit),
    );
  }
}
