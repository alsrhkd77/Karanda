import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:karanda/data_source/bartering_data_source.dart';
import 'package:karanda/repository/bartering_repository.dart';
import 'package:karanda/ui/bartering/widget/bartering_settings_page.dart';
import 'package:karanda/ui/bartering/widget/simple_bartering_parley_tab.dart';
import 'package:karanda/ui/bartering/widget/simple_bartering_weight_tab.dart';
import 'package:karanda/ui/core/ui/karanda_app_bar.dart';
import 'package:provider/provider.dart';

class BarteringPage extends StatefulWidget {
  const BarteringPage({super.key});

  @override
  State<BarteringPage> createState() => _BarteringPageState();
}

class _BarteringPageState extends State<BarteringPage>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (context) => BarteringDataSource()),
        Provider(
          create: (context) => BarteringRepository(
            barteringDataSource: context.read(),
          ),
        ),
      ],
      builder: (context, child) {
        return Scaffold(
          appBar: KarandaAppBar(
            title: context.tr("bartering.bartering"),
            icon: FontAwesomeIcons.arrowRightArrowLeft,
            bottom: TabBar(
              controller: _tabController,
              tabs: [
                Tab(icon: Icon(FontAwesomeIcons.solidHandshake)),
                Tab(icon: Icon(FontAwesomeIcons.weightHanging)),
              ],
            ),
            actions: [
              Consumer(builder: (context, BarteringRepository repository, child){
                return IconButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => BarteringSettingsPage(
                        repository: repository,
                      ),
                    ));
                  },
                  icon: const Icon(Icons.construction),
                  tooltip: context.tr("config"),
                );
              }),
            ],
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              SimpleBarteringParleyTab(),
              SimpleBarteringWeightTab(),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
