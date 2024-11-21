import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:karanda/adventurer_hub/edit_recruitment_page.dart';
import 'package:karanda/common/enums/recruitment_category.dart';
import 'package:karanda/common/global_properties.dart';
import 'package:karanda/widgets/custom_base.dart';
import 'package:karanda/widgets/default_app_bar.dart';

class AdventurerHubPage extends StatefulWidget {
  const AdventurerHubPage({super.key});

  @override
  State<AdventurerHubPage> createState() => _AdventurerHubPageState();
}

class _AdventurerHubPageState extends State<AdventurerHubPage>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DefaultAppBar(
        title: "모험가 허브",
        icon: FontAwesomeIcons.circleNodes,
        actions: [
          /*TextButton(
            onPressed: () {},
            child: Text("KR"),
          ),*/
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("KR"),
          ),
          Padding(
            padding: GlobalProperties.appBarActionPadding,
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.construction),
              tooltip: "설정",
            ),
          )
        ],
      ),
      body: CustomBase(
        children: [
          Text("Hello world!"),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => EditRecruitmentPage(
              category: RecruitmentCategory.guildRaidMercenariesRecruitment,
            ),
          ));
        },
        label: Text("모집하기"),
        icon: Icon(Icons.create),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
