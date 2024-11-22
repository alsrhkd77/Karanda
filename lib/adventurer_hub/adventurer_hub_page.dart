import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:karanda/adventurer_hub/recruitment_edit_page.dart';
import 'package:karanda/auth/auth_notifier.dart';
import 'package:karanda/common/enums/recruitment_category.dart';
import 'package:karanda/common/global_properties.dart';
import 'package:karanda/widgets/custom_base.dart';
import 'package:karanda/widgets/default_app_bar.dart';
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DefaultAppBar(
        title: "모험가 허브 (Beta)",
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
      body: TabBarView(
        controller: _tabController,
        children: [
          CustomBase(
            children: [
              Text("All!"),
            ],
          ),
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
      ),
      floatingActionButton: context.watch<AuthNotifier>().waitResponse
          ? null
          : FloatingActionButton.extended(
              onPressed: () async {
                if(context.read<AuthNotifier>().authenticated){
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
              label: const Text("adventurer hub.FAB label").tr(),
              icon: const Icon(Icons.create),
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
      title: const Text("adventurer hub.new post").tr(),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: RecruitmentCategory.values.map((e) {
          return RadioListTile(
            value: e,
            title: Text("adventurer hub category.${e.name}").tr(),
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
          child: const Text("cancel").tr(),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          onPressed: () => Navigator.of(context).pop(selected),
          child: const Text("select").tr(),
        )
      ],
    );
  }
}
