import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:karanda/ui/core/theme/dimes.dart';
import 'package:karanda/ui/core/ui/karanda_app_bar.dart';

class ColorCounterPage extends StatefulWidget {
  const ColorCounterPage({super.key});

  @override
  State<ColorCounterPage> createState() => _ColorCounterPageState();
}

class _ColorCounterPageState extends State<ColorCounterPage> {
  final List<_Color> colors = [
    _Color(name: "red", color: Colors.red),
    _Color(name: "yellow", color: Colors.yellow),
    _Color(name: "blue", color: Colors.blue),
    _Color(name: "white", color: Colors.white),
  ];

  void reset() {
    setState(() {
      for (_Color color in colors) {
        color.reset();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final dimension = size.width > size.height
        ? (size.width - 80) / 5
        : (size.height - 80) / 5;
    return Scaffold(
      appBar: KarandaAppBar(
        icon: FontAwesomeIcons.staffSnake,
        title: context.tr("colorCounter.colorCounter"),
      ),
      body: Container(
        alignment: Alignment.center,
        padding: Dimens.pagePadding,
        child: Flex(
          direction: size.width > size.height ? Axis.horizontal : Axis.vertical,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: colors.map((color) {
            return _ColorBox(
              color: color,
              onPressed: () {
                setState(() {
                  color.increase();
                });
              },
              dimension: dimension,
            );
          }).toList(),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: colors.map((color) {
            return _DecreaseButton(
              color: color,
              onPressed: () {
                setState(() {
                  color.decrease();
                });
              },
            );
          }).toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: reset,
        elevation: 0.0,
        tooltip: context.tr("colorCounter.reset"),
        child: const Icon(Icons.refresh),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
    );
  }
}

class _ColorBox extends StatelessWidget {
  final _Color color;
  final double dimension;
  final void Function() onPressed;

  const _ColorBox({
    super.key,
    required this.color,
    required this.onPressed,
    required this.dimension,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: dimension,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
            side: const BorderSide(color: Colors.black),
          ),
          foregroundColor: Colors.black,
          backgroundColor: color.color,
        ),
        onPressed: onPressed,
        child: Text(
          color.count.toString(),
          style: TextTheme.of(context)
              .headlineLarge
              ?.copyWith(color: Colors.black),
        ),
      ),
    );
  }
}

class _DecreaseButton extends StatelessWidget {
  final _Color color;
  final void Function() onPressed;

  const _DecreaseButton({
    super.key,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: IconButton.filled(
        onPressed: onPressed,
        icon: const Icon(Icons.remove),
        color: color.color,
      ),
    );
  }
}

class _Color {
  final String name;
  final Color color;
  int count;

  _Color({required this.name, required this.color, this.count = 0});

  void increase() {
    count++;
  }

  void decrease() {
    if (count > 0) {
      count--;
    }
  }

  void reset() {
    count = 0;
  }
}
