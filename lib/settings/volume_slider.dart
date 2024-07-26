import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:karanda/common/audio_controller.dart';
import 'package:karanda/widgets/loading_indicator.dart';

class VolumeSlider extends StatefulWidget {
  const VolumeSlider({super.key});

  @override
  State<VolumeSlider> createState() => _VolumeSliderState();
}

class _VolumeSliderState extends State<VolumeSlider> {
  final AudioController controller = AudioController();
  TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((timeStamp) => controller.subscribe());
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: controller.volume,
        builder: (context, volume) {
          if (!volume.hasData) {
            return const LoadingIndicator();
          }
          textEditingController.text = volume.requireData.toInt().toString();
          return ListTile(
            title: Slider(
              value: volume.requireData,
              onChanged: controller.setVolume,
              min: 0.0,
              max: 100.0,
              divisions: 100,
            ),
            trailing: SizedBox(
              width: 60.0,
              child: TextFormField(
                controller: textEditingController,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^(\d{0,3})')),
                ],
                textAlign: TextAlign.center,
                onChanged: (String? value){
                  if(value != null && value.isNotEmpty){
                    int parsed = int.tryParse(value) ?? 0;
                    controller.setVolume(parsed.toDouble());
                  }
                },
              ),
            ),
          );
        });
  }
}
