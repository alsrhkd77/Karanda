import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:karanda/ui/core/theme/app_colors.dart';
import 'package:karanda/utils/extension/build_context_extension.dart';

class BdoItemImage extends StatelessWidget {
  final String code;
  final bool coloredBorder;
  final int enhancementLevel;
  final double size;

  const BdoItemImage({
    super.key,
    required this.code,
    this.enhancementLevel = 0,
    this.size = 44,
    this.coloredBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    double fontSize = size / 3.0;
    final item = context.itemInfo(code);
    final text = item.enhancementLevelToString(enhancementLevel);
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(1),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(
          width: 1.2,
          color: coloredBorder
              ? AppColors.bdoItemGradeColors[item.grade]
              : Colors.transparent,
        ),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Stack(
        alignment: Alignment.center,
        fit: StackFit.expand,
        children: [
          Image.network(
            item.imagePath,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, imageChunkEvent) {
              if (imageChunkEvent == null) {
                return child;
              }
              return Center(
                child: SpinKitFadingFour(
                  color: Colors.blue.shade400,
                  size: size * 0.7,
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Image.asset('assets/image/unknown_item.png');
            },
          ),
          Center(
            child: Text(
              text,
              style: TextStyle(
                  fontSize: fontSize,
                  //fontWeight: FontWeight.normal,
                  shadows: const [
                    Shadow(
                      color: Colors.red,
                      offset: Offset(0, 0),
                      blurRadius: 8.0,
                    ),
                  ],
                  foreground: Paint()
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = fontSize * 0.25
                    ..color = Colors.red),
            ),
          ),
          Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: fontSize,
                //fontWeight: FontWeight.normal,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
