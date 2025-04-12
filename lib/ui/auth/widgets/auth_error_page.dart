import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:karanda/ui/core/ui/karanda_app_bar.dart';

class AuthErrorPage extends StatelessWidget {
  const AuthErrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const KarandaAppBar(),
      body: Center(
        child: Column(
          children: [
            Image.asset("assets/image/exclamation.png"),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(context.tr("auth.auth error")),
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
