import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:karanda/enums/bdo_region.dart';
import 'package:karanda/ui/adventurer_hub/controllers/adventurer_hub_controller.dart';
import 'package:karanda/ui/adventurer_hub/widgets/edit_recruitment_post_page.dart';
import 'package:karanda/ui/core/ui/karanda_app_bar.dart';
import 'package:karanda/ui/core/ui/snack_bar_set.dart';
import 'package:provider/provider.dart';

class AdventurerHubPage extends StatelessWidget {
  final BDORegion region;
  const AdventurerHubPage({super.key, required this.region});

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
        //body: LoadingIndicator(),
        body: Center(child: Text(region.name)),
        floatingActionButton: _FAB(region: region),
      ),
    );
  }
}

class _FAB extends StatefulWidget {
  final BDORegion region;

  const _FAB({super.key, required this.region});

  @override
  State<_FAB> createState() => _FABState();
}

class _FABState extends State<_FAB> {

  @override
  Widget build(BuildContext context) {
    final authenticated = context.watch<AdventurerHubController>().authenticated;
    return FloatingActionButton.extended(
      label: Text(context.tr("adventurer hub.FAB label")),
      onPressed: () {
        if(authenticated){
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => EditRecruitmentPostPage(
              region: widget.region,
            ),
          ));
        } else {
          SnackBarSet.of(context).needLogin();
        }
      },
    );
  }
}
