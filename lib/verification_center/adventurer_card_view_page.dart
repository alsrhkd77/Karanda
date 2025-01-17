import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:karanda/common/global_properties.dart';
import 'package:karanda/verification_center/services/adventurer_card_view_service.dart';
import 'package:karanda/verification_center/widgets/adventurer_card_widget.dart';
import 'package:karanda/widgets/default_app_bar.dart';
import 'package:karanda/widgets/loading_indicator.dart';

import 'package:provider/provider.dart';

class AdventurerCardViewPage extends StatefulWidget {
  final String code;

  const AdventurerCardViewPage({super.key, required this.code});

  @override
  State<AdventurerCardViewPage> createState() => _AdventurerCardViewPageState();
}

class _AdventurerCardViewPageState extends State<AdventurerCardViewPage> {
  Future<void> download() async {
    final imgName = await context.read<AdventurerCardViewService>().saveImage();
    if (imgName.isNotEmpty && context.mounted && kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.tr("adventurer card.save image success", args: [imgName]),
          ),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          margin: GlobalProperties.snackBarMargin,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AdventurerCardViewService(code: widget.code),
      child: Scaffold(
        appBar: DefaultAppBar(
          icon: FontAwesomeIcons.idCard,
          title: context.tr('adventurer card.title'),
        ),
        body: Consumer<AdventurerCardViewService>(
          builder: (context, service, child) {
            if (service.adventurerCardData != null) {
              return InteractiveViewer(
                child: Center(
                  child: AdventurerCardWidget(
                    widgetKey: service.imageKey,
                    data: service.adventurerCardData!,
                  ),
                ),
              );
            } else if (service.errorMsg != null) {
              return Center(
                child: Text(context.tr(service.errorMsg!)),
              );
            }
            return const LoadingIndicator();
          },
        ),
        floatingActionButton: _FAB(onPressed: download),
      ),
    );
  }
}

class _FAB extends StatelessWidget {
  final Future<void> Function() onPressed;

  const _FAB({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<AdventurerCardViewService>().adventurerCardData;
    return FloatingActionButton.extended(
      onPressed: data == null ? null : onPressed,
      icon: const Icon(Icons.download),
      label: Text(context.tr("adventurer card.download")),
    );
  }
}

