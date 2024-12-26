import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:karanda/adventurer_hub/models/applicant.dart';
import 'package:karanda/adventurer_hub/models/recruitment.dart';
import 'package:karanda/adventurer_hub/recruitment_data_controller.dart';
import 'package:karanda/adventurer_hub/recruitment_edit_page.dart';
import 'package:karanda/adventurer_hub/tabs/recruitment_applicants_tab.dart';
import 'package:karanda/adventurer_hub/tabs/recruitment_detail_tab.dart';
import 'package:karanda/auth/auth_notifier.dart';
import 'package:karanda/common/enums/applicant_status.dart';
import 'package:karanda/common/enums/recruit_method.dart';
import 'package:karanda/common/global_properties.dart';
import 'package:karanda/widgets/default_app_bar.dart';
import 'package:karanda/widgets/loading_indicator.dart';
import 'package:provider/provider.dart';

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

class _RecruitmentDetailPageState extends State<RecruitmentDetailPage>
    with TickerProviderStateMixin {
  late RecruitmentDataController dataController;
  late final TabController tabController;

  @override
  void initState() {
    dataController = RecruitmentDataController(
      postId: widget.postId,
      authenticated: widget.authenticated,
    );
    super.initState();
    tabController = TabController(length: 2, vsync: this);
  }

  Future<void> apply() async {
    bool result = false;
    result = await dataController.changeApplyStatus();
    if (!result) {
      showResultSnackBar(result);
    }
  }

  Future<void> openPost() async {
    bool result = false;
    result = await dataController.changePostStatus();
    if (!result) {
      showResultSnackBar(result);
    }
  }

  void showResultSnackBar(bool status) {
    final snackbar = SnackBar(
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      margin: GlobalProperties.snackBarMargin,
      showCloseIcon: true,
      content: Text(context
          .tr("recruitment post detail.${status ? "success" : "failed"}")),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthNotifier>(context);
    return StreamBuilder(
      stream: dataController.recruitmentStream,
      builder: (context, snapshot) {
        return Scaffold(
          appBar: DefaultAppBar(
            title: context.tr("adventurer hub title"),
            icon: FontAwesomeIcons.circleNodes,
            actions: snapshot.hasData && auth.authenticated
                ? [
                    _MenuButton(
                      post: snapshot.requireData,
                      updatePost: dataController.updatePost,
                    )
                  ]
                : null,
            bottom: snapshot.hasData &&
                    auth.authenticated &&
                    snapshot.requireData.author!.discordId == auth.discordId &&
                    snapshot.requireData.recruitMethod ==
                        RecruitMethod.karandaReservation
                ? TabBar(
                    controller: tabController,
                    tabs: [
                      Tab(
                        text: context.tr("recruitment post detail.details"),
                      ),
                      Tab(
                        text: context.tr("recruitment post detail.applicants"),
                      ),
                    ],
                  )
                : null,
          ),
          body: !snapshot.hasData
              ? const LoadingIndicator()
              : auth.authenticated &&
                      snapshot.requireData.author!.discordId == auth.discordId
                  ? TabBarView(
                      controller: tabController,
                      children: [
                        RecruitmentDetailTab(
                          data: snapshot.requireData,
                          applyFunction: apply,
                          openFunction: openPost,
                        ),
                        RecruitmentApplicantsTab(
                          post: snapshot.requireData,
                          stream: dataController.applicantsStream,
                          initFunction: dataController.getApplicants,
                          approveFunction: dataController.approve,
                          rejectFunction: dataController.reject,
                        ),
                      ],
                    )
                  : RecruitmentDetailTab(
                      data: snapshot.requireData,
                      applyFunction: apply,
                      openFunction: openPost,
                    ),
          floatingActionButton: snapshot.data?.applicant != null
              ? _ApplicantStatusFAB(applicant: snapshot.requireData.applicant!)
              : null,
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

class _MenuButton extends StatelessWidget {
  final Recruitment post;
  final void Function(Recruitment) updatePost;

  const _MenuButton({super.key, required this.post, required this.updatePost});

  @override
  Widget build(BuildContext context) {
    context.watch<AuthNotifier>().authenticated;
    return MenuAnchor(
      menuChildren: [
        MenuItemButton(
          onPressed: () async {
            Recruitment? result = await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => RecruitmentEditPage(
                  category: post.category,
                  recruitment: post,
                ),
              ),
            );
            if (result != null) {
              updatePost(result);
            }
          },
          leadingIcon: const Icon(Icons.edit),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(context.tr('recruitment post detail.edit')),
          ),
        ),
        MenuItemButton(
          onPressed: () {},
          leadingIcon: const Icon(Icons.share),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(context.tr('recruitment post detail.share')),
          ),
        ),
      ],
      alignmentOffset: const Offset(-86, -8),
      builder: (_, MenuController controller, Widget? child) {
        return Padding(
          padding: GlobalProperties.appBarActionPadding,
          child: IconButton(
            onPressed: () {
              if (controller.isOpen) {
                controller.close();
              } else {
                controller.open();
              }
            },
            icon: const Icon(Icons.more_vert_rounded),
          ),
        );
      },
    );
  }
}

class _ApplicantStatusFAB extends StatelessWidget {
  final Applicant applicant;

  const _ApplicantStatusFAB({super.key, required this.applicant});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      tooltip: applicant.status == ApplicantStatus.approved
          ? context.tr("recruitment post detail.copy code")
          : null,
      onPressed: applicant.status == ApplicantStatus.approved ? () {} : null,
      label: Text(
        context.tr(
          "recruitment post detail.FAB.${applicant.status.name}",
          args: applicant.status == ApplicantStatus.approved
              ? [applicant.code!]
              : null,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
