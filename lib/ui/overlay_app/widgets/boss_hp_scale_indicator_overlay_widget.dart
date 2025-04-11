import 'package:flutter/material.dart';
import 'package:flutter_box_transform/flutter_box_transform.dart';
import 'package:karanda/enums/overlay_features.dart';
import 'package:karanda/ui/overlay_app/controllers/boss_hp_scale_indicator_overlay_controller.dart';
import 'package:karanda/ui/overlay_app/widgets/custom_angular_handle.dart';
import 'package:provider/provider.dart';

class BossHpScaleIndicatorOverlayWidget extends StatelessWidget {
  final double width;

  const BossHpScaleIndicatorOverlayWidget({super.key, required this.width});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => BossHpScaleIndicatorController(
        key: OverlayFeatures.bossHpScaleIndicator,
        defaultRect: Rect.fromLTWH(width / 2 - 201, 46, 400, 24),
        constraints: const BoxConstraints(
          minWidth: 200,
          maxWidth: 800,
          minHeight: 12,
          maxHeight: 48,
        ),
        service: context.read(),
      ),
      child: Consumer(
        builder: (context, BossHpScaleIndicatorController controller, child) {
          return TransformableBox(
            controller: controller.boxController,
            resizable: controller.editMode,
            visibleHandles: const {
              HandlePosition.topLeft,
              HandlePosition.bottomRight
            },
            enabledHandles: const {
              HandlePosition.topLeft,
              HandlePosition.bottomRight
            },
            cornerHandleBuilder: (context, handle) {
              return CustomAngularHandle(handle: handle);
            },
            sideHandleBuilder: (context, handle) {
              return CustomAngularHandle(handle: handle);
            },
            contentBuilder: (context, rect, flip) {
              return AnimatedOpacity(
                opacity: controller.show ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _Scale(
                      height: rect.height,
                      showLastScale: true,
                      color: Colors.white.withAlpha(178),
                    ),
                    _Scale(
                      height: rect.height,
                      showLastScale: false,
                      color: Colors.white.withAlpha(178),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _Scale extends StatelessWidget {
  final double height;
  final bool showLastScale;
  final Color color;
  final double scaleWidth;

  const _Scale({
    super.key,
    required this.height,
    required this.showLastScale,
    required this.color,
    this.scaleWidth = 1.5,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Table(
        defaultColumnWidth: const FlexColumnWidth(),
        border: TableBorder(
          top: BorderSide.none,
          bottom: BorderSide.none,
          right: showLastScale
              ? BorderSide(width: 3, color: color)
              : BorderSide.none,
          left: BorderSide.none,
          horizontalInside: BorderSide.none,
          verticalInside: BorderSide(width: scaleWidth, color: color),
        ),
        children: [
          TableRow(
            children: List<Widget>.generate(
              5,
              (index) => Container(
                padding: EdgeInsets.only(bottom: height / 2),
                height: height,
                child: VerticalDivider(
                  color: color,
                  width: scaleWidth,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
