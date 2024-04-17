import 'package:flutter/material.dart';
import 'package:karanda/common/global_properties.dart';
import 'package:karanda/common/launch_url.dart';
import 'package:karanda/settings/brand_card.dart';
import 'package:karanda/widgets/default_app_bar.dart';
import 'package:karanda/widgets/title_text.dart';

class SupportKarandaPage extends StatelessWidget {
  const SupportKarandaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DefaultAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: GlobalProperties.widthConstrains,
            ),
            child: Column(
              children: [
                const ListTile(
                  title: TitleText('후원하기', bold: true),
                ),
                const Divider(),
                const SizedBox(height: 24.0,),
                BrandCard(assetPath: 'assets/image/toss_full.png', onTap: () => launchURL('https://toss.me/hammuu')),
                //BrandCard(assetPath: 'assets/image/bmc_full.png', onTap: () => launchURL('https://www.buymeacoffee.com/hammuu')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
