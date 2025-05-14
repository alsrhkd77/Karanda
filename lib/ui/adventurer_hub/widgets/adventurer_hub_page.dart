import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:karanda/enums/bdo_region.dart';
import 'package:karanda/model/recruitment.dart';
import 'package:karanda/ui/adventurer_hub/controllers/adventurer_hub_controller.dart';
import 'package:karanda/ui/adventurer_hub/widgets/edit_recruitment_post_page.dart';
import 'package:karanda/ui/adventurer_hub/widgets/recruitment_tile.dart';
import 'package:karanda/ui/core/ui/karanda_app_bar.dart';
import 'package:karanda/ui/core/ui/loading_indicator.dart';
import 'package:karanda/ui/core/ui/page_base.dart';
import 'package:karanda/ui/core/ui/snack_bar_set.dart';
import 'package:karanda/utils/extension/build_context_extension.dart';
import 'package:karanda/utils/extension/go_router_extension.dart';
import 'package:provider/provider.dart';

class AdventurerHubPage extends StatelessWidget {
  const AdventurerHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AdventurerHubController(
        adventurerHubService: context.read(),
      ),
      child: Scaffold(
        appBar: KarandaAppBar(
          icon: FontAwesomeIcons.circleNodes,
          title: context.tr("adventurer hub.adventurer hub"),
        ),
        body: Consumer(
          builder: (context, AdventurerHubController controller, child) {
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
        context.watch<AdventurerHubController>().authenticated;
    final region = context.region;
    if (region == null) {
      return const FloatingActionButton(
        onPressed: null,
        child: CircularProgressIndicator(),
      );
    }
    return FloatingActionButton.extended(
      icon: const Icon(FontAwesomeIcons.penToSquare),
      label: Text(context.tr("adventurer hub.recruit")),
      onPressed: () async {
        if (authenticated) {
          final Recruitment? result = await Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => EditRecruitmentPostPage(
              region: context.region ?? BDORegion.KR,
            ),
          ),);
          if(context.mounted && result != null){
            context.goWithGa("/adventurer-hub/recruit/${result.id}");
          }
        } else {
          SnackBarSet.of(context).needLogin();
        }
      },
    );
  }
}
