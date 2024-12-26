import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_box_transform/flutter_box_transform.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:karanda/adventurer_hub/models/recruitment.dart';
import 'package:karanda/common/enums/recruit_method.dart';
import 'package:karanda/overlay/overlay_data_controller.dart';
import 'package:karanda/overlay/utils/box_utils.dart';
import 'package:karanda/overlay/widgets/edit_mode_card_widget.dart';
import 'package:karanda/widgets/custom_angular_handle.dart';
import 'package:karanda/widgets/discord_name_widget.dart';
import 'package:karanda/widgets/family_name_widget.dart';
import 'package:karanda/widgets/loading_indicator.dart';

class AdventurerHubOverlayWidget extends StatefulWidget {
  final bool editMode;
  final bool enabled;

  const AdventurerHubOverlayWidget({
    super.key,
    required this.editMode,
    required this.enabled,
  });

  @override
  State<AdventurerHubOverlayWidget> createState() =>
      _AdventurerHubOverlayWidgetState();
}

class _AdventurerHubOverlayWidgetState
    extends State<AdventurerHubOverlayWidget> {
  final key = "adventurer hub overlay";
  final OverlayDataController dataController = OverlayDataController();
  final _boxController = TransformableBoxController();

  @override
  void initState() {
    super.initState();
    loadBoxProperties();
  }

  Future<void> loadBoxProperties() async {
    final height = (dataController.screenSize.height / 3) - 24;
    Rect rect = await BoxUtils.loadBoxRect(key) ??
        Rect.fromLTWH(
          20,
          (dataController.screenSize.height / 2) - (height / 2),
          340,
          height,
        );
    _boxController.setRect(rect);
    _boxController.setConstraints(const BoxConstraints(
      minWidth: 240,
      minHeight: 120,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return TransformableBox(
      controller: _boxController,
      resizable: widget.editMode,
      handleAlignment: HandleAlignment.inside,
      onChanged: (event, detail) => BoxUtils.saveRect(key, event.rect),
      cornerHandleBuilder: (context, handle) {
        return CustomAngularHandle(handle: handle);
      },
      sideHandleBuilder: (context, handle) {
        return CustomAngularHandle(handle: handle);
      },
      contentBuilder: (context, rect, flip) {
        return StreamBuilder(
          stream: dataController.adventurerHubStream,
          builder: (context, snapshot) {
            if (widget.editMode) {
              return EditModeCardWidget(
                title: context.tr("adventurer hub title"),
              );
            } else if (!snapshot.hasData) {
              return Opacity(
                opacity: widget.enabled ? 1.0 : 0.0,
                child: const Card(
                  child: LoadingIndicator(
                    size: 40,
                  ),
                ),
              );
            }
            final posts = snapshot.requireData.where((post) => post.status);
            return Card(
              child: ListView(
                children: [
                  ListTile(
                    leading: const Icon(FontAwesomeIcons.circleNodes),
                    title: Text(
                      context.tr("adventurer hub title"),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  posts.isEmpty
                      ? SizedBox(
                          height: rect.height - 36,
                          child: Center(
                            child: Text(
                              context.tr("adventurer hub.no posts open"),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : const SizedBox(),
                  ...posts.map((post) => _PostTile(post: post)),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _PostTile extends StatelessWidget {
  final Recruitment post;

  const _PostTile({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    String title = post.title;
    if (post.recruitMethod == RecruitMethod.karandaReservation) {
      title =
          "$title (${post.currentParticipants}/${post.maximumParticipants})";
    } else {
      title = "$title (${post.maximumParticipants})";
    }
    return ListTile(
      leadingAndTrailingTextStyle: Theme.of(context).textTheme.bodyMedium,
      title: Text(title),
      subtitle:
          post.author!.mainFamily != null && post.author!.mainFamily!.verified
              ? FamilyNameWidget(family: post.author!.mainFamily!)
              : DiscordNameWidget(user: post.author!),
    );
  }
}
