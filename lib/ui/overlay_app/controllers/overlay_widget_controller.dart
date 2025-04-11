import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_box_transform/flutter_box_transform.dart';
import 'package:karanda/enums/overlay_features.dart';
import 'package:karanda/service/overlay_app_service.dart';

/// Overlay widget controller들의 공통 부분
abstract class OverlayWidgetController extends ChangeNotifier {
  final OverlayFeatures key;
  final Rect defaultRect;
  final OverlayAppService service;
  final boxController = TransformableBoxController();
  late final StreamSubscription _editMode;
  late final StreamSubscription _activated;

  bool editMode = false;
  bool activated = false;

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
  }

  bool get show => editMode ? true : activated;

  Future<void> _loadBoxRect() async {
    final rect = await service.loadRect(key);
    boxController.setRect(rect ?? defaultRect);
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

  @override
  void dispose() {
    _activated.cancel();
    _editMode.cancel();
    boxController.dispose();
    super.dispose();
  }
}
