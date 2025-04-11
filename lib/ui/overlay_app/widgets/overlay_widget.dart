import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_box_transform/flutter_box_transform.dart';
import 'package:karanda/enums/overlay_features.dart';
import 'package:karanda/ui/overlay_app/widgets/custom_angular_handle.dart';

class OverlayWidget extends StatelessWidget {
  final Widget Function(BuildContext, Rect, Flip) contentBuilder;
  final TransformableBoxController boxController;
  final OverlayFeatures feature;
  final bool resizable;
  final bool show;

  const OverlayWidget({
    super.key,
    required this.resizable,
    required this.show,
    required this.feature,
    required this.boxController,
    required this.contentBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return TransformableBox(
      controller: boxController,
      resizable: resizable,
      cornerHandleBuilder: (context, handle) {
        return CustomAngularHandle(handle: handle);
      },
      sideHandleBuilder: (context, handle) {
        return CustomAngularHandle(handle: handle);
      },
      contentBuilder: (context, rect, flip) {
        return AnimatedOpacity(
          opacity: show ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: Card(
            child: resizable
                ? _Name(feature: feature)
                : contentBuilder(context, rect, flip),
          ),
        );
      },
    );
  }
}

class _Name extends StatelessWidget {
  final OverlayFeatures feature;

  const _Name({super.key, required this.feature});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        context.tr("overlay.${feature.name}"),
        style: TextTheme.of(context).headlineMedium,
      ),
    );
  }
}
