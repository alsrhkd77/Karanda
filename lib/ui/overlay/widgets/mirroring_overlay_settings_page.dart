import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:karanda/enums/box_sizing_mode.dart';
import 'package:karanda/enums/mirror_crop_mode.dart';
import 'package:karanda/enums/overlay_features.dart';
import 'package:karanda/model/window_info.dart';
import 'package:karanda/ui/core/ui/karanda_app_bar.dart';
import 'package:karanda/ui/core/ui/loading_indicator.dart';
import 'package:karanda/ui/core/ui/page_base.dart';
import 'package:karanda/ui/overlay/controllers/overlay_controller.dart';
import 'package:karanda/ui/overlay/widgets/opacity_slider.dart';
import 'package:provider/provider.dart';

/// 미러링 오버레이 상세 설정 페이지.
/// 소스 프로그램 선택(세션 한정), 크롭 모드, 표시 영역 크기 모드, 투명도를 설정한다.
class MirroringOverlaySettingsPage extends StatelessWidget {
  final OverlayController overlayController;

  const MirroringOverlaySettingsPage({
    super.key,
    required this.overlayController,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: overlayController,
      child: Scaffold(
        appBar: KarandaAppBar(
          icon: FontAwesomeIcons.layerGroup,
          title: context.tr("overlay.overlay"),
        ),
        body: Consumer(
          builder: (context, OverlayController controller, child) {
            if (controller.overlaySettings == null) {
              return const LoadingIndicator();
            }
            final settings = controller.overlaySettings!.mirroringSettings;
            return PageBase(
              children: [
                SwitchListTile(
                  title: Text(context.tr("overlay.use overlay")),
                  value: controller.overlaySettings!.activatedFeatures
                      .contains(OverlayFeatures.mirroring),
                  onChanged: (value) {
                    controller.switchActivation(
                      OverlayFeatures.mirroring,
                      value,
                    );
                  },
                ),
                const _SourceSelector(),
                const Divider(),
                _Header(title: context.tr("overlay.mirroring settings.crop mode")),
                RadioListTile(
                  title: Text(
                      context.tr("overlay.mirroring settings.crop full")),
                  value: MirrorCropMode.full,
                  groupValue: settings.cropMode,
                  onChanged: (value) {
                    settings.cropMode = MirrorCropMode.full;
                    controller.updateMirroringSettings(settings);
                  },
                ),
                RadioListTile(
                  title: Text(
                      context.tr("overlay.mirroring settings.crop ratio")),
                  value: MirrorCropMode.ratio,
                  groupValue: settings.cropMode,
                  onChanged: (value) {
                    settings.cropMode = MirrorCropMode.ratio;
                    controller.updateMirroringSettings(settings);
                  },
                ),
                if (settings.cropMode == MirrorCropMode.ratio)
                  _AspectRatioInput(
                    aspectWidth: settings.cropAspectWidth,
                    aspectHeight: settings.cropAspectHeight,
                    onChanged: (width, height) {
                      settings.cropAspectWidth = width;
                      settings.cropAspectHeight = height;
                      controller.updateMirroringSettings(settings);
                    },
                  ),
                RadioListTile(
                  title: Text(
                      context.tr("overlay.mirroring settings.crop custom")),
                  value: MirrorCropMode.custom,
                  groupValue: settings.cropMode,
                  onChanged: (value) {
                    settings.cropMode = MirrorCropMode.custom;
                    controller.updateMirroringSettings(settings);
                  },
                ),
                if (settings.cropMode == MirrorCropMode.custom)
                  _RegionInput(
                    region: settings.customRegion,
                    onChanged: (region) {
                      settings.customRegion = region;
                      controller.updateMirroringSettings(settings);
                    },
                  ),
                const Divider(),
                _Header(
                    title:
                        context.tr("overlay.mirroring settings.box sizing")),
                RadioListTile(
                  title:
                      Text(context.tr("overlay.mirroring settings.box free")),
                  value: BoxSizingMode.free,
                  groupValue: settings.boxSizingMode,
                  onChanged: (value) {
                    settings.boxSizingMode = BoxSizingMode.free;
                    controller.updateMirroringSettings(settings);
                  },
                ),
                RadioListTile(
                  title:
                      Text(context.tr("overlay.mirroring settings.box ratio")),
                  value: BoxSizingMode.ratio,
                  groupValue: settings.boxSizingMode,
                  onChanged: (value) {
                    settings.boxSizingMode = BoxSizingMode.ratio;
                    controller.updateMirroringSettings(settings);
                  },
                ),
                if (settings.boxSizingMode == BoxSizingMode.ratio)
                  _AspectRatioInput(
                    aspectWidth: settings.boxAspectWidth,
                    aspectHeight: settings.boxAspectHeight,
                    onChanged: (width, height) {
                      settings.boxAspectWidth = width;
                      settings.boxAspectHeight = height;
                      controller.updateMirroringSettings(settings);
                    },
                  ),
                const Divider(),
                OpacitySlider(
                  opacity: controller.overlaySettings
                          ?.opacity[OverlayFeatures.mirroring] ??
                      0,
                  onChanged: (value) {
                    controller.setOpacity(OverlayFeatures.mirroring, value);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.info_outline, size: 20),
                  title: Text(
                    context.tr("overlay.mirroring settings.drm notice"),
                    style: TextTheme.of(context)
                        .bodySmall
                        ?.copyWith(color: Colors.grey),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;

  const _Header({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title, style: TextTheme.of(context).titleMedium),
    );
  }
}

/// 미러링 소스 프로그램 선택 타일. 탭하면 현재 열린 창 목록 다이얼로그를 띄운다.
class _SourceSelector extends StatelessWidget {
  const _SourceSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<OverlayController>();
    final source = controller.mirroringSource;
    return ListTile(
      title: Text(context.tr("overlay.mirroring settings.select program")),
      subtitle: Text(
        source?.title ??
            context.tr("overlay.mirroring settings.not selected"),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(Icons.window),
      onTap: () => _showWindowListDialog(context, controller),
    );
  }

  Future<void> _showWindowListDialog(
    BuildContext context,
    OverlayController controller,
  ) async {
    final windows = controller.getMirrorableWindows();
    if (!context.mounted) return;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title:
              Text(context.tr("overlay.mirroring settings.select program")),
          content: SizedBox(
            width: 480,
            child: windows.isEmpty
                ? Center(
                    child: Text(
                      context.tr("overlay.mirroring settings.no windows"),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: windows.length,
                    itemBuilder: (context, index) {
                      final WindowInfo window = windows[index];
                      return ListTile(
                        title: Text(
                          window.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () {
                          controller.setMirroringSource(window);
                          Navigator.of(context).pop();
                        },
                      );
                    },
                  ),
          ),
          actions: [
            if (controller.mirroringSource != null)
              TextButton(
                onPressed: () {
                  controller.setMirroringSource(null);
                  Navigator.of(context).pop();
                },
                child: Text(
                    context.tr("overlay.mirroring settings.clear selection")),
              ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(context.tr("cancel")),
            ),
          ],
        );
      },
    );
  }
}

/// 종횡비 입력 (프리셋 + 직접 입력)
class _AspectRatioInput extends StatefulWidget {
  final double aspectWidth;
  final double aspectHeight;
  final void Function(double width, double height) onChanged;

  const _AspectRatioInput({
    super.key,
    required this.aspectWidth,
    required this.aspectHeight,
    required this.onChanged,
  });

  @override
  State<_AspectRatioInput> createState() => _AspectRatioInputState();
}

class _AspectRatioInputState extends State<_AspectRatioInput> {
  static const presets = [(16.0, 9.0), (21.0, 9.0), (4.0, 3.0)];
  late final TextEditingController _width;
  late final TextEditingController _height;

  @override
  void initState() {
    super.initState();
    _width = TextEditingController(text: _format(widget.aspectWidth));
    _height = TextEditingController(text: _format(widget.aspectHeight));
  }

  @override
  void dispose() {
    _width.dispose();
    _height.dispose();
    super.dispose();
  }

  String _format(double value) {
    return value == value.roundToDouble()
        ? value.round().toString()
        : value.toString();
  }

  void _submit() {
    final width = double.tryParse(_width.text);
    final height = double.tryParse(_height.text);
    if (width == null || height == null || width <= 0 || height <= 0) return;
    widget.onChanged(width, height);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 8.0,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          for (final (width, height) in presets)
            ChoiceChip(
              label: Text("${width.round()}:${height.round()}"),
              selected: widget.aspectWidth == width &&
                  widget.aspectHeight == height,
              onSelected: (selected) {
                if (!selected) return;
                _width.text = _format(width);
                _height.text = _format(height);
                widget.onChanged(width, height);
              },
            ),
          SizedBox(
            width: 64,
            child: TextField(
              controller: _width,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
              ],
              decoration: const InputDecoration(
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
              ),
              textAlign: TextAlign.center,
              onSubmitted: (value) => _submit(),
              onTapOutside: (event) => _submit(),
            ),
          ),
          const Text(":"),
          SizedBox(
            width: 64,
            child: TextField(
              controller: _height,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
              ],
              decoration: const InputDecoration(
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
              ),
              textAlign: TextAlign.center,
              onSubmitted: (value) => _submit(),
              onTapOutside: (event) => _submit(),
            ),
          ),
        ],
      ),
    );
  }
}

/// 직접 지정 크롭 영역 입력 (소스 창 클라이언트 기준 물리 픽셀)
class _RegionInput extends StatefulWidget {
  final Rect? region;
  final void Function(Rect) onChanged;

  const _RegionInput({super.key, required this.region, required this.onChanged});

  @override
  State<_RegionInput> createState() => _RegionInputState();
}

class _RegionInputState extends State<_RegionInput> {
  late final TextEditingController _x;
  late final TextEditingController _y;
  late final TextEditingController _width;
  late final TextEditingController _height;

  @override
  void initState() {
    super.initState();
    final region = widget.region;
    _x = TextEditingController(text: region?.left.round().toString() ?? "0");
    _y = TextEditingController(text: region?.top.round().toString() ?? "0");
    _width = TextEditingController(
        text: region?.width.round().toString() ?? "1920");
    _height = TextEditingController(
        text: region?.height.round().toString() ?? "1080");
  }

  @override
  void dispose() {
    _x.dispose();
    _y.dispose();
    _width.dispose();
    _height.dispose();
    super.dispose();
  }

  void _submit() {
    final x = double.tryParse(_x.text);
    final y = double.tryParse(_y.text);
    final width = double.tryParse(_width.text);
    final height = double.tryParse(_height.text);
    if (x == null || y == null || width == null || height == null) return;
    if (width <= 0 || height <= 0) return;
    widget.onChanged(Rect.fromLTWH(x, y, width, height));
  }

  Widget _field(String label, TextEditingController controller) {
    return SizedBox(
      width: 96,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
        ),
        textAlign: TextAlign.center,
        onSubmitted: (value) => _submit(),
        onTapOutside: (event) => _submit(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 8.0,
        children: [
          _field("X", _x),
          _field("Y", _y),
          _field("W", _width),
          _field("H", _height),
        ],
      ),
    );
  }
}
