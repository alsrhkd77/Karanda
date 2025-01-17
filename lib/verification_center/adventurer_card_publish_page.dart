import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:karanda/common/api.dart';
import 'package:karanda/common/enums/adventurer_card_background.dart';
import 'package:karanda/common/go_router_extension.dart';
import 'package:karanda/verification_center/services/adventurer_card_publish_service.dart';
import 'package:karanda/verification_center/models/bdo_family.dart';
import 'package:karanda/verification_center/services/verification_center_data_controller.dart';
import 'package:karanda/verification_center/widgets/adventurer_card_widget.dart';
import 'package:karanda/widgets/custom_base.dart';
import 'package:karanda/widgets/default_app_bar.dart';
import 'package:karanda/widgets/loading_indicator.dart';

class AdventurerCardPublishPage extends StatefulWidget {
  final BdoFamily family;
  final VerificationCenterDataController verificationCenterService;

  const AdventurerCardPublishPage({
    super.key,
    required this.family,
    required this.verificationCenterService,
  });

  @override
  State<AdventurerCardPublishPage> createState() =>
      _AdventurerCardPublishPageState();
}

class _AdventurerCardPublishPageState extends State<AdventurerCardPublishPage> {
  late final AdventurerCardPublishService service;

  @override
  void initState() {
    service = AdventurerCardPublishService(family: widget.family);
    super.initState();
  }

  @override
  void dispose() {
    service.dispose();
    super.dispose();
  }

  Future<void> publish() async {
    final result = await service.publish();
    if (result != null) {
      widget.verificationCenterService.addAdventurerCard(result, widget.family);
      if (context.mounted) {
        Navigator.of(context).pop();
        context.goWithGa(
            "/verification-center/adventurer-card/${result.verificationCode}");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DefaultAppBar(
        title: context.tr('adventurer card.title'),
        icon: FontAwesomeIcons.idCard,
      ),
      body: StreamBuilder(
        stream: service.cardData,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const LoadingIndicator();
          }
          return CustomBase(
            children: [
              Container(
                constraints: const BoxConstraints(maxHeight: 480),
                padding: const EdgeInsets.all(8.0),
                child: FittedBox(
                  child: AdventurerCardWidget(data: snapshot.requireData),
                ),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12.0,
                    horizontal: 8.0,
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        title: TextFormField(
                          decoration: InputDecoration(
                            labelText: context.tr('keywords'),
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.deny(RegExp(r'\s'))
                          ],
                          onChanged: service.setKeywords,
                        ),
                      ),
                      _ShowFamilyName(
                        value: snapshot.requireData.familyName.isNotEmpty,
                        onChanged: service.setFamilyNameOption,
                      ),
                      ListTile(
                        title: Text(context.tr('backgrounds')),
                        subtitle: _BackgroundSelector(
                          selected: snapshot.requireData.background,
                          onSelected: service.setBackground,
                        ),
                      ),
                      Container(
                        width: Size.infinite.width,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: ElevatedButton(
                          onPressed: publish,
                          child: Text(context.tr("adventurer card.publish")),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BackgroundSelector extends StatelessWidget {
  final AdventurerCardBackground selected;
  final void Function(AdventurerCardBackground) onSelected;

  const _BackgroundSelector({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return GridView.count(
      shrinkWrap: true,
      padding: const EdgeInsets.only(top: 12.0),
      crossAxisCount: min(width ~/ 270, 3),
      childAspectRatio: 16 / 9,
      mainAxisSpacing: 8.0,
      crossAxisSpacing: 8.0,
      children: AdventurerCardBackground.values.map((item) {
        return _BackgroundCard(
          background: item,
          onSelected: onSelected,
          selected: selected == item,
        );
      }).toList(),
    );
  }
}

class _BackgroundCard extends StatelessWidget {
  final AdventurerCardBackground background;
  final void Function(AdventurerCardBackground) onSelected;
  final bool selected;

  const _BackgroundCard({
    super.key,
    required this.background,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            "${Api.cardBackground}/${background.name}.jpg",
            fit: BoxFit.fill,
          ),
          selected
              ? Container(
                  color: Colors.black.withOpacity(0.4),
                  alignment: Alignment.topRight,
                  child: const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Icon(
                      size: 28,
                      Icons.check_circle,
                      color: Colors.green,
                    ),
                  ),
                )
              : Positioned.fill(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        onSelected(background);
                      },
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

class _ShowFamilyName extends StatelessWidget {
  final bool value;
  final void Function(bool?) onChanged;

  const _ShowFamilyName({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: value,
      onChanged: onChanged,
      title: Text(context.tr('adventurer card.show family name')),
    );
  }
}
