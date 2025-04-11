import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:karanda/service/overlay_app_service.dart';

class OverlayAppController extends ChangeNotifier {
  final OverlayAppService _appService;
  late final StreamSubscription _editMode;

  bool? editMode;

  OverlayAppController({required OverlayAppService appService})
      : _appService = appService {
    _editMode = _appService.editModeStream.listen(_onEditModeUpdate);
  }

  void exitEditMode(){
    _appService.exitEditMode();
  }

  void _onEditModeUpdate(bool value) {
    editMode = value;
    notifyListeners();
  }

  @override
  Future<void> dispose() async {
    await _editMode.cancel();
    super.dispose();
  }
}
