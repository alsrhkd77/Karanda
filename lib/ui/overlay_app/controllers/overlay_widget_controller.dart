import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_box_transform/flutter_box_transform.dart';
import 'package:karanda/enums/overlay_features.dart';
import 'package:karanda/service/overlay_app_service.dart';
import 'package:karanda/ui/core/theme/app_theme.dart';

/// Overlay widget controller들의 공통 부분
abstract class OverlayWidgetController extends ChangeNotifier {
  final OverlayFeatures key;
  final Rect defaultRect;
  final OverlayAppService service;
  final boxController = TransformableBoxController();
  late final StreamSubscription _editMode;
  late final StreamSubscription _activated;
  late final StreamSubscription _resetWidgets;
  late final StreamSubscription _position;
  late final StreamSubscription _opacity;

  bool editMode = false;
  bool activated = false;
  int opacity = AppTheme.overlayDefaultOpacity;

  OverlayWidgetController({
    required this.key,
    required this.defaultRect,
    required BoxConstraints constraints,
    required this.service,
  }) {
    _loadBoxRect();
    boxController.setConstraints(constraints);
    _editMode = service.editModeStream.listen(_onEditModeUpdate);
    _activated = service.activationStatusStream.listen(_onActivateStatusUpdate);
    _resetWidgets = service.resetWidgetsStream.listen(_onResetWidgets);
    _position = service.positionStream.listen(_onPositionUpdate);
    _opacity = service.opacityStream.listen(_onOpacityUpdate);
  }

  bool get show => editMode ? true : activated;

  Future<void> _loadBoxRect() async {
    //final rect = kDebugMode ? null : await service.loadRect(key);
    // final rect = await service.loadRect(key);
    // boxController.setRect(rect ?? defaultRect);
    boxController.setRect(defaultRect);
  }

  void _onResetWidgets(bool value){
    if(value){
      boxController.setRect(defaultRect);
      service.saveRect(key, defaultRect);
    }
  }

  void _onEditModeUpdate(bool value) {
    if (editMode != value) {
      editMode = value;
      notifyListeners();
      if (!value && !kDebugMode) {
        service.saveRect(key, boxController.rect);
      }
    }
  }

  void _onActivateStatusUpdate(Map<OverlayFeatures, bool> value) {
    if (value.containsKey(key)) {
      activated = value[key]!;
      notifyListeners();
    }
  }

  void _onPositionUpdate(Map<OverlayFeatures, Rect> value){
    boxController.setRect(value[key] ?? defaultRect);
  }

  void _onOpacityUpdate(Map<OverlayFeatures, int> value){
    if (value.containsKey(key)) {
      opacity = value[key]!;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _activated.cancel();
    _editMode.cancel();
    _resetWidgets.cancel();
    _position.cancel();
    _opacity.cancel();
    boxController.dispose();
    super.dispose();
  }
}
