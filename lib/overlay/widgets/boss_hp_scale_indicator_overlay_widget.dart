import 'package:flutter/material.dart';
import 'package:flutter_box_transform/flutter_box_transform.dart';
import 'package:karanda/overlay/overlay_data_controller.dart';
import 'package:karanda/overlay/utils/box_utils.dart';
import 'package:karanda/widgets/custom_angular_handle.dart';

class BossHpScaleIndicatorOverlayWidget extends StatefulWidget {
  final bool editMode;
  final bool enabled;

  const BossHpScaleIndicatorOverlayWidget(
      {super.key, required this.editMode, required this.enabled});

  @override
  State<BossHpScaleIndicatorOverlayWidget> createState() =>
      _BossHpScaleIndicatorOverlayWidgetState();
}

class _BossHpScaleIndicatorOverlayWidgetState
    extends State<BossHpScaleIndicatorOverlayWidget> {
  final OverlayDataController _dataController = OverlayDataController();
  final _boxController = TransformableBoxController();
  final String key = "boss hp scale indicator";

  @override
  void initState() {
    super.initState();
    loadBoxProperties();
    _boxController.setConstraints(const BoxConstraints(
      minWidth: 200,
      maxWidth: 800,
      minHeight: 12,
      maxHeight: 48,
    ));
  }

  Future<void> loadBoxProperties() async {
    Rect? rect = await BoxUtils.loadBoxRect(key) ??
        Rect.fromLTWH(
          _dataController.screenSize.width / 2 - 201,
          46,
          400,
          24,
        );
    _boxController.setRect(rect);
  }

  @override
  Widget build(BuildContext context) {
    return TransformableBox(
      controller: _boxController,
      resizable: widget.editMode,
      handleAlignment: HandleAlignment.inside,
      onChanged: (event, detail) => BoxUtils.saveRect(key, event.rect),
      visibleHandles: const {
        HandlePosition.topLeft,
        HandlePosition.bottomRight
      },
      enabledHandles: const {
        HandlePosition.topLeft,
        HandlePosition.bottomRight
      },
      sideHandleBuilder: (context, handle) {
        return CustomAngularHandle(handle: handle);
      },
      cornerHandleBuilder: (context, handle) {
        return CustomAngularHandle(handle: handle);
      },
      contentBuilder: (context, rect, flip) {
        return Opacity(
          opacity: widget.editMode
              ? 1.0
              : widget.enabled
                  ? 1.0
                  : 0.0,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _CustomWidget(
                height: rect.height,
                right: false,
                color: Colors.white.withOpacity(0.7),
              ),
              _CustomWidget(
                height: rect.height,
                right: true,
                color: Colors.white.withOpacity(0.7),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CustomWidget extends StatelessWidget {
  final double height;
  final bool right;
  final Color color;

  const _CustomWidget({
    super.key,
    required this.height,
    required this.right,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final EdgeInsets padding = EdgeInsets.fromLTRB(0, 0, 0, height / 2);
    const double width = 1.5;
    return Expanded(
      child: Table(
        defaultColumnWidth: const FlexColumnWidth(),
        border: TableBorder(
          top: BorderSide.none,
          bottom: BorderSide.none,
          horizontalInside: BorderSide.none,
          right: right ? BorderSide.none : BorderSide(width: 3, color: color),
          left: BorderSide.none,
          verticalInside: BorderSide(width: width, color: color),
        ),
        children: [
          TableRow(
            children: List<Widget>.generate(
              5,
              (index) => Container(
                padding: padding,
                height: height,
                child: VerticalDivider(
                  color: color,
                  width: width,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
