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

  Widget item() {
    return SizedBox.square(
      dimension: _dimension,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
            side: BorderSide(color: Colors.black)
          ),
          foregroundColor: Colors.black,
          backgroundColor: Colors.white,
        ),
        onPressed: () {},
        child: Text('12', style: TextStyle(fontSize: 32.0)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DefaultAppBar(),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(12.0),
          child: Flex(
            direction: _direction,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              item(),
              item(),
              item(),
              item(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: IconButton.filled(
                  onPressed: () {},
                  icon: Icon(Icons.remove),
                  color: Colors.red),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: IconButton.filled(
                  onPressed: () {},
                  icon: Icon(Icons.remove),
                  color: Colors.blue),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: IconButton.filled(
                  onPressed: () {},
                  icon: Icon(Icons.remove),
                  color: Colors.yellow),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: IconButton.filled(
                  onPressed: () {},
                  icon: Icon(Icons.remove),
                  color: Colors.white),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.refresh),
        onPressed: () {},
        elevation: 0.0,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
    );
  }
}
