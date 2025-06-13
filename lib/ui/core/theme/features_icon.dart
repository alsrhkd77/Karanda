import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:karanda/enums/features.dart';

abstract class FeaturesIcon {
  static IconData get worldBoss => FontAwesomeIcons.dragon;

  static IconData get adventurerHub => FontAwesomeIcons.circleNodes;

  static IconData get notifications => FontAwesomeIcons.bell;

  static IconData byFeature(Features feature) {
    return switch (feature) {
      Features.worldBoss => worldBoss,
      Features.adventurerHub => adventurerHub,
    Features.notifications => notifications
    };
  }
}
