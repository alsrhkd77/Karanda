import 'package:flutter/material.dart';
import 'package:karanda/enums/bdo_class.dart';
import 'package:karanda/utils/api_endpoints/karanda_api.dart';

class ClassSymbolWidget extends StatelessWidget {
  final double size;
  final BDOClass bdoClass;

  const ClassSymbolWidget(
      {super.key, this.size = 32.0, required this.bdoClass});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(shape: BoxShape.circle),
      child: Image.network(
        "${KarandaApi.classSymbol}/${bdoClass.name}.png",
        fit: BoxFit.fill,
        color: Theme.of(context).brightness == Brightness.dark
            ? null
            : Colors.black,
        // unknown 처럼 대응하는 심볼 이미지가 없거나 네트워크가 실패한 경우 깨진 이미지 대신
        // 대체 아이콘을 보여준다.
        errorBuilder: (context, error, stackTrace) =>
            Icon(Icons.help_outline, size: size),
      ),
    );
  }
}
