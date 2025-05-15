import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:karanda/ui/core/theme/dimes.dart';
import 'package:karanda/ui/core/ui/karanda_app_bar.dart';

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const KarandaAppBar(),
      body: Padding(
        padding: Dimens.pagePadding,
        child: Center(
          child: Column(
            children: [
              Expanded(
                child: Image.asset(
                  "assets/image/exclamation.png",
                  fit: BoxFit.contain,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Page not found!",
                  style: TextTheme.of(context).headlineMedium,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.home),
                  onPressed: () => context.go("/"),
                  label: const Text("Home"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
