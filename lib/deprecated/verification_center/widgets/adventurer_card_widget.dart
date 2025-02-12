import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:karanda/common/api.dart';
import 'package:karanda/common/enums/bdo_class.dart';
import 'package:karanda/deprecated/verification_center/models/adventurer_card.dart';

class AdventurerCardWidget extends StatelessWidget {
  final GlobalKey? widgetKey;
  final AdventurerCard data;

  const AdventurerCardWidget({super.key, this.widgetKey, required this.data});

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(
      fontSize: 30,
      fontFamily: 'NanumSquareRound',
      color: Colors.white,
      overflow: TextOverflow.clip,
    );
    return RepaintBoundary(
      key: widgetKey,
      child: Container(
        clipBehavior: Clip.antiAlias,
        color: Colors.white,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        width: 960,
        height: 540,
        child: Stack(
          fit: StackFit.expand,
          alignment: Alignment.center,
          children: [
            Image.network("${Api.cardBackground}/${data.background.name}.jpg"),
            Container(
              color: Colors.black.withOpacity(0.6),
            ),
            Positioned(
              left: 105.5,
              top: 105.5,
              child: _ClassPortrait(
                bdoClass: data.mainClass,
                keywords: data.keywords,
                textStyle: textStyle,
              ),
            ),
            Positioned(
              right: 105,
              child: _Contents(
                familyName: data.familyName,
                guild: data.guild,
                createdOn: data.createdOn,
                contributionPoints: data.contributionPoints,
                highestLevel: data.highestLevel,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Contents extends StatelessWidget {
  final String familyName;
  final String guild;
  final String createdOn;
  final String contributionPoints;
  final int highestLevel;

  const _Contents({
    super.key,
    required this.familyName,
    required this.guild,
    required this.createdOn,
    required this.contributionPoints,
    required this.highestLevel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        familyName.isNotEmpty
            ? Text(
                context.tr(
                  "adventurer card contents.family name",
                  args: [familyName],
                ),
              )
            : const SizedBox(),
        Text(
          context.tr(
            "adventurer card contents.guild",
            args: [guild],
          ),
        ),
        Text(
          context.tr(
            "adventurer card contents.created on",
            args: [createdOn],
          ),
        ),
        Text(
          context.tr(
            "adventurer card contents.contribution points",
            args: [contributionPoints],
          ),
        ),
        Text(
          context.tr(
            "adventurer card contents.highest level",
            args: [
              highestLevel == 0
                  ? context.tr("private")
                  : highestLevel.toString(),
            ],
          ),
        ),
      ],
    );
  }
}

class _ClassPortrait extends StatelessWidget {
  final BdoClass bdoClass;
  final String keywords;
  final TextStyle textStyle;

  const _ClassPortrait({
    super.key,
    required this.bdoClass,
    required this.keywords,
    required this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: 237,
        height: 329,
        child: Stack(
          fit: StackFit.loose,
          alignment: Alignment.center,
          children: [
            Image.network("${Api.classPortrait}/${bdoClass.name}.jpg"),
            Positioned(
              height: 50,
              width: 50,
              bottom: keywords.isEmpty ? 2 : 25,
              child: Image.network(
                "${Api.classSymbol}/${bdoClass.name}.png",
              ),
            ),
            Positioned(
              width: 237,
              bottom: 2,
              child: Text(
                keywords,
                maxLines: 1,
                style: textStyle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
