import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:karanda/ui/core/ui/karanda_app_bar.dart';

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const KarandaAppBar(),
      body: Center(
        child: Column(
          children: [
            Image.asset("assets/image/exclamation.png"),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("Page not found"),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.home),
              onPressed: () => context.go("/"),
              label: const Text("Home"),
            )
          ],
        ),
      ),
    );
  }
}
