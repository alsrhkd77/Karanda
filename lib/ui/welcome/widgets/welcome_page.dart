import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:karanda/enums/bdo_region.dart';
import 'package:karanda/ui/core/ui/karanda_app_bar.dart';
import 'package:karanda/ui/core/ui/loading_indicator.dart';
import 'package:karanda/ui/core/ui/page_base.dart';
import 'package:karanda/ui/core/ui/section.dart';
import 'package:karanda/ui/welcome/controllers/welcome_controller.dart';
import 'package:provider/provider.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          WelcomeController(appSettingsRepository: context.read()),
      child: Scaffold(
        appBar: KarandaAppBar(
          icon: FontAwesomeIcons.language,
          title: context.tr("settings.welcome"),
        ),
        body: Consumer(builder: (context, WelcomeController controller, child) {
          if (controller.region == null) {
            return const LoadingIndicator();
          }
          return PageBase(
            children: [
              Section(
                icon: Icons.translate,
                title: "Language",
                child: Column(
                  children: context.supportedLocales.map((item) {
                    return _LocaleTile(
                      locale: item,
                      selected: context.locale,
                    );
                  }).toList(),
                ),
              ),
              /*Section(
                icon: Icons.dns,
                title: context.tr("settings.region"),
                child: Column(
                  children: BDORegion.values.map((region) {
                    return _RegionTile(
                      region: region,
                      selected: controller.region!,
                    );
                  }).toList(),
                ),
              ),*/
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: ElevatedButton(
                  onPressed: () {
                    if (kIsWeb) {
                      GoRouter.of(context).pop();
                    } else {
                      context.go("/");
                    }
                  },
                  child: Text(context.tr("confirm")),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _LocaleTile extends StatelessWidget {
  final Locale selected;
  final Locale locale;

  const _LocaleTile({super.key, required this.locale, required this.selected});

  @override
  Widget build(BuildContext context) {
    return RadioListTile(
      groupValue: selected,
      value: locale,
      onChanged: (value) {
        if (value != null) {
          context.setLocale(value);
        }
      },
      title: Text(locale.toLanguageTag()),
    );
  }
}

class _RegionTile extends StatelessWidget {
  final BDORegion selected;
  final BDORegion region;

  const _RegionTile({super.key, required this.region, required this.selected});

  @override
  Widget build(BuildContext context) {
    return RadioListTile(
      groupValue: selected,
      value: region,
      onChanged: context.read<WelcomeController>().setRegion,
      title: Text(region.name),
    );
  }
}
