import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:karanda/enums/bdo_region.dart';
import 'package:karanda/model/bdo_item_info.dart';
import 'package:karanda/service/app_settings_service.dart';
import 'package:karanda/service/bdo_item_info_service.dart';
import 'package:provider/provider.dart';

extension BuildContextExtension on BuildContext {
  String itemName(String code, [int enhancementLevel = 0]) {
    final item = watch<BDOItemInfoService>().itemInfo(code);
    String name = item.name(locale);
    if (enhancementLevel > 0) {
      final level = item.enhancementLevelToString(enhancementLevel);
      if (level.startsWith("+")) {
        name = "$level $name";
      } else {
        name = "${tr("enhancementLevel.$level")} : $name";
      }
    }
    return name;
  }

  BDOItemInfo itemInfo(String code) {
    return watch<BDOItemInfoService>().itemInfo(code);
  }

  BDORegion? get region => watch<AppSettingsService>().region;
}
