import 'package:flutter/material.dart';
import 'package:karanda/common/go_router_extension.dart';

class InvalidAccessPage extends StatelessWidget {
  const InvalidAccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Karanda'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.warning,
              color: Colors.red,
              size: 180,
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("잘못된 접근입니다"),
            ),
            ElevatedButton(
              onPressed: () {
                context.goWithGa('/');
              },
              child: const Text("Back"),
            )
          ],
        ),
      ),
    );
  }
}
