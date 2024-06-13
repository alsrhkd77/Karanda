import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:karanda/common/global_properties.dart';
import 'package:karanda/horse_status/horse_status_data_controller.dart';
import 'package:karanda/widgets/default_app_bar.dart';
import 'package:karanda/widgets/title_text.dart';

class HorseStatusPage extends StatefulWidget {
  const HorseStatusPage({super.key});

  @override
  State<HorseStatusPage> createState() => _HorseStatusPageState();
}

class _HorseStatusPageState extends State<HorseStatusPage> {
  final HorseStatusDataController dataController = HorseStatusDataController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DefaultAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const ListTile(
              leading: Icon(FontAwesomeIcons.stickerMule),
              title: TitleText('말 성장치 계산기', bold: true),
            ),
            Container(
              constraints: BoxConstraints(
                maxWidth: GlobalProperties.widthConstrains,
              ),
              child: Column(
                children: [],
              ),
            )
          ],
        ),
      ),
    );
  }
}
