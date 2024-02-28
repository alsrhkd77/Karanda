import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:karanda/common/api.dart';
import 'package:karanda/common/global_properties.dart';

class BdoItemImageWidget extends StatelessWidget {
  final String code;
  final int? grade;
  final String enhancementLevel;
  final double size;

  const BdoItemImageWidget({
    super.key,
    required this.code,
    this.grade,
    this.enhancementLevel = '',
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    double fontSize = size / 3.8;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      padding: EdgeInsets.all(size * 0.1),
      decoration: BoxDecoration(
          border: Border.all(
              color: grade == null
                  ? Colors.transparent
                  : GlobalProperties.bdoItemGradeColor[grade!],
              width: 1.2),
          borderRadius: BorderRadius.circular(4.0)),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.network(
            '${Api.itemImage}/$code.png',
            width: size * 0.9,
            height: size * 0.9,
            fit: BoxFit.fill,
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
          Text(
            enhancementLevel,
            style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.normal,
                shadows: const [
                  Shadow(
                    color: Colors.red,
                    offset: Offset(0, 0),
                    blurRadius: 8.0,
                  ),
                ],
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = fontSize * 0.2
                  ..color = Colors.red),
          ),
          Text(
            enhancementLevel,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.normal,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
