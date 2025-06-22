import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:karanda/enums/recruitment_category.dart';
import 'package:karanda/model/overlay_settings.dart';
import 'package:karanda/model/recruitment.dart';
import 'package:karanda/ui/overlay_app/controllers/overlay_widget_controller.dart';
import 'dart:developer' as developer;

class PartyFinderOverlayController extends OverlayWidgetController {
  final ScrollController scrollController = ScrollController();
  List<Recruitment>? _recruitments;
  List<RecruitmentCategory> _excluded = [];
  late final StreamSubscription _settings;

  PartyFinderOverlayController({
    required super.key,
    required super.defaultRect,
    required super.constraints,
    required super.service,
  }) {
    _settings = service.settingsStream.listen(_onSettingsUpdate);
    service.registerCallback(key: key.name, callback: _onRecruitmentUpdate);
  }

  List<Recruitment>? get recruitments => _recruitments
      ?.where((value) => !_excluded.contains(value.category))
      .toList();

  void _onRecruitmentUpdate(MethodCall call) {
    final List<Recruitment> result = [];
    try {
      for (Map json in jsonDecode(call.arguments)) {
        result.add(Recruitment.fromJson(json));
      }
      _recruitments = result;
      notifyListeners();
    } catch (e) {
      developer
          .log("Failed to parse [PartyFinder] message\n${call.arguments}");
    }
  }

  void _onSettingsUpdate(OverlaySettings value) {
    _excluded = value.partyFinderExcludedCategory.toList();
    notifyListeners();
  }

  @override
  void dispose() {
    service.unregisterCallback(key.name);
    _settings.cancel();
    super.dispose();
  }
}
