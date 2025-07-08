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
      ),
    );
  }
}
