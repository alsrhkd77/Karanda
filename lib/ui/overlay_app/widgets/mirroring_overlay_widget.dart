import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:karanda/enums/overlay_features.dart';
import 'package:karanda/ui/overlay_app/controllers/mirroring_overlay_controller.dart';
import 'package:karanda/ui/overlay_app/widgets/overlay_widget.dart';
import 'package:provider/provider.dart';

/// 미러링 오버레이 위젯.
/// 실제 미러 화면은 DWM이 박스 영역에 직접 합성하므로 Flutter는 배경(Card)과
/// 소스 미선택 안내 문구만 그린다.
class MirroringOverlayWidget extends StatelessWidget {
  final double width;
  final double height;

  const MirroringOverlayWidget({
    super.key,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MirroringOverlayController(
        service: context.read(),
        key: OverlayFeatures.mirroring,
        defaultRect: Rect.fromLTWH(
          2,
          (height - 400),
          440,
          247.5,
        ),
        constraints: const BoxConstraints(minWidth: 160, minHeight: 90),
      ),
      child: Consumer(
        builder: (context, MirroringOverlayController controller, child) {
          controller.devicePixelRatio =
              MediaQuery.devicePixelRatioOf(context);
          return OverlayWidget(
            feature: controller.key,
            boxController: controller.boxController,
            resizable: controller.editMode,
            show: controller.show,
            opacity: controller.opacity,
            contentBuilder: (context, rect, flip) {
              if (controller.hasSource) {
                return const SizedBox.expand();
              }
              return Center(
                child: Text(
                  context.tr("overlay.mirroring hint"),
                  textAlign: TextAlign.center,
                  style: TextTheme.of(context)
                      .bodyMedium
                      ?.copyWith(color: Colors.grey),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
