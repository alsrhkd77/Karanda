import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:karanda/adventurer_hub/tabs/home_tab.dart';
import 'package:karanda/adventurer_hub/adventurer_hub_data_controller.dart';
import 'package:karanda/adventurer_hub/recruitment_edit_page.dart';
import 'package:karanda/auth/auth_notifier.dart';
import 'package:karanda/common/enums/recruitment_category.dart';
import 'package:karanda/common/global_properties.dart';
import 'package:karanda/widgets/custom_base.dart';
import 'package:karanda/widgets/default_app_bar.dart';
import 'package:karanda/widgets/loading_indicator.dart';
import 'package:karanda/widgets/need_login_snack_bar.dart';
import 'package:provider/provider.dart';

class AdventurerHubPage extends StatefulWidget {
  const AdventurerHubPage({super.key});

  @override
  State<AdventurerHubPage> createState() => _AdventurerHubPageState();
}

class _AdventurerHubPageState extends State<AdventurerHubPage>
    with TickerProviderStateMixin {
  late final TabController _tabController;
  final AdventurerHubDataController dataController =
      AdventurerHubDataController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance
        .addPostFrameCallback((tick) => dataController.publish());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DefaultAppBar(
        title: context.tr("adventurer hub title"),
        icon: FontAwesomeIcons.circleNodes,
        actions: [
          /*TextButton(
            onPressed: () {},
            child: Text("KR"),
          ),*/
          Padding(
            padding: GlobalProperties.appBarActionPadding,
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.construction),
              tooltip: "설정",
            ),
          )
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            const Tab(text: 'Home'),
            ...RecruitmentCategory.values.map(
              (e) => Tab(text: context.tr("adventurer hub category.${e.name}")),
            ),
            Tab(text: "🚨 ${context.tr("reporting")}"),
          ],
        ),
      ),
      body: StreamBuilder(
        stream: dataController.postsStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const LoadingIndicator();
          }
          return TabBarView(
            controller: _tabController,
            children: [
              HomeTab(posts: snapshot.requireData),
              CustomBase(
                children: [
                  Text("Hello world!"),
                ],
              ),
              CustomBase(
                children: [
                  Text("Hello world!"),
                ],
              ),
              CustomBase(
                children: [
                  Text("Reporting!"),
                ],
              ),
            ],
          );
        },
      ),
      floatingActionButton: context.watch<AuthNotifier>().waitResponse
          ? null
          : FloatingActionButton.extended(
              onPressed: () async {
                if (context.read<AuthNotifier>().authenticated) {
                  RecruitmentCategory? selected = await showDialog(
                    context: context,
                    builder: (context) => const _SelectCategoryDialog(),
                  );
                  if (selected != null && context.mounted) {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          RecruitmentEditPage(category: selected),
                    ));
                  }
                } else {
                  NeedLoginSnackBar(context);
                }
              },
              label: Text(context.tr("adventurer hub.FAB label")),
              icon: const Icon(FontAwesomeIcons.penToSquare),
            ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

class _SelectCategoryDialog extends StatefulWidget {
  const _SelectCategoryDialog({super.key});

  @override
  State<_SelectCategoryDialog> createState() => _SelectCategoryDialogState();
}

class _SelectCategoryDialogState extends State<_SelectCategoryDialog> {
  RecruitmentCategory selected = RecruitmentCategory.values.first;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.tr("adventurer hub.new post")),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: RecruitmentCategory.values.map((e) {
          return RadioListTile(
            value: e,
            title: Text(context.tr("adventurer hub category.${e.name}")),
            groupValue: selected,
            onChanged: (value) {
              setState(() {
                selected = e;
              });
            },
          );
        }).toList(),
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        TextButton(
          style: ElevatedButton.styleFrom(foregroundColor: Colors.red),
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.tr("cancel")),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          onPressed: () => Navigator.of(context).pop(selected),
          child: Text(context.tr("select")),
        )
      ],
    );
  }
}
