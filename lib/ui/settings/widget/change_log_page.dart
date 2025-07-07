import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:karanda/data_source/github_api.dart';
import 'package:karanda/repository/github_repository.dart';
import 'package:karanda/ui/core/theme/dimes.dart';
import 'package:karanda/ui/core/ui/karanda_app_bar.dart';
import 'package:karanda/ui/core/ui/loading_indicator.dart';
import 'package:karanda/ui/settings/controller/change_log_controller.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:provider/provider.dart';

import '../../../utils/launch_url.dart';

class ChangeLogPage extends StatelessWidget {
  const ChangeLogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: KarandaAppBar(
        icon: Icons.description_outlined,
        title: context.tr("settings.updateHistory"),
      ),
      body: MultiProvider(
        providers: [
          Provider(create: (context) => GithubApi()),
          Provider(
            create: (context) => GithubRepository(githubApi: context.read()),
          ),
          ChangeNotifierProvider(
            create: (context) => ChangeLogController(
              githubRepository: context.read(),
            )..getChangeLog(),
          ),
        ],
        child: Consumer(
          builder: (context, ChangeLogController controller, child) {
            if (controller.contents?.isEmpty ?? true) {
              return const LoadingIndicator();
            }
            final width = MediaQuery.sizeOf(context).width;
            return MarkdownWidget(
              data: controller.contents ?? "",
              padding: Dimens.constrainedPagePadding(width),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            launchURL('https://github.com/Hammuu1112/Karanda/releases'),
        child: const Icon(Icons.open_in_new),
      ),
    );
  }
}
