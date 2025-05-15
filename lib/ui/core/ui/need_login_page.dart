import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:karanda/ui/core/theme/dimes.dart';
import 'package:karanda/ui/core/ui/karanda_app_bar.dart';

import '../../auth/widgets/auth_page.dart';

class NeedLoginPage extends StatelessWidget {
  const NeedLoginPage({super.key});

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
                  "Need login!",
                  style: TextTheme.of(context).headlineMedium,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.login),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const AuthPage(),
                    ));
                  },
                  label: Text(context.tr("auth.social login")),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.home),
                  onPressed: () => context.go("/"),
                  label: const Text("Home"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
