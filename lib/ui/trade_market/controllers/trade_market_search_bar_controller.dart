import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:karanda/enums/bdo_region.dart';
import 'package:karanda/model/app_settings.dart';
import 'package:karanda/service/app_settings_service.dart';
import 'package:karanda/service/bdo_item_info_service.dart';
import 'package:karanda/utils/extension/go_router_extension.dart';

class TradeMarketSearchBarController extends ChangeNotifier {
  final BDOItemInfoService _itemInfoService;
  final AppSettingsService _settingsService;
  TextEditingController textEditingController = TextEditingController();
  final GoRouter _router;
  late final StreamSubscription _region;

  BDORegion? region;

  TradeMarketSearchBarController({
    required BDOItemInfoService itemInfoService,
    required AppSettingsService settingsService,
    required GoRouter router,
  })  : _itemInfoService = itemInfoService,
        _settingsService = settingsService,
        _router = router {
    _region = _settingsService.appSettingsStream.listen(_onSettingsUpdate);
  }

  List<String> getOptions(String value, Locale locale) {
    final items =
        _itemInfoService.tradeAbleItems.map((item) => item.name(locale));
    return items
        .where((item) => item
            .replaceAll(" ", "")
            .toLowerCase()
            .contains(value.toLowerCase()))
        .toList();
  }

  void onSelected(String value, Locale locale) {
    if (region != null) {
      textEditingController.clear();
      final target = _itemInfoService.tradeAbleItems
          .firstWhere((item) => item.name(locale) == value);
      _router.goWithGa("/trade-market/${region?.name}/detail/${target.code}");
    }
  }

  void onSubmitted(String value, Locale locale, void Function() onSubmit) {
    final options = getOptions(value, locale);
    if (region != null &&
        options.first.replaceAll(" ", "").toLowerCase() ==
            value.toLowerCase()) {
      textEditingController.clear();
      final target = _itemInfoService.tradeAbleItems
          .firstWhere((item) => item.name(locale) == options.first);
      _router.goWithGa("/trade-market/${region?.name}/detail/${target.code}");
    } else {
      onSubmit();
    }
  }

  void _onSettingsUpdate(AppSettings value) {
    region = value.region;
  }

  @override
  void dispose() {
    _region.cancel();
    super.dispose();
  }
}
