import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:karanda/enums/bdo_region.dart';
import 'package:karanda/model/recruitment.dart';
import 'package:karanda/ui/core/ui/karanda_app_bar.dart';
import 'package:karanda/ui/core/ui/loading_indicator.dart';
import 'package:karanda/ui/core/ui/page_base.dart';
import 'package:karanda/ui/core/ui/snack_bar_kit.dart';
import 'package:karanda/utils/extension/build_context_extension.dart';
import 'package:karanda/utils/extension/go_router_extension.dart';
import 'package:provider/provider.dart';

import '../controllers/party_finder_controller.dart';
import 'edit_recruitment_post_page.dart';
import 'recruitment_tile.dart';

class PartyFinderPage extends StatelessWidget {
  const PartyFinderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PartyFinderController(
        partyFinderService: context.read(),
      ),
      child: Scaffold(
        appBar: KarandaAppBar(
          icon: FontAwesomeIcons.circleNodes,
          title: context.tr("partyFinder.partyFinder"),
        ),
        body: Consumer(
          builder: (context, PartyFinderController controller, child) {
            if (controller.recruitments == null) {
              return const LoadingIndicator();
            }
            return PageBase(
              children: [
                ...controller.recruitments!
                    .map((post) => RecruitmentTile(data: post))
                    .toList(),
              ],
            );
          },
        ),
        floatingActionButton: const _FAB(),
      ),
    );
  }
}

class _FAB extends StatelessWidget {
  const _FAB({super.key});

  @override
  Widget build(BuildContext context) {
    final authenticated =
        context.watch<PartyFinderController>().authenticated;
    final region = context.region;
    if (region == null) {
      return const FloatingActionButton(
        onPressed: null,
        child: CircularProgressIndicator(),
      );
    }
    return FloatingActionButton.extended(
      icon: const Icon(FontAwesomeIcons.penToSquare),
      label: Text(context.tr("partyFinder.recruit")),
      onPressed: () async {
        if (authenticated) {
          final Recruitment? result = await Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => EditRecruitmentPostPage(
              region: context.region ?? BDORegion.KR,
            ),
          ),);
          if(context.mounted && result != null){
            context.goWithGa("/party-finder/recruit/${result.id}");
          }
        } else {
          SnackBarKit.of(context).needLogin();
        }
      },
    );
  }
}
