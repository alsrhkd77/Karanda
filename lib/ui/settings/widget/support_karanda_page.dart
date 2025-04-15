import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:karanda/ui/core/theme/dimes.dart';
import 'package:karanda/ui/core/ui/karanda_app_bar.dart';
import 'package:karanda/utils/external_links.dart';
import 'package:karanda/utils/launch_url.dart';

class SupportKarandaPage extends StatelessWidget {
  const SupportKarandaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: KarandaAppBar(
        icon: Icons.loyalty_outlined,
        title: context.tr("settings.support"),
      ),
      body: SingleChildScrollView(
        padding: Dimens.pagePadding,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: Dimens.pageMaxWidth),
            child: Column(
              children: [
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => launchURL(ExternalLinks.chzzk),
                    child: Image.asset(
                      "assets/image/chzzk_full.png",
                      isAntiAlias: true,
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
