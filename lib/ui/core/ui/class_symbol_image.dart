import 'package:flutter/material.dart';
import 'package:karanda/enums/bdo_class.dart';
import 'package:karanda/utils/api_endpoints/karanda_api.dart';

class ClassSymbolImage extends StatelessWidget {
  final double size;
  final BDOClass bdoClass;

  const ClassSymbolImage({super.key, this.size = 32.0, required this.bdoClass});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.network(
        "${KarandaApi.classSymbol}/${bdoClass.name}.png",
        fit: BoxFit.fill,
        color: Theme.of(context).brightness == Brightness.dark
            ? null
            : Colors.black,
      ),
    );
  }
}
