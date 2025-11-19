import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:karanda/enums/overlay_features.dart';
import 'package:karanda/enums/recruitment_type.dart';
import 'package:karanda/model/recruitment.dart';
import 'package:karanda/ui/core/ui/loading_indicator.dart';
import 'package:karanda/ui/overlay_app/controllers/party_finder_overlay_controller.dart';
import 'package:karanda/ui/overlay_app/widgets/overlay_widget.dart';
import 'package:provider/provider.dart';

class PartyFinderOverlayWidget extends StatelessWidget {
  final double height;

  const PartyFinderOverlayWidget({super.key, required this.height});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PartyFinderOverlayController(
        key: OverlayFeatures.partyFinder,
        defaultRect: Rect.fromLTWH(2, (height / 2) - ((height / 3) / 2), 440, height / 3),
        constraints: const BoxConstraints(minWidth: 200, minHeight: 400),
        service: context.read(),
      ),
      child: Consumer(
          builder: (context, PartyFinderOverlayController controller, child) {
        return OverlayWidget(
          resizable: controller.editMode,
          show: controller.show,
          opacity: controller.opacity,
          feature: controller.key,
          boxController: controller.boxController,
          contentBuilder: (context, rect, flip) {
            if (controller.recruitments == null) {
              return const LoadingIndicator();
            } else if (controller.recruitments?.isEmpty ?? true) {
              return Center(
                child: Text(context.tr("partyFinder.noPostsOpen")),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(6.0),
              //controller: controller.scrollController,
              physics: const NeverScrollableScrollPhysics(),
              addAutomaticKeepAlives: false,
              itemCount: controller.recruitments?.length ?? 0,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final data = controller.recruitments![index];
                return ListTile(
                  title: Text(data.title),
                  subtitle: _Subtitle(data: data),
                );
              },
            );
          },
        );
      }),
    );
  }
}

class _Subtitle extends StatelessWidget {
  final Recruitment data;

  const _Subtitle({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.groups, size: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: data.recruitmentType == RecruitmentType.karandaReservation
              ? Text("${data.currentParticipants} / ${data.maxMembers}")
              : Text(data.maxMembers.toString()),
        ),
      ],
    );
  }
}
