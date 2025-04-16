import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:karanda/ui/core/ui/karanda_app_bar.dart';
import 'package:karanda/ui/core/ui/loading_indicator.dart';
import 'package:karanda/ui/core/ui/page_base.dart';
import 'package:karanda/ui/settings/controller/karanda_info_controller.dart';
import 'package:provider/provider.dart';

class KarandaInfoPage extends StatelessWidget {
  const KarandaInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => KarandaInfoController()..load(),
      child: Scaffold(
        appBar: KarandaAppBar(
          icon: Icons.info_outline,
          title: context.tr("settings.info"),
        ),
        body: Consumer(
          builder: (context, KarandaInfoController controller, child) {
            if (controller.data == null) {
              return const LoadingIndicator();
            }
            return PageBase(children: [
              ListTile(
                title: Text(context.tr("settings.platform")),
                subtitle: Text(controller.platform),
              ),
              ListTile(
                title: Text(context.tr("settings.version")),
                subtitle: Text(controller.version),
              ),
              ListTile(
                title: Text(context.tr("settings.build number")),
                subtitle: Text(controller.buildNumber),
              ),
              ListTile(
                title: Text(context.tr("settings.flutter version")),
                subtitle: const Text("3.29.0"),
              ),
            ]);
          },
        ),
      ),
    );
  }
}
