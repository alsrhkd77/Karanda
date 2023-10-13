import 'package:flutter/material.dart';
import 'package:karanda/widgets/default_app_bar.dart';

class ColorCounterPage extends StatefulWidget {
  const ColorCounterPage({super.key});

  @override
  State<ColorCounterPage> createState() => _ColorCounterPageState();
}

class _ColorCounterPageState extends State<ColorCounterPage> {
  Axis get _direction =>
      MediaQuery.of(context).size.width > MediaQuery.of(context).size.height
          ? Axis.horizontal
          : Axis.vertical;

  double get _dimension =>
      MediaQuery.of(context).size.width < MediaQuery.of(context).size.height
          ? (MediaQuery.of(context).size.height - 80) / 5
          : (MediaQuery.of(context).size.width - 80) / 5;

  List<_Colors> colorList = [
    _Colors(name: 'red', color: Colors.red),
    _Colors(name: 'yellow', color: Colors.yellow),
    _Colors(name: 'blue', color: Colors.blue),
    _Colors(name: 'white', color: Colors.white),
  ];

  Widget colorBox(_Colors value) {
    return SizedBox.square(
      dimension: _dimension,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0),
              side: BorderSide(color: Colors.black)),
          foregroundColor: Colors.black,
          backgroundColor: Colors.white,
        ),
        onPressed: () {},
        child: Text('12', style: TextStyle(fontSize: 32.0)),
      ),
    );
  }

  void increaseCount() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DefaultAppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Flex(
            direction: _direction,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: colorList
                .map(
                  (e) => _ColorBox(
                    item: e,
                    dimension: _dimension,
                    onPressed: () {
                      setState(() {
                        e.increase();
                      });
                    },
                  ),
                )
                .toList(),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: colorList
              .map(
                (e) => _DecreaseButton(
                  item: e,
                  onPressed: () {
                    setState(() {
                      e.decrease();
                    });
                  },
                ),
              )
              .toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            for (var element in colorList) {
              element.count = 0;
            }
          });
        },
        elevation: 0.0,
        child: const Icon(Icons.refresh),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
    );
  }
}

class _Colors {
  String name;
  Color color;
  int count;

  _Colors({required this.name, required this.color, this.count = 0});

  void increase() {
    count++;
  }

  void decrease() {
    if (count > 0) {
      count--;
    }
  }
}

class _ColorBox extends StatelessWidget {
  final _Colors item;
  final double dimension;
  final Function onPressed;

  const _ColorBox(
      {super.key,
      required this.item,
      required this.dimension,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: dimension,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0),
              side: const BorderSide(color: Colors.black)),
          foregroundColor: Colors.black,
          backgroundColor: item.color,
        ),
        onPressed: () => onPressed(),
        child: Text('${item.count}', style: const TextStyle(fontSize: 32.0)),
      ),
    );
  }
}

class _DecreaseButton extends StatelessWidget {
  final _Colors item;
  final Function onPressed;

  const _DecreaseButton(
      {super.key, required this.item, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: IconButton.filled(
        onPressed: () => onPressed(),
        icon: const Icon(Icons.remove),
        color: item.color,
      ),
    );
  }
}
