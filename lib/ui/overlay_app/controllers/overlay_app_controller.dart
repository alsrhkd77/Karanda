import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:karanda/service/overlay_app_service.dart';

class OverlayAppController extends ChangeNotifier {
  final OverlayAppService _appService;
  late final StreamSubscription _editMode;
  late final StreamSubscription _loading;

  bool editMode = false;
  bool loading = true;

  OverlayAppController({required OverlayAppService appService})
      : _appService = appService {
    _editMode = _appService.editModeStream.listen(_onEditModeUpdate);
    _loading = _appService.loadingStream.listen(_onLoadingStatusUpdate);
  }

  void exitEditMode(){
    _appService.exitEditMode();
  }

  void _onLoadingStatusUpdate(bool value){
    loading = value;
    notifyListeners();
  }

  void _onEditModeUpdate(bool value) {
    editMode = value;
    notifyListeners();
  }

  @override
  Future<void> dispose() async {
    await _editMode.cancel();
    await _loading.cancel();
    super.dispose();
  }
}
